Describe Set-AWSTag {
    #Generate a function from the runbook
    $TemporaryFileName = ".\PesterTempFile.ps1"
    Write-Output "Function MyScript {"  | Out-File $TemporaryFileName
    foreach ($Line in (Get-Content "MyScript.ps1")) {
        #Replace Exits with Throws (to allow us to test for them)
        $Line = $Line -ireplace [regex]::Escape("exit"), "Throw"
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
            "ImageId": "ami-02f3dft5f06d93df",
            "InstanceId": "i-0003547011fd5789f",
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
        "OwnerId": "667047158394",
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
            "ImageId": "ami-02f3dft5f06d93dfc",
            "InstanceId": "i-0003547011fd5789f",
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

        $EC2Tag = '[
        {
          "Key": "Business",
          "ResourceId": "i-0003547011fd5789f",
          "ResourceType": {
            "Value": "instance"
          },
          "Value": "Auscript"
        },
        {
          "Key": "Environment",
          "ResourceId": "i-0003547011fd5789f",
          "ResourceType": {
            "Value": "instance"
          },
          "Value": "Dev"
        },
        {
          "Key": "Test",
          "ResourceId": "i-0003547011fd5789f",
          "ResourceType": {
            "Value": "instance"
          },
          "Value": "abc123"
        }
      ]' | ConvertFrom-JSON
        #Mocks
        Mock New-EC2Tag
        Mock Get-EC2Instance {return $EC2InstanceObject}
        Mock Get-EC2Tag {return $EC2Tag}
        Mock Publish-SNSMessage
        Mock Write-Host
        Mock Get-EC2Volume


        #Assert
        $LambdaInputJSON = '{ "version": "0", "id": "7510756c-8f14-c60d-aa92-8643ea3046d7", "detail-type": "EC2 Instance State-change Notification", "source": "aws.ec2", "account": "667047158394", "time": "2019-01-11T02:32:32Z", "region": "ap-southeast-2", "resources": [ "arn:aws:ec2:ap-southeast-2:667047158394:instance/i-0003547011fd5789f" ], "detail": { "instance-id": "i-0003547011fd5789f", "state": "pending" } }'
        $LambdaInput = $LambdaInputJSON | ConvertFrom-Json
        Set-AWSTag
        It "Should Publish SNS Message" {
            Assert-MockCalled Publish-SNSMessage
        }
        It "Should NOT Execute New-EC2Tag" {
            Assert-MockCalled -Times 0 -Exactly New-EC2Tag
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

        #Assert
        $LambdaInput = $null

        It "Should Throw (Exit)" {
            {MyS} | Should -Throw
        }

    }



    #Cleanup Temporary File
    Remove-Item $TemporaryFileName -Force
}