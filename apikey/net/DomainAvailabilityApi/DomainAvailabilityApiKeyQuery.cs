using System;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;

using Newtonsoft.Json;

/*
 * Target platform: .Net Framework 4.0
 * 
 * You need to install Newtonsoft JSON.NET
 *
 */

namespace DomainAvailabilityApi
{
    public static class DomainAvailabilityApiKeyQuery
    {
        private static void Main()
        {
            const string username = "Your domain availability api username";
            const string apiKey = "Your domain availability api key";
            const string secretKey ="Your domain availability api secret key";

            const string url =
                "https://whoisxmlapi.com/whoisserver/WhoisService";

            string[] domains =
            {
                "google.com",
                "example.com",
                "whoisxmlapi.com",
                "twitter.com"
            };

            ApiSample.PerformRequest(username, apiKey, secretKey,url,domains);
        }
    }

    public static class ApiSample
    {
        public static void PerformRequest(
            string username,
            string apiKey,
            string secretKey,
            string url,
            string[] domains
        )
        {
            var timestamp = GetTimeStamp();
            
            var digest = GenerateDigest(username, apiKey,secretKey,timestamp);

            foreach (var domain in domains)
            {
                try
                {
                    var request = BuildRequest(
                                    username, timestamp, digest, domain);

                    var response = GetAvailabilityData(url + request);

                    if (response.Contains("Request timeout"))
                    {
                        timestamp = GetTimeStamp();

                        digest = GenerateDigest(
                            username, apiKey, secretKey, timestamp);

                        request = BuildRequest(
                            username, timestamp, digest, domain);

                        response = GetAvailabilityData(url + request);
                    }

                    PrintResponse(response);
                }
                catch (Exception)
                {
                    Console.WriteLine(
                       "Error occurred\r\nCannot get whois data for "+domain);
                }
            }

            Console.WriteLine("Press any key to continue...");
            Console.ReadLine();
        }

        private static string GenerateDigest(
            string username,
            string apiKey,
            string secretKey,
            long timestamp
        )
        {
            var data = username + timestamp + apiKey;
            var hmac = new HMACMD5(Encoding.UTF8.GetBytes(secretKey));
            
            var hex = BitConverter.ToString(
                        hmac.ComputeHash(Encoding.UTF8.GetBytes(data)));
            
            return hex.Replace("-", "").ToLower();
        }

        private static string BuildRequest(
            string username,
            long timestamp,
            string digest,
            string domain
        )
        {
            var ud = new UserData
            {
                u = username,
                t = timestamp
            };

            var userData = JsonConvert.SerializeObject(ud,Formatting.None);
            var userDataBytes = Encoding.UTF8.GetBytes(userData);

            var userDataBase64 = Convert.ToBase64String(userDataBytes);

            var requestString = new StringBuilder();
            requestString.Append("?cmd=GET_DN_AVAILABILITY");
            requestString.Append("&requestObject=");
            requestString.Append(Uri.EscapeDataString(userDataBase64));
            requestString.Append("&digest=");
            requestString.Append(Uri.EscapeDataString(digest));
            requestString.Append("&domainName=");
            requestString.Append(Uri.EscapeDataString(domain));
            requestString.Append("&outputFormat=json");

            return requestString.ToString();
        }

        private static string GetAvailabilityData(string url)
        {
            var response = "";

            try
            {
                var wr = WebRequest.Create(url);
                var wp = wr.GetResponse();

                using (var data = wp.GetResponseStream())
                {

                    if (data == null)
                        return response;

                    using (var reader = new StreamReader(data))
                    {
                        response = reader.ReadToEnd();
                    }
                }
                wp.Close();
            }
            catch (Exception e)
            {
                Console.WriteLine(e.Message);
                throw new Exception(e.Message);
            }

            return response;
        }

        private static void PrintResponse(string response)
        {
            dynamic responseObject = JsonConvert.DeserializeObject(response);

            if (responseObject.DomainInfo!= null)
            {
                var daRecord = responseObject.DomainInfo;

                if (daRecord.domainName != null)
                {
                    Console.WriteLine(
                        "Domain name: " + daRecord.domainName.ToString());
                }
                if (daRecord.domainAvailability != null)
                {
                    Console.WriteLine(
                        "Domain availability: "
                        + daRecord.domainAvailability.ToString());
                }
                Console.WriteLine("--------------------------------");

                return;
            }

            Console.WriteLine(response);
        }

        private static long GetTimeStamp()
        {
            return (long)(DateTime.UtcNow.Subtract(new DateTime(1970, 1, 1))
                                         .TotalMilliseconds);
        }
    }

    internal class UserData
    {
        public string u { get; set; }
        public long t { get; set; }
    }
}