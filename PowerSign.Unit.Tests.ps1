Import-Module -Force .\PowerSign

InModuleScope PowerSign {

    $TEST_ATTEMPS_0 = 8

    Describe "Unit Tests" {

        $attempts = 0
        Mock SignFile {
            $script:attempts += 1
            Start-Sleep -Milliseconds 100
            if ($script:attempts -lt $TEST_ATTEMPS_0) {
                return 1
            } else {
                return 0
            }
        }

        Mock LoadConfig {}

        It "Stops after set failed attempts" {
            $result = Set-Sig -File C:\temp\itjustjunk.dll -attempts 5 -config something
            $result | Should -Be 1

            $script:attempts = 0
            $result = Set-Sig -File C:\temp\itjustjunk.dll -attempts 8 -config something
            $result | Should -Be 0
            $script:attempts | Should -Be $TEST_ATTEMPS_0
        }
    }
}
