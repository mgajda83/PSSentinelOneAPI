Function Invoke-PSSentinelOneApi
{
	<#
	.SYNOPSIS
		Invoke SentineOne API request.

	.PARAMETER Request
		Request object.

	.PARAMETER Silent
		Witout Write-Progress

	.EXAMPLE
		$Request = New-PSSentinelOneApiRequest -Uri "https://euce1-103.sentinelone.net/web/api/v2.1/agents" -Method GET -ApiToken $ApiToken
		$Agents = Invoke-PSSentinelOneApi -Request $Request

	.NOTES
		Author: Michal Gajda
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[Hashtable]$Request,
		[Parameter()]
		[Switch]$Silent
	)

	Write-Verbose $Request.Uri
	$Response = Invoke-RestMethod @Request

	$Data = @()
	$Data += $Response.data
	$Counter = $Data.Count
	$Total = $Response.pagination.totalItems

	#Pagination
	While($Response.pagination.nextCursor)
	{
		if(!$Silent.IsPresent)
		{
			Write-Progress -Activity "Przetwarzanie danych" -status "$Counter / $Total" -percentcomplete $([Int](($Counter/$Total)*100))
		}

		$Request = New-PSSentinelOneApiRequest -Uri $Request.Uri -Method $Request.Method -Headers $Request.Headers -Body @{"cursor"=$Response.pagination.nextCursor}

		Write-Verbose $Request.Uri
		$Response = Invoke-RestMethod @Request
		$Data += $Response.data
		$Counter = $Data.Count

		write-host $Response.pagination.nextCursor
	}

	return $Data
}
