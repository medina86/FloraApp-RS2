﻿using Azure.Storage.Blobs;
using Flora.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Flora.Services.Services
{
    public class BlobService : IBlobService
    {
        
            private readonly BlobServiceClient _blobServiceClient;
            private readonly string _containerName = "profile-images";

            public BlobService(IConfiguration config)
            {
                _blobServiceClient = new BlobServiceClient(config["AzureBlobStorage:ConnectionString"]);
            }

            public async Task<string> UploadFileAsync(IFormFile file)
            {
                var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                await containerClient.CreateIfNotExistsAsync();

                var blobClient = containerClient.GetBlobClient(Guid.NewGuid() + Path.GetExtension(file.FileName));
                using (var stream = file.OpenReadStream())
                {
                    await blobClient.UploadAsync(stream, overwrite: true);
                }

                return blobClient.Uri.ToString();
            }
        }

    
}
