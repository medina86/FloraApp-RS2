using Microsoft.Extensions.Configuration;
using PayPal.Api;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class PayPalService
    {
        private readonly IConfiguration _configuration;
        private readonly string _clientId;
        private readonly string _clientSecret;
        private readonly string _mode;
        private readonly string _paypalBaseUrl = "https://api.sandbox.paypal.com"; // Sandbox URL

        public PayPalService(IConfiguration configuration)
        {
            _configuration = configuration;
            _clientId = _configuration["PayPal:ClientID"];
            _clientSecret = _configuration["PayPal:SecretKey"];
            _mode = "sandbox"; // uvijek sandbox za development
            
            Console.WriteLine($"PayPal configuration - ClientID: {_clientId?.Substring(0, 5)}..., SecretKey: {_clientSecret?.Substring(0, 5)}..., Mode: {_mode}");
        }

        private APIContext GetAPIContext()
        {
            try
            {
                Console.WriteLine("Creating PayPal API context...");
                
                var config = new Dictionary<string, string>
                {
                    { "mode", _mode },
                    { "clientId", _clientId },
                    { "clientSecret", _clientSecret },
                    { "connectionTimeout", "360000" },
                    { "requestRetries", "1" }
                };

                Console.WriteLine("Getting PayPal access token...");
                var accessToken = new OAuthTokenCredential(_clientId, _clientSecret, config).GetAccessToken();
                Console.WriteLine($"Access token obtained: {accessToken.Substring(0, 10)}...");
                
                var apiContext = new APIContext(accessToken)
                {
                    Config = config
                };

                return apiContext;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating PayPal API context: {ex.Message}");
                throw;
            }
        }
        
        // Alternativna metoda za dobivanje access tokena direktno preko HTTP poziva
        private async Task<string> GetAccessTokenViaHttp()
        {
            try
            {
                using (var httpClient = new HttpClient())
                {
                    // Postavljanje Basic Authentication headera
                    var authValue = Convert.ToBase64String(Encoding.UTF8.GetBytes($"{_clientId}:{_clientSecret}"));
                    httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Basic", authValue);
                    
                    // Priprema zahtjeva
                    var content = new FormUrlEncodedContent(new[]
                    {
                        new KeyValuePair<string, string>("grant_type", "client_credentials")
                    });
                    
                    // Slanje zahtjeva
                    var response = await httpClient.PostAsync($"{_paypalBaseUrl}/v1/oauth2/token", content);
                    
                    if (response.IsSuccessStatusCode)
                    {
                        var responseContent = await response.Content.ReadAsStringAsync();
                        var tokenResponse = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(responseContent);
                        return tokenResponse["access_token"].GetString();
                    }
                    else
                    {
                        throw new Exception($"Failed to get access token. Status code: {response.StatusCode}");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting access token via HTTP: {ex.Message}");
                throw;
            }
        }

        // Alternativna metoda za kreiranje PayPal narudžbe preko REST API-ja
        public async Task<string> CreateOrderViaRest(decimal amount, string currency, string description, string returnUrl, string cancelUrl)
        {
            try
            {
                Console.WriteLine($"Creating PayPal order via REST API - Amount: {amount} {currency}, Description: {description}");
                
                // Dobivanje access tokena
                var accessToken = await GetAccessTokenViaHttp();
                
                using (var httpClient = new HttpClient())
                {
                    // Postavljanje Authorization headera
                    httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
                    httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                    
                    // Kreiranje tijela zahtjeva
                    var orderRequest = new
                    {
                        intent = "CAPTURE",
                        purchase_units = new[]
                        {
                            new
                            {
                                amount = new
                                {
                                    currency_code = currency,
                                    value = amount.ToString("0.00")
                                },
                                description = description
                            }
                        },
                        application_context = new
                        {
                            return_url = returnUrl,
                            cancel_url = cancelUrl
                        }
                    };
                    
                    var jsonContent = JsonSerializer.Serialize(orderRequest);
                    var content = new StringContent(jsonContent, Encoding.UTF8, "application/json");
                    
                    // Slanje zahtjeva
                    var response = await httpClient.PostAsync($"{_paypalBaseUrl}/v2/checkout/orders", content);
                    
                    if (response.IsSuccessStatusCode)
                    {
                        var responseContent = await response.Content.ReadAsStringAsync();
                        Console.WriteLine($"PayPal order created successfully: {responseContent}");
                        
                        var orderResponse = JsonSerializer.Deserialize<Dictionary<string, JsonElement>>(responseContent);
                        
                        // Traženje approval URL-a
                        var links = orderResponse["links"].EnumerateArray();
                        foreach (var link in links)
                        {
                            if (link.GetProperty("rel").GetString() == "approve")
                            {
                                return link.GetProperty("href").GetString();
                            }
                        }
                        
                        throw new Exception("Approval URL not found in PayPal response");
                    }
                    else
                    {
                        var errorContent = await response.Content.ReadAsStringAsync();
                        throw new Exception($"Failed to create PayPal order. Status code: {response.StatusCode}, Response: {errorContent}");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating PayPal order via REST API: {ex.Message}");
                throw;
            }
        }

        public async Task<Payment> CreatePayment(decimal amount, string currency, string description, string returnUrl, string cancelUrl)
        {
            try
            {
                Console.WriteLine($"Creating PayPal payment - Amount: {amount} {currency}, Description: {description}");
                Console.WriteLine($"Return URL: {returnUrl}, Cancel URL: {cancelUrl}");
                
                var apiContext = GetAPIContext();

                var payment = new Payment
                {
                    intent = "sale",
                    payer = new Payer { payment_method = "paypal" },
                    transactions = new List<Transaction>
                    {
                        new Transaction
                        {
                            description = description,
                            invoice_number = Guid.NewGuid().ToString(),
                            amount = new Amount
                            {
                                currency = currency,
                                total = amount.ToString("F2")
                            }
                        }
                    },
                    redirect_urls = new RedirectUrls
                    {
                        return_url = returnUrl,
                        cancel_url = cancelUrl
                    }
                };

                Console.WriteLine("Calling PayPal API to create payment...");
                var createdPayment = payment.Create(apiContext);
                Console.WriteLine($"Payment created successfully. Payment ID: {createdPayment.id}, State: {createdPayment.state}");
                
                return createdPayment;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"PayPal payment creation failed: {ex.Message}");
                Console.WriteLine($"Exception details: {ex}");
                throw new Exception($"PayPal payment creation failed: {ex.Message}", ex);
            }
        }

        public async Task<Payment> ExecutePayment(string paymentId, string payerId)
        {
            try
            {
                if (string.IsNullOrEmpty(payerId))
                {
                    throw new ArgumentException("PayerID is required for PayPal payment execution", nameof(payerId));
                }
                
                Console.WriteLine($"Executing payment with paymentId: {paymentId}, payerId: {payerId}");
                
                var apiContext = GetAPIContext();
                
                Console.WriteLine("Getting payment details from PayPal...");
                var payment = Payment.Get(apiContext, paymentId);
                Console.WriteLine($"Payment retrieved. Current state: {payment.state}");

                var paymentExecution = new PaymentExecution
                {
                    payer_id = payerId
                };
                
                Console.WriteLine("Executing real PayPal payment...");
                Console.WriteLine($"Payment ID: {paymentId}");
                Console.WriteLine($"Payer ID: {payerId}");
                var executedPayment = payment.Execute(apiContext, paymentExecution);
                Console.WriteLine($"Payment executed successfully. Final state: {executedPayment.state}");

                return executedPayment;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"PayPal execution error: {ex.Message}");
                Console.WriteLine($"Full exception details: {ex}");
                throw new Exception($"PayPal payment execution failed: {ex.Message}", ex);
            }
        }

        public async Task<Payment> GetPayment(string paymentId)
        {
            try
            {
                var apiContext = GetAPIContext();
                return Payment.Get(apiContext, paymentId);
            }
            catch (Exception ex)
            {
                throw new Exception($"PayPal get payment failed: {ex.Message}", ex);
            }
        }

        public string GetApprovalUrl(Payment payment)
        {
            var approvalUrl = payment.links.Find(link => link.rel.Equals("approval_url", StringComparison.OrdinalIgnoreCase));
            return approvalUrl?.href;
        }
    }
}