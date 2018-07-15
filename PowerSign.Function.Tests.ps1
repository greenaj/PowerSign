Import-Module -Force .\PowerSign

InModuleScope PowerSign {
    Describe "Functional Tests" {


        BeforeAll {
            Add-Config .\ExampleConfig.psd1 -Name tester

            # LoadConfig will need to load a valid configuration, you will need a code signing cert.
            LoadConfig "tester"
        }

        It "Loops through URLS" {
            GetTsUrl | Should -Be $timeStampers[0]
            GetTsUrl | Should -Be $timeStampers[1]
        }

        It "Signs executable" {
            $result = Set-Sig "$PSScriptRoot\sample_app\build\Release\hellosign.exe" -config "tester"

            $result | Should -Be 0
        }

        Context "When signing fails" {

            $trials = 0
            Mock SignFile {
                $script:trials = $script:trials + 1
                return 1
            }

            $result = Set-Sig "$PSScriptRoot\sample_app\build\Release\hellosign.exe" -config "tester" -Attempts 5

            $result | Should -Be 1
            $script:trials | Should -Be 5
        }

        AfterAll {
            Remove-Item (Join-Path -Path (GetConfigDir) -ChildPath "tester.psd1")
        }
    }
}
