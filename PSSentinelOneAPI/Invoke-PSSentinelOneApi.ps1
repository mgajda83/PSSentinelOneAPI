Function Invoke-PSSentinelOneApi
{
    [CmdletBinding()]
	param 
	(
		[Parameter(Mandatory = $true)]
		[Hashtable]$Request,
		[Parameter()]
		[Switch]$Silent
	)

    $Response = Invoke-RestMethod @Request

    $Data = @()
    $Data += $Response.data
    $Counter = $Data.Count
    $Total = $Response.pagination.totalItems

	#Paginacja
    While($Data.Count -lt $Total)
    {
        if($null -eq $Silent)
        {
            Write-Progress -Activity "Przetwarzanie danych" -status "$Counter / $Total" -percentcomplete $([Int](($Counter/$Total)*100))
        }

        $Request = New-PSSentinelOneApiRequest -Uri $Request.Uri -Method GET -Headers $Request.Headers -Filter @{"cursor"=$Response.pagination.nextCursor}

        $Response = Invoke-RestMethod @Request
        $Data += $Response.data
        $Counter = $Data.Count
    }

	return $Data
}