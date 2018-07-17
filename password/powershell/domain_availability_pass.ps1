$url = 'https://www.whoisxmlapi.com/whoisserver/WhoisService'

$username = 'Your domain availability api username'
$password = 'Your domain availability api password'
$domain = 'whoisxmlapi.com'
$format = 'json'

$uri = $url`
     + '?cmd=GET_DN_AVAILABILITY'`
     + '&domainName=' + [uri]::EscapeDataString($domain)`
     + '&username=' + [uri]::EscapeDataString($username)`
     + '&password=' + [uri]::EscapeDataString($password)`
     + '&outputFormat=' + [uri]::EscapeDataString($format)

$j = Invoke-WebRequest -Uri $uri -UseBasicParsing | `
     ConvertFrom-Json

if ([bool]($j.PSObject.Properties.name -match 'DomainInfo')) {
    echo "Domain name: $($j.DomainInfo.domainName)"
    echo "Domain availability: $($j.DomainInfo.domainAvailability)"
} else {
    echo $j
}