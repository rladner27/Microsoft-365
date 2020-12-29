## Script by Alex Fields, ITProMentor.com
## Description:
## This script can be used to help configure DKIM for Office 365
## Use: .\Setup-DKIM.ps1 -DomainName "yourdomainhere.com"
## If you do not specify the DomainName variable, the script will prompt you for it
## Prerequisites:
## The tenant will require any Exchange Online plan
## Connect to Exchange Online via PowerShell using MFA:
## https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps
## WARNING: Script provided as-is. Author is not responsible for its use and application. Use at your own risk.

Param(
$DomainName
)

$MessageColor = "cyan"

if ($null -eq $DomainName -or $DomainName -eq "") {
    $DomainName = Read-Host -Prompt "Please specify the domain name"
    Write-Host
}

## This line will return the CNAME record values for the specified domain name (Points to):
Write-Host -ForegroundColor $MessageColor "Enter the (Points to) CNAME values in DNS for $($DomainName):"
Write-Host

$values = Get-DkimSigningConfig $DomainName | Select-Object Domain, *cname
$table = @{
    'selector1._domainkey' = $values.Selector1CNAME
    'selector2._domainkey' = $values.Selector2CNAME
}
$table | ForEach-Object {$_} | Format-Table @{n='Host'; e={$_.Key}}, @{n='Points to'; e={$_.Value}}

## Pause the script to allow time for entering DKIM records
Read-Host -Prompt "Enter the DKIM records, have a coffee and wait several minutes while DNS propogates, and then press Enter to continue..."
## This line will attempt to activate the DKIM service (CNAME records must be already be populated in DNS)

## If DKIM exists but not already enabled, enable it
if (((Get-DkimSigningConfig -Identity $DomainName -ErrorAction SilentlyContinue).enabled) -eq $false) {
    Set-DkimSigningConfig -Identity $DomainName -Enabled $true
}
## If it doesn't exist - create new config
if (!(Get-DkimSigningConfig -Identity $DomainName -ErrorAction SilentlyContinue)) {
    New-DkimSigningConfig -DomainName $DomainName -Enabled $true
}
## End of script