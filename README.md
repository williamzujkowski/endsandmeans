Powershell script to configure Windows 10 1809 VMs for faster spin up.


To install, copy and paste the following into a powershell prompt on the target machine:

`Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/williamzujkowski/endsandmeans/master/Install.ps1'))`




   # ENDSANDMEANS

    .SYNOPSIS A Windows 10 post imaging script 
  
    Written by: William Zujowski 
    Update: 5-27-2019
    https://github.com/williamzujkowski/endsandmeans


    **Function Name**       |   What it does
                         ---|---
    **CompatibilityChecks** |   ensures the system has enough room and other prereqs for running this script
    **PowerSettings**       |   ensure the system stays awake during installs
    **ConfigureRepos**      |   is used to add powershell gallery and other useful package sources
    **Dependencies**        |   installs needed tools and modules prior to debloating and installing software
    **InstallChocolatey**   |   installs chocolatey
    **DEBLOAT**             |   removes commonly unwanted Windows 10 defaults .. Adjust this in the debloat.config    
    **InstallSoftware**     |   Installs softare .. feel free to edit what it installs!
    **SetTheme**            |   Disabled for testing -- Adjusts default Theme in powershell
    **Goodbye**             |   End of script
