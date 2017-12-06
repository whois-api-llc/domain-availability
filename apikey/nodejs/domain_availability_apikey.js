const https = require('https');
const queryString = require('querystring');
const crypto = require('crypto');

const url = 'https://whoisxmlapi.com/whoisserver/WhoisService?';
const username = 'Your domain availability api username';
const apiKey = 'Your domain availability api api_key';
const secretKey = 'Your domain availability api secret_key';

const domains = [
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com'
];

for(var i in domains) {
    getWhois(username, apiKey, secretKey, domains[i]);
}

function getWhois(username, apiKey, secretKey, domain)
{
    timestamp = (new Date).getTime();
    digest = generateDigest(username, timestamp, apiKey, secretKey);
    var requestString = buildRequest(username, timestamp, digest, domain);
    https.get(url + requestString, function (res) {
        const statusCode = res.statusCode;

        if (statusCode !== 200) {
            console.log('Request failed: '
                + statusCode
            );
        }

        var rawData = '';

        res.on('data', function(chunk) {
            rawData += chunk;
        });

        res.on('end', function () {
            printResponse(rawData);
        })
    }).on('error', function(e) {
        console.log("Error: " + e.message);
    });

}

function generateDigest(username, timestamp, apiKey, secretKey) {
    var data = username + timestamp + apiKey;
    var hmac = crypto.createHmac('md5', secretKey);
    hmac.update(data);
    return hmac.digest('hex');
}

function buildRequest(username, timestamp, digest, domain) {
    var data = {
        u: username,
        t: timestamp
    };

    var dataJson = JSON.stringify(data);
    var dataBase64 = Buffer.from(dataJson).toString('base64');

    var request = {
        requestObject: dataBase64,
        cmd: 'GET_DN_AVAILABILITY',
        digest: digest,
        domainName: domain,
        outputFormat: 'json'
    };

    return queryString.stringify(request);
}

function printResponse(responseRaw) {
    response = JSON.parse(responseRaw);
    if (response.DomainInfo) {
        output = 'Domain name: ';
        output += response.DomainInfo.domainName;
        output += "\n";
        output += 'Domain availability: ';
        output += response.DomainInfo.domainAvailability;
        output += "\n";
        console.log(output);
    } else {
        console.log(response);
    }
}