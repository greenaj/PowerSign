Import-Module -Force .\PowerSign

# signtool needs to be in path, call the line below in you profile or session to add signtool.exe in you path,
# [Environment]::SetEnvironmentVariable("Path", "$env:Path;C:\Program Files (x86)\Windows Kits\10\bin\10.0.17134.0\x64", "Process")


InModuleScope PowerSign {
    Describe "Testing Module" {

        BeforeAll {
            Add-Config .\ExampleConfig.psd1 -Name tester
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
