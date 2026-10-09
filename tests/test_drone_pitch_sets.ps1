# Run with: powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_drone_pitch_sets.ps1
# Performances use -n: no audio device or sound files are opened.
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$helper = Join-Path $repo 'prepare_drone.ps1'
$testCsd = Join-Path ([System.IO.Path]::GetTempPath()) ('drone_test_' + [guid]::NewGuid().ToString('N') + '.csd')

function Invoke-Preparation {
    param([string]$PitchSet, [string]$Duration = '3', [string]$Seed = '12345')
    $previousPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = 'Continue'
        $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $helper -Duration $Duration -PitchSet $PitchSet -Seed $Seed -OutputPath $testCsd 2>&1 | Out-String
        return @{ Status = $LASTEXITCODE; Output = $output }
    } finally {
        $ErrorActionPreference = $previousPreference
    }
}

try {
    $catalog = Get-Content -LiteralPath (Join-Path $repo 'forte_pitch_sets.json') -Raw | ConvertFrom-Json
    if (@($catalog.classes.PSObject.Properties).Count -ne 223) { throw 'Incomplete Forte catalogue.' }
    foreach ($property in $catalog.classes.PSObject.Properties) {
        $cardinality = [int]$property.Name.Split('-')[0]
        foreach ($form in @('prime', 'inverse')) {
            $pcs = $property.Value.$form
            if ($null -eq $pcs) { continue }
            if (@($pcs).Count -ne $cardinality -or @($pcs | Select-Object -Unique).Count -ne $cardinality -or
                @($pcs | Where-Object { $_ -lt 0 -or $_ -gt 11 }).Count -ne 0) {
                throw "Invalid catalogue entry: $($property.Name) $form"
            }
        }
        if ($null -ne $property.Value.inverse) {
            $inversionMatches = $false
            for ($shift = 0; $shift -lt 12; $shift++) {
                $inverted = @($property.Value.prime | ForEach-Object { ($shift - $_ + 12) % 12 } | Sort-Object)
                if (($inverted -join ',') -eq ($property.Value.inverse -join ',')) { $inversionMatches = $true }
            }
            if (-not $inversionMatches) { throw "Incorrect B form: $($property.Name)" }
        }
    }

    $cases = @(
        @{ Set='5-31A.01'; Expected='1, 2, 4, 7, 10'; Perform=$true },
        @{ Set='5-35'; Expected='0, 2, 4, 7, 9'; Perform=$false },
        @{ Set='6-35'; Expected='0, 2, 4, 6, 8, 10'; Perform=$true },
        @{ Set='8-28'; Expected='0, 1, 3, 4, 6, 7, 9, 10'; Perform=$true },
        @{ Set='3-11A'; Expected='0, 3, 7'; Perform=$false },
        @{ Set='3-11B'; Expected='0, 4, 7'; Perform=$false },
        @{ Set='4-z15a.11'; Expected='0, 3, 5, 11'; Perform=$false },
        @{ Set='0, 1, 4, 6'; Expected='0, 1, 4, 6'; Perform=$true },
        @{ Set='0'; Expected='0'; Perform=$true },
        @{ Set='12-1'; Expected='0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11'; Perform=$false }
    )
    foreach ($case in $cases) {
        $result = Invoke-Preparation -PitchSet $case.Set
        if ($result.Status -ne 0) { throw $result.Output }
        $prepared = Get-Content -LiteralPath $testCsd -Raw
        if (-not $prepared.Contains('#define PITCH_CLASSES #' + $case.Expected + '#') -or $prepared -match '__DURATION__|__SEED__') {
            throw "Incorrect prepared performance for $($case.Set)"
        }
        if ($case.Perform) {
            # Check the actual Csound table length, not just the macro text.
            $expectedLength = $case.Expected.Split(',').Count
            $probe = 'iScaleLen = ftlen(giScaleDegrees)' + "`n" + '    prints "TEST_PCS_LENGTH %d\n", iScaleLen'
            $prepared = $prepared.Replace('iScaleLen = ftlen(giScaleDegrees)', $probe)
            [System.IO.File]::WriteAllText($testCsd, $prepared, [System.Text.UTF8Encoding]::new($false))
            $previousPreference = $ErrorActionPreference
            $ErrorActionPreference = 'Continue'
            $performance = & csound -n -d -m0 $testCsd 2>&1 | Out-String
            $performanceStatus = $LASTEXITCODE
            $ErrorActionPreference = $previousPreference
            if ($performanceStatus -ne 0 -or $performance -notmatch "TEST_PCS_LENGTH $expectedLength\b") {
                throw "Csound failed for $($case.Set): $performance"
            }
        }
    }

    foreach ($invalidSet in @('5-99', '5-35B', '5-Z35', '5-31A.12', '0,0,7', '0,12', '-1,4', '0,,7')) {
        if ((Invoke-Preparation -PitchSet $invalidSet).Status -eq 0) { throw "Accepted invalid set: $invalidSet" }
    }
    foreach ($invalidDuration in @('0', '-1', 'NaN', 'Infinity', 'nope')) {
        if ((Invoke-Preparation -PitchSet '5-35' -Duration $invalidDuration).Status -eq 0) { throw "Accepted invalid duration: $invalidDuration" }
    }
    foreach ($invalidSeed in @('0', '-1', '4294967296', '1.5')) {
        if ((Invoke-Preparation -PitchSet '5-35' -Seed $invalidSeed).Status -eq 0) { throw "Accepted invalid seed: $invalidSeed" }
    }
    Write-Output 'PASS: complete catalogue, inversion forms, custom lists, validation, and Csound performances.'
} finally {
    if (Test-Path -LiteralPath $testCsd) { Remove-Item -LiteralPath $testCsd }
}
