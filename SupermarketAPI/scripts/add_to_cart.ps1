$token = & "${PSScriptRoot}\gen_jwt.ps1"
$body = @{ productId = 10; quantity = 1 } | ConvertTo-Json
$headers = @{ Authorization = "Bearer $token" }
try {
	$resp = Invoke-RestMethod -Uri 'http://localhost:5000/api/cart/add' -Method Post -Body $body -Headers $headers -ContentType 'application/json'
	$resp | ConvertTo-Json -Compress
}
catch {
	$err = $_.Exception.Response
	if ($err -ne $null) {
		$reader = New-Object System.IO.StreamReader($err.GetResponseStream())
		$reader.ReadToEnd() | Write-Output
	} else {
		$_ | Write-Output
	}
}
