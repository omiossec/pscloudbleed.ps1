   <#
.SYNOPSIS 
    this script will extract domain from chrome and Ie history and test this domains to the cloudbleed domain list
.EXAMPLE
    .\pscloudbleed.ps1 [-username string]
    

.NOTES
    the cloudbleed domain list in provided. If you want the latest one simply delete the file sorted_unique_cf.txt file
    this script will download it again from pirate github 
    https://github.com/pirate/sites-using-cloudflare

    Author       : Olivier Miossec <olivier@omiossec.work>
#> 
    
     
    
    function get-cloudFlareTld
    {
        # this function download the cloudbleed domain list from github if it doesn't exist in the current directory
        # Please read https://github.com/pirate/sites-using-cloudflare 

        if (!(test-path -Path "sorted_unique_cf.txt"))
        {
                    
            $githubrawdata = "https://raw.githubusercontent.com/pirate/sites-using-cloudflare/master/sorted_unique_cf.txt"

            Invoke-WebRequest -Uri $githubrawdata -UseBasicParsing -OutFile sorted_unique_cf.txt

        }


    }



# this 2 functions is a modification of get-browserdata.ps1 from rvrsh3ll https://github.com/rvrsh3ll/Misc-Powershell-Scripts

    function Get-ChromeHistory {

        $chromeUrl = @()

       
      
        $Path = "$Env:systemdrive\Users\$UserName\AppData\Local\Google\Chrome\User Data\Default\History"
        if (-not (Test-Path -Path $Path)) {
            Write-Verbose "[!] Could not find Chrome History for username: $UserName"
        }
        $Regex = '(htt(p|s))://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'
        $Value = Get-Content -Path "$Env:systemdrive\Users\$UserName\AppData\Local\Google\Chrome\User Data\Default\History"|Select-String -AllMatches $regex |% {($_.Matches).Value} |Sort -Unique
        
        $Value | ForEach-Object {
            $Key = $_
            
            if ($Key -match $Search){

                
                $tmp =  ([System.Uri]$_).Host 
                $tmp = $tmp -replace '^www\.'

                $chromeUrl += $tmp
                

            }
        }      

        return   $chromeUrl
    }


    # this function is a modification of get-browserdata.ps1 from rvrsh3ll https://github.com/rvrsh3ll/Misc-Powershell-Scripts

    function Get-InternetExplorerHistory {
        #https://crucialsecurityblog.harris.com/2011/03/14/typedurls-part-1/
        $iEUrl = @()
        $Null = New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS
        $Paths = Get-ChildItem 'HKU:\' -ErrorAction SilentlyContinue | Where-Object { $_.Name -match 'S-1-5-21-[0-9]+-[0-9]+-[0-9]+-[0-9]+$' }

        ForEach($Path in $Paths) {

            $User = ([System.Security.Principal.SecurityIdentifier] $Path.PSChildName).Translate( [System.Security.Principal.NTAccount]) | Select-Object -ExpandProperty Value

            $Path = $Path | Select-Object -ExpandProperty PSPath

            $UserPath = "$Path\Software\Microsoft\Internet Explorer\TypedURLs"
            if (-not (Test-Path -Path $UserPath)) {
                Write-Verbose "[!] Could not find IE History for SID: $Path"
            }
            else {
                Get-Item -Path $UserPath -ErrorAction SilentlyContinue | ForEach-Object {
                    $Key = $_
                    $Key.GetValueNames() | ForEach-Object {
                        $Value = $Key.GetValue($_)
                        if ($Value -match $Search) {
                                $tmp =  ([System.Uri]$Value).Host 
                                $tmp = $tmp -replace '^www\.'
                                $IEUrl += $tmp
                            }
                        }
                    }
                }
            }

            return $iEUrl
        }
    


    if (!$UserName) {
        $UserName = "$ENV:USERNAME"
    }



# Get the full path of the domain file. NET Object do not work with relative path in powershell

$Path = split-path -parent $MyInvocation.MyCommand.Definition 
$Path += "\sorted_unique_cf.txt"




# create an  array with distinct value from chrome and Ie, it's an UNION 

$chromeUrl = Get-ChromeHistory
$ieUrl = get-InternetExplorerHistory

$VisitedUrl = Compare-Object $chromeUrl  $ieUrl  -IncludeEqual -PassThru

 
 if (!(test-path -Path "sorted_unique_cf.txt"))
        {
            get-cloudFlareTld
        }


$reader = [System.IO.File]::OpenText($path)
try {
    for() {
        $line = $reader.ReadLine() 
        if ($line -eq $null) { break }
        # process the line
         
        if ($VisitedUrl -contains $line)
        {
            Write-Host  $line
        }
    }
}
finally {
    $reader.Close()
}