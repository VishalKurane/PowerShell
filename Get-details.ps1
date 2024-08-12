# Initialize and start the stopwatch to measure total execution time
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# Provide the FQDNs in a seperate FQDN_inputs.txt file as input
$ssls= Get-Content 'E:\DevOps\GitHub-Repositories\PowerShell\Input.txt'

New-Item -ItemType File -Path "E:\DevOps\GitHub-Repositories\PowerShell\SSL-Report.csv"

$Report = @("CNAME","Expiry Date","Issued Date","Resource Name","Ip Address", "SAN Count","SAN List","Serial Number","Thumb Print","Issuer Name")
$Report=$Report-join ";"
$Report | Format-Table | out-file E:\DevOps\GitHub-Repositories\PowerShell\SSL-Report.csv -Append

foreach ($ssl in  $ssls) {

    Write-host "Collecting Data for Hostname: $ssl" -BackgroundColor Yellow

    # Run OpenSSL command and capture the Data for respective FQDN
    $command = 'openssl s_client -connect ' + $ssl + ':443 -servername ' + $ssl + ' | openssl x509 -noout -dates -serial -fingerprint -issuer -text'
    $output = Invoke-Expression $command

    $notBefore = ($output | Select-String -Pattern "notBefore=(.+)").Matches.Groups[1].Value
    $notAfter = ($output | Select-String -Pattern "notAfter=(.+)").Matches.Groups[1].Value
    $serial = ($output | Select-String -Pattern "serial=(.+)").Matches.Groups[1].Value
    $fingerprint = ($output | Select-String -Pattern "SHA1 Fingerprint=(.+)").Matches.Groups[1].Value
    $issuer = ($output | Select-String -Pattern "issuer=.+, CN = (.+)").Matches.Groups[1].Value

    #Format the Dates
    $notBefore = $notBefore -replace "  ", " "
    $notAfter = $notAfter -replace "  ", " "

    $notBefore = [DateTime]::ParseExact($notBefore, "MMM d HH:mm:ss yyyy 'GMT'", $null).ToString("dd MMM yyyy")
    $notAfter = [DateTime]::ParseExact($notAfter, "MMM d HH:mm:ss yyyy 'GMT'", $null).ToString("dd MMM yyyy")

    #Format the Thumbprint
    $fingerprint = $fingerprint -replace ":"

    # Getting SAN list
    $SANListcommand = $output | findstr "DNS:"

    # Extract SAN list from the output
    $sanList = $SANListcommand -replace 'DNS:', '' | ForEach-Object { $_.Trim() }

    # Count the number of SANs
    $SanCount =($sanlist -split ',').Count

    # Resolve the CNAME record for the domain
    $record = Resolve-DnsName -Name $ssl -Type CNAME

    # Check if a CNAME record was found
    if ($record) {
        $canonicalName = $record.NameHost
        $resourceName = $canonicalName.Split('.')[0]
    } else {
        Write-host "No CNAME record found for $ssl" -BackgroundColor Red
    }
    
    # Resolve the IP Address for the domain
    $iprecord = Resolve-DnsName -Name $ssl -Type A
    $ipAddress = $ipRecord.IPAddress

    $newList = @("$ssl","$notAfter","$notBefore","$resourceName","$ipAddress","$SanCount","$sanList","$serial","$fingerprint","$issuer")
    $newList=$newList -join ";"
    $newList | Format-Table | out-file E:\DevOps\GitHub-Repositories\PowerShell\SSL-Report.csv -Append

    Write-host "Collected Data for Hostname: $ssl" -BackgroundColor Green

    $ssl = $null
    $notAfter = $null
    $notBefore = $null
    $resourceName = $null
    $ipAddress = $null
    $SanCount = $null
    $sanList = $null
    $serial = $null
    $fingerprint = $null
    $issuer = $null

}

# Stop the stopwatch and format the total execution time
$stopwatch.Stop()
$elapsed = $stopwatch.Elapsed
$formattedTime = "{0:D2}:{1:D2}.{2:D3}" -f $elapsed.Minutes, $elapsed.Seconds, $elapsed.Milliseconds
Write-Host "Total execution time: $formattedTime"