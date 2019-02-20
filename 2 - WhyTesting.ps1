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
        [parameter(Mandatory = $false, Position = 3)]
        [string[]]
        $AMIID,
        #TODO-NOW Add Support for filtering by InstanceType
        [parameter(Mandatory = $false, Position = 4)]
        [string[]]
        $InstanceType
    )
    # retrieve EC2Instance Details
    try {
        Write-Verbose "START: Retrieving EC2 Details for Instance: $($InstanceID)"
        $EC2InstanceDetail = Get-EC2Instance -InstanceID $InstanceID -Region $Region
        Write-Verbose "SUCCESS: Retrieving EC2 Details for Instance: $($InstanceID)"
    } catch {
        Throw "ERROR: Retrieving EC2 Details for Instance: $($InstanceID) ErrorMessage: $($_.Exception.Message)"
    }
    If($AMIID){
    #Compare AMI ID wth provided ID
    If ($AMIID -contains $($EC2InstanceDetail.Instances.ImageId)) {
        Write-Verbose "$($EC2InstanceDetail.Instances.ImageId) Matches one of Provided AMIID: $($AMIID)"
        return $EC2InstanceDetail
    } else {
        Write-Verbose "$($EC2InstanceDetail.Instances.ImageId) does NOT Match one of Provided AMIID: $($AMIID)"
        return $null
    }
}
    If($InstanceType){
    #Compare InstanceType wth provided Types
    #TODO-NOW I've Made a mistake, can you see it?
    If ($InstanceType -contains $($EC2InstanceDetail.Instances.InstaceType)) {
        Write-Verbose "$($EC2InstanceDetail.Instances.InstanceType) Matches one of Provided InstanceTypes: $($InstanceType)"
        return $EC2InstanceDetail
    } else {
        Write-Verbose "$($EC2InstanceDetail.Instances.InstanceType) does NOT Match one of Provided InstanceType: $($InstanceType)"
        return $null
    }
    }

}
#endregion Find-MeInstance