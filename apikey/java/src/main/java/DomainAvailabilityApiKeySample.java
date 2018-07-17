import java.net.URLEncoder;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.codec.binary.Hex;
import org.apache.commons.httpclient.HttpClient;
import org.apache.commons.httpclient.HttpMethod;
import org.apache.commons.httpclient.methods.GetMethod;
import org.json.JSONException;
import org.json.JSONObject;

public class DomainAvailabilityApiKeySample
{
    private Logger logger =
        Logger.getLogger(DomainAvailabilityApiKeySample.class.getName());

    public static void main(String[]args)
    {
        new DomainAvailabilityApiKeySample().getSimpleDomainUsingApiKey();
    }

    private void getSimpleDomainUsingApiKey()
    {
        String domainName = "google.com";

        String username = "Your domain availability api username";
        String apiKey = "Your domain availability api key";
        String secretKey = "Your domain availability api secret key";

        getDomainNameUsingApiKey(domainName, username, apiKey, secretKey);
    }

    private String executeURL(String url)
    {
        HttpClient c = new HttpClient();
        System.out.println(url);
        HttpMethod m = new GetMethod(url);
        String res = null;

        try {
            c.executeMethod(m);
            res = new String(m.getResponseBody());
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Cannot get url", e);
        } finally {
            m.releaseConnection();
        }

        return res;
    }

    public void getDomainNameUsingApiKey(
        String domainName,
        String username,
        String apiKey,
        String secretKey
    )
    {
        String apiKeyAuthenticationRequest =
            generateApiKeyAuthenticationRequest(username, apiKey, secretKey);

        if (apiKeyAuthenticationRequest == null) {
            return;
        }

        String domName = "";
        try {
            domName = URLEncoder.encode(domainName, "UTF-8");
        } catch (Exception e) {
            logger.log(Level.SEVERE, "an error occurred", e);
        }

        String url = "https://www.whoisxmlapi.com/whoisserver/WhoisService?"
                   + apiKeyAuthenticationRequest
                   + "&cmd=GET_DN_AVAILABILITY"
                   + "&domainName=" + domName;

        String result = executeURL(url);
        if (result != null) {
            logger.log(Level.INFO, "result: " + result);
        }
    }

    private String generateApiKeyAuthenticationRequest(
        String username,
        String apiKey,
        String secretKey
    )
    {
        try {
            long timestamp = System.currentTimeMillis();

            String request = generateRequest(username, timestamp);
            String digest =
                generateDigest(username, apiKey, secretKey, timestamp);

            String requestURL = URLEncoder.encode(request, "UTF-8");
            String digestURL = URLEncoder.encode(digest, "UTF-8");

            return "requestObject=" + requestURL + "&digest=" + digestURL;
        } catch (Exception e) {
            logger.log(Level.SEVERE, "an error occurred", e);
        }
        return null;
    }

    private String generateRequest(String username, long timestamp)
        throws JSONException
    {
        JSONObject json = new JSONObject();
        json.put("u", username);
        json.put("t", timestamp);
        String jsonStr = json.toString();
        byte[] json64 = Base64.encodeBase64(jsonStr.getBytes());

        return new String(json64);
    }

    private String generateDigest(
        String username,
        String apiKey,
        String secretKey,
        long timestamp
    )
        throws Exception
    {
        String sb = username + timestamp + apiKey;

        SecretKeySpec secretKeySpec =
            new SecretKeySpec(secretKey.getBytes("UTF-8"), "HmacMD5");

        Mac mac = Mac.getInstance(secretKeySpec.getAlgorithm());
        mac.init(secretKeySpec);

        byte[] digestBytes = mac.doFinal(sb.getBytes("UTF-8"));

        return new String(Hex.encodeHex(digestBytes));
    }
}