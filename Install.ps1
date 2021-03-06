<#
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                  _                         _
  ___  _ __    __| | ___   __ _  _ __    __| | _ __ ___    ___   __ _  _ __   ___
 / _ \| '_ \  / _` |/ __| / _` || '_ \  / _` || '_ ` _ \  / _ \ / _` || '_ \ / __|
|  __/| | | || (_| |\__ \| (_| || | | || (_| || | | | | ||  __/| (_| || | | |\__ \
 \___||_| |_| \__,_||___/ \__,_||_| |_| \__,_||_| |_| |_| \___| \__,_||_| |_||___/


  .SYNOPSIS A Windows 10 post imaging script 
  
  Written by: William Zujowski 
  Update: 8-20-2019
  https://github.com/williamzujkowski/endsandmeans

  -- Removes Telemetry, Cortana, and other Bloat autoamtically
  -- Installs Chocolatey for package management and a bunch useful software
  -- Installs Windows Updates
  -- 


    CompatibilityChecks ensures the system has enough room and other prereqs for running this script
    PowerSettings       ensure the system stays awake during installs
    ConfigureRepos      is used to add powershell gallery and other useful package sources
    Dependencies        installs needed tools and modules prior to debloating and installing software
    InstallChocolatey   installs chocolatey
    DEBLOAT             removes commonly unwanted Windows 10 defaults .. Adjust this in the debloat.config    
    InstallSoftware     Installs softare .. feel free to edit what it installs!
    SetTheme            Disabled for testing -- Adjusts default Theme in powershell
    

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++    
    
#>


Function InstallSoftware()
{
    
 
 Write-Host "Installing software.."
 
 cup volatility sysinternals rawcopy screentogif vscode markdownmonster googlechrome x64dbg.portable Hashcheck nmap ida-free fiddler pester packer winscp processhacker yed pesieve baretail wireshark lessmsi putty notepadplusplus 7zip -y

# Install-WindowsUpdate -Full
     
}

function CompatibilityChecks()
 { # Start CompatibilityChecks
  
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
    if (-Not (($disk.used + $disk.free)/1GB -gt 20)){
      Write-Host "`t[ERR] This install requires a minimum 20 GB of free space, please increase disk space to continue`n" -ForegroundColor Red
      Read-Host "Press any key to continue"
      Write-Host  ""
      exit
    }
    else
    {
      Write-Host "`t> At least 20 GB of disk space detected, that should be enough .." -ForegroundColor Green
      Write-Host  ""
    }
} # End CompatibilityChecks
  
function ConfigureRepos()
{ # Start ConfigureRepos
    <#
.SYNOPSIS
Trust repositories for installing modules with "install-package"
#>

Write-Host "[+] Trusting PSGallery and installing Modules"
Write-Host  ""
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Write-Host "PSGallery Successfully Added."
Write-Host  ""
# Installing NuGet here to avoid prompting later
  Write-Host  "[+] Installing NuGet"
  Install-Module -Name NuGet
  Write-Host  ""
  Write-Host "NuGet Successfully Added."
  # posh-git is a PowerShell module that integrates Git and PowerShell https://github.com/dahlbyk/posh-git
  Write-Host "Posh-Git Installed"
  Install-Module posh-git
  # A theme engine for Powershell in ConEmu --  https://github.com/JanDeDobbeleer/oh-my-posh
  Install-Module oh-my-posh
  Write-Host "oh-my-posh installed..."
  
} # End ConfigureRepos

function Dependencies()
{ # Start Dependencies
Write-Host "[+] Installing Modules.."
Write-Host ""
mkdir -p 'c:\temp' | Out-Null
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/williamzujkowski/endsandmeans/master/Win10.psm1' -Outfile 'C:\temp\Win10.psm1'
  Write-Host "Trying to import Win10 Debloat after download"
  Import-Module 'C:\TEMP\Win10.psm1'
  Write-Host "  Win10 Debloat DOWNLOADED and installed"
    Write-Host ""
  Write-Host "The following modules are currently installed:"
  Write-Host ""
  Get-Module
  Write-Host ""
} # End Dependencies

function SetTheme ()
{ # Start SetTheme
  if (!(Test-Path -Path $PROFILE )) { New-Item -Type File -Path $PROFILE -Force };
  Add-Content $PROFILE ( "Import-Module posh-git `nImport-Module oh-my-posh `nSet-Theme Paradox")
  
}

function DEBLOAT()
{ # Start DEBLOAT
Write-Host "[ + ] Starting DEBLOAT process"
Write-Host ""
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/williamzujkowski/endsandmeans/master/debloat.config'))
Write-Host ""
Write-Host " DEBLOAT Complete!!"
Write-Host ""
# $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

} # End DEBLOAT

function InstallChocolatey()
{ # Start InstallChocolatey
  
  Write-Host "[ * ] Installing Chocolatey"


  # Download and install latest Chocolatey
  Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
  
  # Choco config prior to software installs
    choco feature enable -n allowGlobalConfirmation
      
 } # End InstallChocolatey


function PowerSettings()
{ # Start PowerSettings
  # Tweak power options to prevent installs from timing out
  Write-Host "[ * ] Adjusting Power Settings on" $env:computername -ForegroundColor Magenta -NoNewline
  Write-Host  ""
  Write-Host  ""
  Start-Sleep -Milliseconds 500 
  
  & powercfg -change -monitor-timeout-ac 0 | Out-Null
  & powercfg -change -monitor-timeout-dc 0 | Out-Null
  & powercfg -change -disk-timeout-ac 0 | Out-Null
  & powercfg -change -disk-timeout-dc 0 | Out-Null
  & powercfg -change -standby-timeout-ac 0 | Out-Null
  & powercfg -change -standby-timeout-dc 0 | Out-Null
  & powercfg -change -hibernate-timeout-ac 0 | Out-Null
  & powercfg -change -hibernate-timeout-dc 0 | Out-Null
} # End PowerSettings

function InstallPowerStig() 
{
  Install-Module PowerSTIG -Scope CurrentUser
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

Set-ExecutionPolicy unrestricted
    Write-Host "Execution Policy set to unrestricted"

# Announce script kick off.
Start-Sleep -Milliseconds 500
    Write-Host "Configuring" $env:computername -ForegroundColor Magenta -NoNewline
  
    Write-Host  ""
    Write-Host  ""
    Start-Sleep -Milliseconds 500  

# Start functions .. I suggest you don't reorder these unless you understand what you're doing!

    CompatibilityChecks
    PowerSettings
    ConfigureRepos
    Dependencies
    InstallChocolatey
    DEBLOAT
    InstallSoftware
    InstallPowerStig
    # SetTheme - Disabled for testing
