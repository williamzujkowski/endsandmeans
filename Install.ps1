
Function InstallSoftware()
{
 Install-WindowsUpdate -Full   
 
 Write-Ascii "Installing software.."
 
 choco upgrade volatility sysinternals rawcopy screentogif vscode markdownmonster googlechrome x64dbg.portable cmder Hashcheck nmap ida-free fiddler pester packer winscp processhacker yed pesieve baretail wireshark lessmsi putty notepadplusplus 7zip -y
   
     
}

function CompatibilityChecks()
 {
  
    # Check to make sure host is supported
    Write-Host "[+] Checking to make sure Operating System is compatible"
    if (-Not (([System.Environment]::OSVersion.Version.Major -eq 10)))
    {
        Write-Host  ""  
        Write-Host "`t[ERR] $((Get-WmiObject -class Win32_OperatingSystem).Caption) is not supported, please use Windows 10" -ForegroundColor Red
      exit 
    }
    else
    {
        Write-Host  ""
        Write-Host "`t$((Get-WmiObject -class Win32_OperatingSystem).Caption) supported" -ForegroundColor Green
    }

  
    #Check to make sure host has enough disk space
    Write-Host  ""
    Write-Host "[+] Checking if host has enough disk space"
    Write-Host  ""
    $disk = Get-PSDrive C
    Start-Sleep -Seconds 1
    if (-Not (($disk.used + $disk.free)/1GB -gt 58.8)){
      Write-Host "`t[ERR] This install requires a minimum 60 GB of free space, please increase disk space to continue`n" -ForegroundColor Red
      Read-Host "Press any key to continue"
      Write-Host  ""
      exit
    }
    else
    {
      Write-Host "`t> At least 60 GB of disk space detected, finding other reasons to flunk you .." -ForegroundColor Green
    }
}
  
    <# Prompt user to remind them to take a snapshot
    Write-Host  ""
    Write-Host "[-] Do you need to take a snapshot before continuing? Y/N " -ForegroundColor Yellow -NoNewline
    $response = Read-Host
    if ($response -ne "N") {
        Write-Host  ""
        Write-Host "[*] Kicking you out to make up for your lack of caution..." -ForegroundColor Red
      exit
    }
    Write-Host  ""
    Write-Host "Good job so far!" -ForegroundColor Green
    Write-Host  ""
  }

#>

function ConfigureRepos()
{
    <#
.SYNOPSIS
Trust repositories for installing modules with "install-package"
#>

Write-Host "Trusting PSGallery and installing Modules"
Write-Host  ""
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Write-Host "PSGallery Successfully Added."
}

function Dependencies()
{
Write-Host "Installing Modules.."
mkdir -p 'c:\temp' | Out-Null
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/williamzujkowski/Win10-Setup-Functions/master/Win10.psm1' -Outfile 'C:\temp\Win10.psm1'
   Write-Host "Trying to import Win10 Debloat after download"
   Import-Module 'C:\TEMP\Win10.psm1'
   Write-Host "  Win10 Debloat DOWNLOADED and installed"

Write-Host ""
Write-Host "The following modules are currently installed:"
Write-Host ""
Get-Module
Write-Host ""
}


function DEBLOAT()
{
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/williamzujkowski/commando-vm/master/commandovm.win10.preconfig.fireeye/tools/Default.preset'))
Write-Host ""
Write-Ascii " DEBLOAT Complete!!"
# $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

}

