Import-Module "AWSPowerShell.NetCore"
Describe Find-MeInstance {
    #Dot Source Script
    . './2 - WhyTesting.ps1'
    Context "When a Instance is created with the specified AMI" {
        $EC2InstanceObject = Get-Content .\Tests\When_a_Instance_is_created_with_the_specified_AMI.json | ConvertFrom-JSON

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
        $EC2InstanceObject = Get-Content .\Tests\When_a_Instance_is_created_and_doesnt_match_a_specified_AMI.json | ConvertFrom-JSON

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
    #TODO-NOW TESTING MY NEW FEATURES!
    Context "When a Instance is created with the specified InstanceType" {
        $EC2InstanceObject = Get-Content .\Tests\When_a_Instance_is_created_with_the_specified_InstanceType.json | ConvertFrom-JSON

        Mock Get-EC2Instance {return $EC2InstanceObject}

        $InstanceType = "t2.micro", "t2.nano"
        $Region = "ap-southeast-2"
        $InstanceID = "i-035ce67f82e649970"
        $result = Find-MeInstance -InstanceID $InstanceID -Region $Region -InstanceType $InstanceType
        #Assert

        It "Should not return null" {
            $result | Should -not -be $null
        }
        It "Should return a valid object containg one of the AMIID's provided" {
            $InstanceType | Should -Contain $result.Instances.InstanceType
        }
        It "Should return a valid object with the Same InstanceID as provided" {
            $result.Instances.InstanceId | Should be $InstanceID
        }
    }
}