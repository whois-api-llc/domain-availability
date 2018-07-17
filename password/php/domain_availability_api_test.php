<?php

$username = 'Your domain availability api username';
$password = 'Your domain availability api password';
$domain = 'google.com';

$url = 'https://www.whoisxmlapi.com/whoisserver/WhoisService'
     . '?cmd=GET_DN_AVAILABILITY'
     . '&domainName=' . urlencode($domain)
     . '&username=' . urlencode($username)
     . '&password=' . urlencode($password)
     . '&outputFormat=JSON';

$contents = file_get_contents($url);

$res = json_decode($contents);

if ($res) {
    if (isset($res->ErrorMessage)) {
        echo $res->ErrorMessage->msg;
    }  
    else {
        $domainInfo = $res->DomainInfo;
        if ($domainInfo) {
            echo 'Domain name: ' .print_r($domainInfo->domainName,1) .PHP_EOL;
            echo 'Domain Availability: '
                 . print_r($domainInfo->domainAvailability, 1) . PHP_EOL;
        }
    }
}