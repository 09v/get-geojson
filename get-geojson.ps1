Param (
    # Set country code (ISO 316601 alpha-2).
    # Refere to https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 .
    # This script GET https://raw.githubusercontent.com/olahol/iso-3166-2.js/master/data.csv .
    [parameter(Mandatory=$True)]
    [alias("c")]
    [string]$CountryCode,

    [alias("o")]
    [string]$OutputDir = "_dump",

    # This is switch flag. If set, you DO NOT download geojson.
    [alias("d")]
    [switch]$DryRunFlag
)

# ------------------------------------------------------------------------------
# NOTE: download iso-3166-2.csv if not exist in current directory.
function Get-CountryCodeData {
    $countryCodeFile = $OutputDir + "/iso-3166-2.csv"
    $targetUri = "https://raw.githubusercontent.com/olahol/iso-3166-2.js/master/data.csv"
    if (Test-Path $countryCodeFile) {
        Write-Host "[Download] ** skip ** $countryCodeFile (already downloaded)"
    } else {
        Write-Host "[Download] $targetUri"
        Invoke-WebRequest -Uri $targetUri -OutFile $countryCodeFile
    }
    $data = Import-Csv $countryCodeFile -Header "CountryName","Code","Name","Type","CountryCode"
    # Write-Host $data
    return $data
}

# ------------------------------------------------------------------------------
function Get-TargetSubdivisionData([string]$country_code) {
    $targetData = Get-CountryCodeData | Where-Object {
        $_.CountryCode -eq $country_code
    } | Select-Object Code, Name, CountryCode, CountryName
    return $targetData
}

# ------------------------------------------------------------------------------
# $target_subdiv_data は Code (Subdivision Code), Name, CountryCode, CountryName の入ったオブジェクトの配列
function Download-Geojson($target_subdiv_data) {
    $count = $target_subdiv_data.Count
    for ($i = 0; $i -lt $count; $i++) {
        $target = $target_subdiv_data[$i]
        Write-Host "`n==== [$($i+1)/$count] $($target.Code) ($($target.Name)) @ $($target.CountryName) ===="
        $output = "$OutputDir/$($target.Code).geojson"
        $uri="https://nominatim.openstreetmap.org/search?state=$($target.Name)&country=$($target.CountryCode)&polygon_geojson=1&format=geojson"
        if ($DryRunFlag) {
            Write-Host "[DRY RUN] $uri`n=> $output"
        } elseif (Test-Path $output) {
            $size = (Get-item $output).Length
            Write-Host "[SKIP] (already exist)`n=> $output ($size byte)"
        } else {
            # 1st try [state=xxxx&country=YY]
            Write-Host "[GET] 1st try: $uri"
            Invoke-WebRequest -Uri $uri -OutFile $output
            # **Requirements** https://operations.osmfoundation.org/policies/nominatim/
            # No heavy uses (an absolute maximum of 1 request per second).
            Sleep 2
            $tmp = Get-Content $output -Encoding UTF8 -Raw | ConvertFrom-Json
            if ($tmp.features) {
                $size = (Get-item $output).Length
                Write-Host "=> $output ($size byte)"
                continue
            }

            # 2nd try
            $uri="https://nominatim.openstreetmap.org/search?q=$($target.Name)+$($target.CountryCode)&polygon_geojson=1&format=geojson"
            Write-Host "[GET] 2nd try: $uri"
            Invoke-WebRequest -Uri $uri -OutFile $output
            $size = (Get-item $output).Length
            Write-Host "=> $output ($size byte)"
            Sleep 2
        }
    }
}

# ==============================================================================
function Main {
    $CountryCodeUppered = $CountryCode.ToUpper()
    Write-Host "[CountryCode]        $CountryCode"
    Write-Host "[CountryCodeUppered] $CountryCodeUppered"
    Write-Host "[DryRunFlag]         $DryRunFlag"
    if (!(Test-Path $OutputDir -PathType Container)) {
        Write-Host "[mkdir] $OutputDir"
        New-Item $OutputDir -ItemType Directory | Out-Null
    }

    $targetSubdivisionData = Get-TargetSubdivisionData($CountryCodeUppered)
    if ($targetSubdivisionData.Count -eq 0) {
        Write-Error "[ERROR] CountryCode (-c `"$CountryCode`") not found..."
        exit 1
    }

    Download-Geojson($targetSubdivisionData)
}

Main
