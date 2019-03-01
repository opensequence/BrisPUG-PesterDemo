Import-Module "AWSPowerShell.NetCore"
Describe Find-MeInstance {
    #Mocks
    Mock New-EC2Tag
    Mock Get-EC2Instance
    Mock Get-EC2Tag
    Mock Publish-SNSMessage
    Mock Write-Output
    Mock Get-EC2Volume
    #Dot Source Script
    . ./MyScript.ps1
    Context "When a Instance is created with the specified AMI" {
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
                "ImageId": "ami-00c3d41691e25e54c",
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
                "ImageId": "ami-00c3d41691e25e54c",
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

        Mock Get-EC2Instance {return $EC2InstanceObject}

        $AMIID = "ami-00c3d41691e25e54c", "ami-00c3d41691e25e54d"
        $Region = "ap-southeast-2"
        $InstanceID = "i-035ce67f82e649970"
        $result = Find-MeInstance -InstanceID $InstanceID -Region $Region -AMIID $AMIID
        #Assert

        It "Should not return null" {
            $result | Should -not -be $null
        }
        It "Should return a valid object containg one of the AMIID's provided" {
            $AMIID | Should -Contain $result.Instances.ImageId
        }
        It "Should return a valid object with the Same InstanceID as provided" {
            $result.Instances.InstanceId | Should be $InstanceID
        }
    }
    Context "When a Instance is created and doesn't match a specified AMI" {
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
                "ImageId": "ami-00c3d41671e25e54c",
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
                "PrivateDnsName": "ip-172-31-5-33.ap-southeast-2.compute.internal",
                "PrivateIpAddress": "172.31.5.33",
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
                "ImageId": "ami-00c3d41671e25e54c",
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
                "PrivateDnsName": "ip-172-31-5-33.ap-southeast-2.compute.internal",
                "PrivateIpAddress": "172.31.5.33",
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
        Mock Get-EC2Instance {return $EC2InstanceObject}

        $AMIID = "ami-00c3d41691e25e54c", "ami-00c3d41691e25e54d"
        $Region = "ap-southeast-2"
        $InstanceID = "i-035ce67f82e649970"
        $result = Find-MeInstance -InstanceID $InstanceID -Region $Region -AMIID $AMIID
        #Assert

        It "Should return null" {
            $result | Should -Be $null
        }
    }

    Context "If there is an error Retreiving EC2 Information" {
        Mock Get-EC2Instance {Throw}

        $AMIID = "ami-00c3d41691e25e54c", "ami-00c3d41691e25e54d"
        $Region = "ap-southeast-2"
        $InstanceID = "i-035ce67f82e649970"

        #Assert

        It "Should Throw" {
            {$result = Find-MeInstance -InstanceID $InstanceID -Region $Region -AMIID $AMIID} | Should -Throw
        }
    }
}