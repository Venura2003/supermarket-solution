$header = '{"alg":"HS256","typ":"JWT"}'
$now = [int][DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
$exp = $now + 3600
$payload = @{
    iss='SupermarketAPI'
    aud='SupermarketAPIUsers'
    exp=$exp
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'='9999'
    'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'='cashier@gmail.com'
    'http://schemas.microsoft.com/ws/2008/06/identity/claims/role'='Employee'
} | ConvertTo-Json -Compress
function B64UrlEncode([string]$s) {
    $b = [System.Text.Encoding]::UTF8.GetBytes($s)
    $t = [Convert]::ToBase64String($b)
    $t = $t.TrimEnd('=')
    $t = $t.Replace('+','-').Replace('/','_')
    return $t
}
$unsigned = (B64UrlEncode $header) + '.' + (B64UrlEncode $payload)
$secret = 'SupermarketAPI-SecureKey-Change-This-In-Production-MinimumLength32'
$hmac = [System.Security.Cryptography.HMACSHA256]::new([System.Text.Encoding]::UTF8.GetBytes($secret))
$sig = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($unsigned))
$sigb = [Convert]::ToBase64String($sig).TrimEnd('=')
$sigb = $sigb.Replace('+','-').Replace('/','_')
$token = $unsigned + '.' + $sigb
Write-Output $token