function InstallBoxstarter()
{
  <#
  .SYNOPSIS
  Install BoxStarter on the current system  
  .DESCRIPTION
  Install BoxStarter on the current system. Returns $true or $false to indicate success or failure. On
  fresh windows 7 systems, some root certificates are not installed and updated properly. Therefore,
  this funciton also temporarily trusts all certificates before installing BoxStarter.  
  #>  

  # https://stackoverflow.com/questions/11696944/powershell-v3-invoke-webrequest-https-error
  # Allows current PowerShell session to trust all certificates
  # Also a good find: https://www.briantist.com/errors/could-not-establish-trust-relationship-for-the-ssltls-secure-channel/

  try {
  Add-Type @"
  using System.Net;
  using System.Security.Cryptography.X509Certificates;
  public class TrustAllCertsPolicy : ICertificatePolicy {
  	public bool CheckValidationResult(
  		ServicePoint srvPoint, X509Certificate certificate,
  		WebRequest request, int certificateProblem) {
  		return true;
  	}
  }
"@
  } catch {
    Write-Debug "Failed to add new type"
  }  
  try {
  	$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
  } catch {
  	Write-Debug "Failed to find SSL type...1"
  }  
  try {
  	$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls'
  } catch {
  	Write-Debug "Failed to find SSL type...2"
  }  
  $prevSecProtocol = [System.Net.ServicePointManager]::SecurityProtocol
  $prevCertPolicy = [System.Net.ServicePointManager]::CertificatePolicy  
  Write-Host "[ * ] Installing Boxstarter"
  # Become overly trusting
  [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
  [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy  

  # Download and install latest Chocolatey
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  # Choco config prior to install
    choco feature enable -n allowGlobalConfirmation
    choco upgrade boxstarter
  # Download and install boxstarter
  #Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://boxstarter.org/bootstrapper.ps1'));
  #	C:\ProgramData\chocolatey\lib\boxstarter.chocolatey.2.12.0\tools\Boxstarter.Chocolatey 	 get-boxstarter -Force
  # Restore previous trust settings for this PowerShell session
  # Note: SSL certs trusted from installing BoxStarter above will be trusted for the remaining PS session
  [System.Net.ServicePointManager]::SecurityProtocol = $prevSecProtocol
  [System.Net.ServicePointManager]::CertificatePolicy = $prevCertPolicy
  return $true
}

function PowerSettings()
{
  # Tweak power options to prevent installs from timing out
  & powercfg -change -monitor-timeout-ac 0 | Out-Null
  & powercfg -change -monitor-timeout-dc 0 | Out-Null
  & powercfg -change -disk-timeout-ac 0 | Out-Null
  & powercfg -change -disk-timeout-dc 0 | Out-Null
  & powercfg -change -standby-timeout-ac 0 | Out-Null
  & powercfg -change -standby-timeout-dc 0 | Out-Null
  & powercfg -change -hibernate-timeout-ac 0 | Out-Null
  & powercfg -change -hibernate-timeout-dc 0 | Out-Null
}

# ---------------------------------------------
#
#   THIS IS THE BEGINNING OF THE WHOLE THING
#
#       REALLY THIS IS IT!!!
#----------------------------------------------

Write-Host "******Elevating script to Configure Windows 10...******" -ForegroundColor Green
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   #$Host.UI.RawUI.BackgroundColor = "Black"
   # clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }
 
# Run your code that needs to be elevated here
    Write-Host "This script requires elevation, and we're sorted now!"
<#    
    Write-Host  ""
    Write-Host ".. press any key to continue..."
    Write-Host  ""
    Write-Host  ""
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
#>
Set-ExecutionPolicy unrestricted
    Write-Host "Execution Policy set to unrestricted"

# Announce script kick off.
Start-Sleep -Milliseconds 500
    Write-Host "Now lets " -ForegroundColor Magenta -NoNewline
    Start-Sleep -Milliseconds 500
    Write-Host "    pwn " -ForegroundColor Cyan -NoNewline
    Start-Sleep -Milliseconds 500
    Write-Host "    this " -ForegroundColor Green -NoNewline
    Start-Sleep -Milliseconds 500
    Write-Host "    box!!!!!! " -ForegroundColor Red
    Write-Host  ""
    Write-Host  ""
    Start-Sleep -Milliseconds 500  

# Start functions .. I suggest you don't reorder these unless you understand what you're doing!

    CompatibilityChecks
    PowerSettings
    ConfigureRepos
    Dependencies
    InstallBoxstarter
    DEBLOAT
    InstallSoftware
    Goodbye
    <# 
	RemoveApps
    DisableTasks
    DisableServices
    RegChange
    ClearStartMenu
    #>