Describe MyScript {
    #Generate a function from the runbook
    $TemporaryFileName = ".\PesterTempFile.ps1"
    Write-Output "Function MyScript {"  | Out-File $TemporaryFileName
    foreach ($Line in (Get-Content "MyScript.ps1")) {
        #Replace Exits with Throws (to allow us to test for them)
        $Line = $Line -ireplace [regex]::Escape("exit"), "Throw"
        #Comment out dot sources (specifiy them in testing)
        $Line = $Line -ireplace [regex]::Escape(". ."), "#. ."
        Write-Output $Line  | Out-File $TemporaryFileName -Append
    }
    Write-Output "}"  | Out-File $TemporaryFileName -Append


    #Dotsource in the Powershell Script
    . .\PesterTempFile.ps1

    Context "Improperly Tagged Instance (No Matching AMI Image)" {
        $EC2InstanceObject = '{
          "GroupNames": [],
          "Groups": [],
          "Instances": [
            {
              "AmiLaunchIndex": 0,
              "Architecture": "x86_64",
              "BlockDeviceMappings": "Amazon.EC2.Model.InstanceBlockDeviceMapping",
              "CapacityReservationId": null,
              "CapacityReservationSpecification": null,
              "ClientToken": null,
              "CpuOptions": "Amazon.EC2.Model.CpuOptions",
              "EbsOptimized": false,
              "ElasticGpuAssociations": "",
              "ElasticInferenceAcceleratorAssociations": "",
              "EnaSupport": true,
              "HibernationOptions": "Amazon.EC2.Model.HibernationOptions",
              "Hypervisor": "xen",
              "IamInstanceProfile": null,
              "ImageId": "ami-00c3d41691e25e54z",
              "InstanceId": "i-035ce67f82e649970",
              "InstanceLifecycle": null,
              "InstanceType": "t2.micro",
              "KernelId": null,
              "KeyName": "Infrastructure",
              "LaunchTime": "2019-01-11T15:56:41+10:00",
              "Licenses": "",
              "Monitoring": "Amazon.EC2.Model.Monitoring",
              "NetworkInterfaces": "Amazon.EC2.Model.InstanceNetworkInterface",
              "Placement": "Amazon.EC2.Model.Placement",
              "Platform": null,
              "PrivateDnsName": "ip-172-41-5-43.ap-southeast-2.compute.internal",
              "PrivateIpAddress": "172.41.5.43",
              "ProductCodes": "",
              "PublicDnsName": null,
              "PublicIpAddress": null,
              "RamdiskId": null,
              "RootDeviceName": "/dev/xvda",
              "RootDeviceType": "ebs",
              "SecurityGroups": "Amazon.EC2.Model.GroupIdentifier",
              "SourceDestCheck": true,
              "SpotInstanceRequestId": null,
              "SriovNetSupport": null,
              "State": "Amazon.EC2.Model.InstanceState",
              "StateReason": "Amazon.EC2.Model.StateReason",
              "StateTransitionReason": "User initiated (2019-01-11 05:58:56 GMT)",
              "SubnetId": "subnet-fd406699",
              "Tags": "Amazon.EC2.Model.Tag",
              "VirtualizationType": "hvm",
              "VpcId": "vpc-2df06b49"
            }
          ],
          "OwnerId": "392817394756",
          "RequesterId": null,
          "ReservationId": "r-0fdf0c8e0b863dc38",
          "RunningInstance": [
            {
              "AmiLaunchIndex": 0,
              "Architecture": "x86_64",
              "BlockDeviceMappings": "Amazon.EC2.Model.InstanceBlockDeviceMapping",
              "CapacityReservationId": null,
              "CapacityReservationSpecification": null,
              "ClientToken": null,
              "CpuOptions": "Amazon.EC2.Model.CpuOptions",
              "EbsOptimized": false,
              "ElasticGpuAssociations": "",
              "ElasticInferenceAcceleratorAssociations": "",
              "EnaSupport": true,
              "HibernationOptions": "Amazon.EC2.Model.HibernationOptions",
              "Hypervisor": "xen",
              "IamInstanceProfile": null,
              "ImageId": "ami-00c3d41691e25e54z",
              "InstanceId": "i-035ce67f82e649970",
              "InstanceLifecycle": null,
              "InstanceType": "t2.micro",
              "KernelId": null,
              "KeyName": "Infrastructure",
              "LaunchTime": "2019-01-11T15:56:41+10:00",
              "Licenses": "",
              "Monitoring": "Amazon.EC2.Model.Monitoring",
              "NetworkInterfaces": "Amazon.EC2.Model.InstanceNetworkInterface",
              "Placement": "Amazon.EC2.Model.Placement",
              "Platform": null,
              "PrivateDnsName": "ip-172-41-5-43.ap-southeast-2.compute.internal",
              "PrivateIpAddress": "172.41.5.43",
              "ProductCodes": "",
              "PublicDnsName": null,
              "PublicIpAddress": null,
              "RamdiskId": null,
              "RootDeviceName": "/dev/xvda",
              "RootDeviceType": "ebs",
              "SecurityGroups": "Amazon.EC2.Model.GroupIdentifier",
              "SourceDestCheck": true,
              "SpotInstanceRequestId": null,
              "SriovNetSupport": null,
              "State": "Amazon.EC2.Model.InstanceState",
              "StateReason": "Amazon.EC2.Model.StateReason",
              "StateTransitionReason": "User initiated (2019-01-11 05:58:56 GMT)",
              "SubnetId": "subnet-fd406699",
              "Tags": "Amazon.EC2.Model.Tag",
              "VirtualizationType": "hvm",
              "VpcId": "vpc-2df06b49"
            }
          ]
        }' | ConvertFrom-JSON

        #Mocks
        Mock Get-EC2Instance {return $EC2InstanceObject}
        Mock Write-Host
        Mock Publish-SNSMessage
        Mock Set-EC2Tag


        #Assert
        $AMIID = "ami-00c3d41691e25e54c", "ami-00c3d41691e25e54d"
        $Region = "ap-southeast-2"
        $InstanceID = "i-035ce67f82e649970"

        MyScript -InstanceID $InstanceID -Region $Region -AMIID $AMIID

        It "Should NOT Execute New-EC2Tag" {
            Assert-MockCalled -Times 0 -Exactly Set-EC2Tag
        }
        It "Should Execute Get-EC2Instance Once" {
            Assert-MockCalled Get-EC2Instance -Times 1 -Exactly
        }
        It "Should Execute Get-EC2Volume Once" {
            Assert-MockCalled Get-EC2Volume -Times 1 -Exactly
        }

    }

    Context "InstanceID is null" {
        #Mocks
        Mock Get-EC2Instance
        Mock Write-Host

        It "Should Throw (Exit)" {
            {MyScript} | Should -Throw
        }

    }



    #Cleanup Temporary File
    Remove-Item $TemporaryFileName -Force
}