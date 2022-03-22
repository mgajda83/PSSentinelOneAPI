Function New-PSSentinelOneApiRequest
{
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
		[String]$Body,
		[Parameter()]
		[Hashtable]$Filter
	)

    #Buduj parametryzacje dla GET'a
	Add-Type -AssemblyName System.Web
	$QueryString = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

	if($null -ne $Filter)
	{
		ForEach($Item in $Filter.GetEnumerator())
		{
			$QueryString.Add($Item.Name, $Item.Value)
		}
	}

	$UriRequest = [System.UriBuilder]$Uri
	$UriRequest.Query = $QueryString.ToString()

  	#Buduj naglowki
    if(!$Headers)
    {
        $Headers = @{}
        $Headers.Add("Authorization","ApiToken $ApiToken")
    }

	#Buduj request
	$Request = @{}
    $Request.Add("Method",$Method)
    $Request.Add("Headers",$Headers)
    $Request.Add("Uri",$UriRequest.Uri.OriginalString)
    Write-Verbose $UriRequest.Uri.OriginalString

    if($Body)
    {
        $Request.Add("Body",$Body)
        $Request.Add("ContentType", "application/json")
    }

    return $Request
}