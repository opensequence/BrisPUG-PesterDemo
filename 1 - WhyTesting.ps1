#Set the error action preference to stop to handle errors as they occur
$ErrorActionPreference = "Stop"

#Override the verbose preference
$VerbosePreference = "SilentlyContinue"

#endregion Parameters

#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.428.0'}
#====================================================================================================
#                                             Functions
#====================================================================================================
#region Functions

#region Find-MeInstance

function Find-MeInstance {
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $True, Position = 1)]
        [string]
        $InstanceID,
        [parameter(Mandatory = $True, Position = 2)]
        [string]
        $Region,
        [parameter(Mandatory = $True, Position = 3)]
        [string[]]
        $AMIID
    )
    # retrieve EC2Instance Details
    try {
        Write-Verbose "START: Retrieving EC2 Details for Instance: $($InstanceID)"
        $EC2InstanceDetail = Get-EC2Instance -InstanceID $InstanceID -Region $Region
        Write-Verbose "SUCCESS: Retrieving EC2 Details for Instance: $($InstanceID)"
    } catch {
        Throw "ERROR: Retrieving EC2 Details for Instance: $($InstanceID) ErrorMessage: $($_.Exception.Message)"
    }

    #Compare AMI ID wth provided ID
    If ($AMIID -contains $($EC2InstanceDetail.Instances.ImageId)) {
        Write-Verbose "$($EC2InstanceDetail.Instances.ImageId) Matches one of Provided AMIID: $($AMIID)"
        return $EC2InstanceDetail
    } else {
        Write-Verbose "$($EC2InstanceDetail.Instances.ImageId) does NOT Match one of Provided AMIID: $($AMIID)"
        return $null
    }

}
#endregion Find-MeInstance