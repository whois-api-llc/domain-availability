$domain = "google.com"
$key = "Your domain availability api api_key"
$secret = "Your domain availability api secret_key"
$username = "Your domain availability api username"

$time = [DateTimeOffset]::Now.ToUnixTimeMilliseconds()
$req=[Text.Encoding]::UTF8.GetBytes("{`"t`":$($time),`"u`":`"$($username)`"}")
$req = [Convert]::ToBase64String($req)

$data = $username + $time + $key
$hmac = New-Object System.Security.Cryptography.HMACMD5
$hmac.key = [Text.Encoding]::UTF8.GetBytes($secret)
$hash = $hmac.ComputeHash([Text.Encoding]::UTF8.GetBytes($data))
$digest = [BitConverter]::ToString($hash).Replace('-','').ToLower()

$uri = "https://www.whoisxmlapi.com/whoisserver/WhoisService?"`
     + "cmd=GET_DN_AVAILABILITY&requestObject=$($req)&digest=$($digest)&domainName=$($domain)"

echo (Invoke-WebRequest -Uri $uri).Content