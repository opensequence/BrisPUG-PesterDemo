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
        $EC2InstanceObject = Get-Content '.\Tests\Improperly_Tagged_Instance_(No_Matching_AMI_Image).json' | ConvertFrom-JSON

        #Mocks
        Mock Get-EC2Instance {return $EC2InstanceObject}
        Mock Write-Host
        Mock Publish-SNSMessage
        Mock New-EC2Tag


        #Assert
        $AMIID = "ami-00c3d41691e25e54c", "ami-00c3d41691e25e54d"
        $Region = "ap-southeast-2"
        $InstanceID = "i-035ce67f82e649970"

        MyScript -InstanceID $InstanceID -Region $Region -AMIID $AMIID

        It "Should NOT Execute New-EC2Tag" {
            Assert-MockCalled -Times 0 -Exactly New-EC2Tag
        }
        It "Should Execute Get-EC2Instance Once" {
            Assert-MockCalled Get-EC2Instance -Times 1 -Exactly
        }
        It "Should Execute Publish-SNSMessage Once" {
            Assert-MockCalled Publish-SNSMessage -Times 1 -Exactly
        }


    }

    Context "InstanceID is null" {
        #Mocks
        Mock Get-EC2Instance
        Mock Write-Output

        It "Should Throw (Exit)" {
            {MyScript} | Should -Throw
        }

    }

    Context "Improperly Tagged Instance (Matching AMI Image)" {
        $EC2InstanceObject = Get-Content '.\Tests\Improperly_Tagged_Instance_(No_Matching_AMI_Image).json' | ConvertFrom-JSON

        #Mocks
        Mock Get-EC2Instance {return $EC2InstanceObject}
        Mock Write-Output
        Mock Publish-SNSMessage
        Mock New-EC2Tag


        #Assert
        $AMIID = "ami-00c3d41691e25e54z", "ami-00c3d41691e25e54d"
        $Region = "ap-southeast-2"
        $InstanceID = "i-035ce67f82e649970"

        MyScript -InstanceID $InstanceID -Region $Region -AMIID $AMIID

        It "Should Execute New-EC2Tag" {
            Assert-MockCalled -Times 1 -Exactly New-EC2Tag
        }
        It "Should Execute Get-EC2Instance Once" {
            Assert-MockCalled Get-EC2Instance -Times 1 -Exactly
        }
        It "Should NOT Execute Publish-SNSMessage" {
            Assert-MockCalled Publish-SNSMessage -Times 0 -Exactly
        }

    }



    #Cleanup Temporary File
    Remove-Item $TemporaryFileName -Force
}