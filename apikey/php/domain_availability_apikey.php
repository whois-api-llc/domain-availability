<?php

$username = 'Your domain availability api username';
$apiKey = 'Your domain availability api key';
$secret = 'Your domain availability api secret key';

$url = 'https://whoisxmlapi.com/whoisserver/WhoisService';

$domains = array(
    'google.com',
    'example.com',
    'whoisxmlapi.com',
    'twitter.com',
);

$timestamp = null;
$digest = null;

generateParameters($timestamp, $digest, $username, $apiKey, $secret);

foreach ($domains as $domain) {
    $response = request($url, $username, $timestamp, $digest, $domain);

    if (strpos($response, 'Request timeout') !== false) {
        generateParameters($timestamp, $digest, $username, $apiKey, $secret);
        $response = request($url, $username, $timestamp, $digest, $domain);
    }

    printResponse($response);
    echo '----------------------------' . PHP_EOL;
}

function generateParameters(&$timestamp, &$digest, $username, $apiKey,$secret)
{
    $timestamp = round(microtime(true) * 1000);
    $digest = generateDigest($username, $timestamp, $apiKey, $secret);
}

function request($url, $username, $timestamp, $digest, $domain)
{
    $requestString = buildRequest($username, $timestamp, $digest, $domain);
    return file_get_contents($url . $requestString);
}

function printResponse($response)
{
    $responseArray = json_decode($response, true);

    if (!empty($responseArray['DomainInfo']['domainName'])) {
        echo 'Domain name: '
             . $responseArray['DomainInfo']['domainName']
             . PHP_EOL;
    }
    if (!empty($responseArray['DomainInfo']['domainAvailability'])) {
        echo 'Domain availability: '
            . $responseArray['DomainInfo']['domainAvailability']
            . PHP_EOL;
    }
}

function generateDigest($username, $timestamp, $apiKey, $secretKey)
{
    $digest = $username . $timestamp . $apiKey;
    $hash = hash_hmac('md5', $digest, $secretKey);

    return urlencode($hash);
}

function buildRequest($username, $timestamp, $digest, $domain)
{
    $requestString = '?requestObject=';

    $request = array(
        'u' => $username,
        't' => $timestamp
    );

    $requestJson = json_encode($request);
    $requestBase64 = urlencode(base64_encode($requestJson));

    $requestString .= urlencode($requestBase64);
    $requestString .= '&cmd=GET_DN_AVAILABILITY';
    $requestString .= '&digest=' . $digest;
    $requestString .= '&domainName=' . urlencode($domain);
    $requestString .= '&outputFormat=json';

    return $requestString;
}