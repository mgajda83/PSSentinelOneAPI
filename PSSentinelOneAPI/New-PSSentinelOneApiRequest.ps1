Function New-PSSentinelOneApiRequest
{
	<#
	.SYNOPSIS
		Create SentineOne API request.

	.PARAMETER ApiToken
		Authorization token.

	.PARAMETER Method
		Rest API method.

	.PARAMETER Uri
		API uri.

	.PARAMETER Headers
		Use own headers.

	.PARAMETER Body
		Hashtable or JSON body.

	.EXAMPLE
		$Body = @{
			filter = @{
				computerName = $ComputerName
				ids = @($ComputerId)
			}
		}

		$Params = @{
			Uri = "https://euce1-103.sentinelone.net/web/api/v2.1/agents/actions/decommission"
			Method = "POST"
			Body = ($Body | ConvertTo-Json)
			ApiToken = $ApiToken
		}
		$Request = New-PSSentinelOneApiRequest @Params

	.EXAMPLE
		$Body = @{
			tenant = $true
		}

		$Params = @{
			Uri = "https://euce1-103.sentinelone.net/web/api/v2.1/restrictions"
			Method = "GET"
			Body = $Body
			ApiToken = $ApiToken
		}
		$Request = New-PSSentinelOneApiRequest @Params

	.NOTES
		Author: Michal Gajda
	#>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true,ParameterSetName="ApiToken")]
		[String]$ApiToken,
		[Parameter(Mandatory = $true)]
		[ValidateSet("GET", "POST", "PUT", "DELETE")]
		[String]$Method,
		[Parameter(Mandatory = $true)]
		[String]$Uri,
		[Parameter(Mandatory = $true,ParameterSetName="Headers")]
		[Hashtable]$Headers,
		[Parameter()]
		$Body
	)

	#Load assembly System.Web
	Add-Type -AssemblyName System.Web

	$UriRequest = [System.UriBuilder]$Uri

  	#Build request headers
	if(!$Headers)
	{
		$Headers = @{}
		$Headers.Add("Authorization","ApiToken $ApiToken")
	}

	#Build core request
	$Request = @{}
	$Request.Add("Method",$Method)
	$Request.Add("Headers",$Headers)
	Write-Debug "Method: $Method"

	#Build request params
	if($Body)
	{
		if($Method -eq "GET")
		{
			#For GET method
			$QueryString = [System.Web.HttpUtility]::ParseQueryString($UriRequest.Query)

			ForEach($Item in $Body.GetEnumerator())
			{
				if($null -eq $QueryString[$Item.Name])
				{
					#Add new param
					$QueryString.Add($Item.Name, $Item.Value)
				} else {
					#Set overwrite exist param
					$QueryString.Set($Item.Name, $Item.Value)
				}
			}

			$UriRequest.Query = $QueryString.ToString()
			Write-Debug "Params: $($QueryString.ToString())"
		} else {
			#For non GET methods
			if($Body -is "Hashtable")
			{
				$Body = $Body | ConvertTo-Json
			}

			$Request.Add("Body",$Body)
			$Request.Add("ContentType", "application/json")
			Write-Debug "Params: $Body"
		}
	}
	
	#Build Uri
	$Request.Add("Uri",$UriRequest.Uri.OriginalString)
	Write-Verbose $UriRequest.Uri.OriginalString

	return $Request
}
