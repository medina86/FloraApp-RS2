using Microsoft.Extensions.Configuration;
using PayPal.Api;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class PayPalService
    {
        private readonly IConfiguration _configuration;
        private readonly string _clientId;
        private readonly string _clientSecret;
        private readonly string _mode;

        public PayPalService(IConfiguration configuration)
        {
            _configuration = configuration;
            _clientId = _configuration["PayPal:ClientID"];
            _clientSecret = _configuration["PayPal:SecretKey"];
            _mode = "sandbox"; // uvijek sandbox za development
        }

        private APIContext GetAPIContext()
        {
            var config = new Dictionary<string, string>
            {
                { "mode", _mode },
                { "clientId", _clientId },
                { "clientSecret", _clientSecret }
            };

            var accessToken = new OAuthTokenCredential(_clientId, _clientSecret, config).GetAccessToken();
            var apiContext = new APIContext(accessToken)
            {
                Config = config
            };

            return apiContext;
        }

        public async Task<Payment> CreatePayment(decimal amount, string currency, string description, string returnUrl, string cancelUrl)
        {
            try
            {
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

                var createdPayment = payment.Create(apiContext);
                return createdPayment;
            }
            catch (Exception ex)
            {
                throw new Exception($"PayPal payment creation failed: {ex.Message}", ex);
            }
        }

        public async Task<Payment> ExecutePayment(string paymentId, string payerId)
        {
            try
            {
                var apiContext = GetAPIContext();
                var payment = Payment.Get(apiContext, paymentId);

                var paymentExecution = new PaymentExecution
                {
                    payer_id = payerId
                };

                var executedPayment = payment.Execute(apiContext, paymentExecution);
                return executedPayment;
            }
            catch (Exception ex)
            {
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
