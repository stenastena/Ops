#Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
#Connect-AzAccount -TenantId af353fcf-5951-4079-bfae-72ce6172733e
#Select-AzSubscription -SubscriptionID f5b5d7b3-27e6-47ba-83c1-58824d3eb42b 

# Choose the Azure Firewall for West Europe workloads
$azFw=Get-AzFirewall -Name "*wall2*"

Write-Host "Before adding a network rule collection" -ForegroundColor Green

#Reading firewall network rules
$azFw.NetworkRuleCollections.Rules | Format-Table

#Headers for com-matrix
#Time slot,Source server name,Source IP,Source application,Source process,Destination server name,Destination IP,Destination application,Destination process,Destination port

#Import communication matrix for target server
##$Com-matrix = Import-Csv -Path .\Com-matrix.csv
##$OldIP = "10.100.240.175"

<#
$networkrule = New-AzFirewallNetworkRule -Name "AllowOutboundRule33" -SourceAddress "*" -DestinationAddress "*" -DestinationPort 345 -Protocol "TCP"
$networkrulecollection = New-AzFirewallNetworkRuleCollection -Name "MyWorkload" -Rule $networkrule -Priority 2020 -ActionType "Allow"
$azFw.AddNetworkRuleCollection($networkrulecollection)


#$netRule = New-AzFirewallNetworkRule -Name "all-udp-traffic" -Description "Rule for all UDP traffic" -Protocol "UDP" -SourceAddress "*" -DestinationAddress "*" -DestinationPort "*"
#$netRuleCollection = New-AzFirewallNetworkRuleCollection -Name "MyNetworkRuleCollection" -Priority 100 -Rule $netRule -ActionType "Allow"
#$azFw.AddNetworkRuleCollection($netRuleCollection)

#$NetRule1 = New-AzFirewallNetworkRule -Name "Allow-DNS" -Protocol UDP -SourceAddress 10.0.2.0/24 `
#   -DestinationAddress 209.244.0.3,209.244.0.4 -DestinationPort 53
Write-Host "AFter adding a network rule collection" -ForegroundColor Yellow
$azFw.NetworkRuleCollections.Rules | Format-Table
#>