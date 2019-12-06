using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Microsoft.Extensions.Configuration;
using System.Runtime.InteropServices.ComTypes;

namespace ReadIperf
{
   public class AppSettings
    {
        public string workspaceId { get; set; }
        public string sharedKey { get; set; }
    }
    class Program
    {
        static AppSettings appSettings = new AppSettings();
        static int Main(string[] args)
        {
            //configuration builder
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
            var configuration = builder.Build();
            ConfigurationBinder.Bind(configuration.GetSection("AppSettings"), appSettings);


            if (args.Length == 0)
            {
                Console.WriteLine("Please include a path to the log output for iperf");
                Console.WriteLine("Windows Usage: ReadIperf c:\\temp\\iperf.log");
                Console.WriteLine("Linux Usage: ReadIperf /opt/iperf.log");
                return 1;
            }
            if(File.Exists(args[0]) != true)
            {
                Console.WriteLine("Log file does not exist please check location");
                return 1;
            }
            Console.WriteLine("Log File Exists!");
            string json = File.ReadAllText(args[0]);
                     
            AzureLogAnalytics logAnalytics = new AzureLogAnalytics(
          workspaceId: appSettings.workspaceId,
           sharedKey: appSettings.sharedKey,
          logType: "ApplicationLog");
            logAnalytics.Post(json);
            return 0;
           
        }
        
    }
    public class AzureLogAnalytics
    {
        public String WorkspaceId { get; set; }
        public String SharedKey { get; set; }
        public String ApiVersion { get; set; }
        public String LogType { get; set; }
        public AzureLogAnalytics(String workspaceId, String sharedKey, String logType, String apiVersion = "2016-04-01")
        {
            this.WorkspaceId = workspaceId;
            this.SharedKey = sharedKey;
            this.LogType = logType;
            this.ApiVersion = apiVersion;
        }
        public void Post(string json)
        {
            string requestUriString = $"https://{WorkspaceId}.ods.opinsights.azure.com/api/logs?api-version={ApiVersion}";
            DateTime dateTime = DateTime.UtcNow;
            string dateString = dateTime.ToString("r");
            string signature = GetSignature("POST", json.Length, "application/json", dateString, "/api/logs");
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(requestUriString);
            request.ContentType = "application/json";
            request.Method = "POST";
            request.Headers["Log-Type"] = LogType;
            request.Headers["x-ms-date"] = dateString;
            request.Headers["Authorization"] = signature;
            byte[] content = Encoding.UTF8.GetBytes(json);
            using (Stream requestStreamAsync = request.GetRequestStream())
            {
                requestStreamAsync.Write(content, 0, content.Length);
            }
            using (HttpWebResponse responseAsync = (HttpWebResponse)request.GetResponse())
            {
                Console.WriteLine("HTTP Response Code: {0}", responseAsync.StatusCode);
                if (responseAsync.StatusCode != HttpStatusCode.OK && responseAsync.StatusCode != HttpStatusCode.Accepted)
                {
                    Stream responseStream = responseAsync.GetResponseStream();
                    if (responseStream != null)
                    {
                        using (StreamReader streamReader = new StreamReader(responseStream))
                        {
                            throw new Exception(streamReader.ReadToEnd());
                        }
                    }
                }
            }
        }

        private string GetSignature(string method, int contentLength, string contentType, string date, string resource)
        {
            string message = $"{method}\n{contentLength}\n{contentType}\nx-ms-date:{date}\n{resource}";
            byte[] bytes = Encoding.UTF8.GetBytes(message);
            using (HMACSHA256 encryptor = new HMACSHA256(Convert.FromBase64String(SharedKey)))
            {
                return $"SharedKey {WorkspaceId}:{Convert.ToBase64String(encryptor.ComputeHash(bytes))}";
            }
        }

    }
}
