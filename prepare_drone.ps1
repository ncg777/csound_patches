<#
.SYNOPSIS
Prepare a drone performance with selected group-root pitch classes.
.DESCRIPTION
Forte labels are resolved using the bundled music21 catalogue (see
MUSIC21_LICENSE.txt). No Python or music21 installation is needed.
An omitted A/B suffix selects the prime/A form. Z is optional for Z-related
classes. This launcher's .NN suffix transposes by 0-11 semitones modulo 12,
then sorts the result; 5-31A.01 preserves the original 1,2,4,7,10 list.
Custom comma-separated pitch classes retain their supplied order.
Only group roots change: voice intervals and comb-filter offsets stay fixed.
Eight groups cycle through the list with octave shifts. Lists longer than
eight contribute their first eight entries as roots.
.EXAMPLE
play_drone.bat 600 5-35 12345
.EXAMPLE
play_drone.bat 600 "0,1,4,6" 12345
.EXAMPLE
play_drone.bat --list-sets 5
.EXAMPLE
render_drone.bat 600 "drone.wav" 5-31B.01 12345
#>
[CmdletBinding()]
param(
    [string]$Duration = '600',
    [string]$PitchSet = '5-31A.01',
    [string]$Seed = '',
    [string]$OutputPath,
    [switch]$ListSets,
    [ValidateRange(0, 12)][int]$Cardinality = 0
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

try {
    $catalog = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'forte_pitch_sets.json') -Raw | ConvertFrom-Json

    if ($ListSets) {
        Write-Output 'Forte sets: A/B select inversion forms; .00-.11 transpose in semitones.'
        Write-Output 'Default: 5-31A.01 = 1,2,4,7,10'
        foreach ($property in $catalog.classes.PSObject.Properties) {
            if ($Cardinality -ne 0 -and [int]($property.Name.Split('-')[0]) -ne $Cardinality) {
                continue
            }
            $entry = $property.Value
            $label = $property.Name
            if ($entry.zPartner -ne 0) { $label = $label.Replace('-', '-Z') }
            if ($null -eq $entry.inverse) {
                Write-Output ('{0,-9} {1}' -f $label, ($entry.prime -join ','))
            } else {
                Write-Output ('{0,-9} {1}' -f ($label + 'A'), ($entry.prime -join ','))
                Write-Output ('{0,-9} {1}' -f ($label + 'B'), ($entry.inverse -join ','))
            }
        }
        exit 0
    }

    $PitchSet = $PitchSet.Trim()
    $aliases = @{
        'default' = '5-31A.01'
        'pentatonic' = '5-35'
        'whole-tone' = '6-35'
        'octatonic' = '8-28'
        'chromatic' = '12-1'
    }
    if ($aliases.ContainsKey($PitchSet)) { $PitchSet = $aliases[$PitchSet] }

    $forte = [regex]::Match($PitchSet, '^(?<card>1[0-2]|[1-9])-(?<z>Z?)(?<index>[1-9]\d?)(?<form>[AB]?)(?:\.(?<shift>\d{1,2}))?$', 'IgnoreCase')
    if ($forte.Success) {
        $key = $forte.Groups['card'].Value + '-' + $forte.Groups['index'].Value
        $property = $catalog.classes.PSObject.Properties[$key]
        if ($null -eq $property) { throw "Unknown Forte set '$PitchSet'. Use --list-sets to see the catalogue." }
        $entry = $property.Value
        if ($forte.Groups['z'].Value -ne '' -and $entry.zPartner -eq 0) {
            throw "Forte set '$key' has no Z relation; remove the Z."
        }
        $form = $forte.Groups['form'].Value.ToUpperInvariant()
        if ($form -eq 'B') {
            if ($null -eq $entry.inverse) { throw "Forte set '$key' has no distinct B form." }
            $pitchClasses = @($entry.inverse)
        } else {
            $pitchClasses = @($entry.prime)
        }
        $shift = 0
        if ($forte.Groups['shift'].Success) { $shift = [int]$forte.Groups['shift'].Value }
        if ($shift -gt 11) { throw 'The .NN transposition must be between .00 and .11.' }
        if ($shift -ne 0) {
            $pitchClasses = @($pitchClasses | ForEach-Object { ($_ + $shift) % 12 } | Sort-Object)
        }
    } elseif ($PitchSet -match '^\d{1,2}(\s*,\s*\d{1,2})*$') {
        $pitchClasses = @($PitchSet.Split(',') | ForEach-Object { [int]$_.Trim() })
        if (@($pitchClasses | Where-Object { $_ -lt 0 -or $_ -gt 11 }).Count -ne 0) {
            throw 'Custom pitch classes must be integers from 0 through 11.'
        }
        if (@($pitchClasses | Select-Object -Unique).Count -ne $pitchClasses.Count) {
            throw 'A custom pitch-class set must not contain duplicate values.'
        }
    } else {
        throw "Unknown pitch set '$PitchSet'. Use a Forte label, a named alias, or a comma-separated list such as 0,2,4,7,9."
    }

    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    $durationValue = 0.0
    if (-not [double]::TryParse($Duration, [System.Globalization.NumberStyles]::Float, $culture, [ref]$durationValue) -or
        [double]::IsNaN($durationValue) -or [double]::IsInfinity($durationValue) -or $durationValue -le 0) {
        throw 'Duration must be a positive number of seconds.'
    }
    $durationText = $durationValue.ToString('R', $culture)
    if ([string]::IsNullOrWhiteSpace($Seed)) {
        $Seed = (Get-Random -Minimum 1 -Maximum 1073741824).ToString($culture)
    }
    $seedValue = [uint32]0
    if (-not [uint32]::TryParse($Seed, [System.Globalization.NumberStyles]::None, $culture, [ref]$seedValue) -or $seedValue -eq 0) {
        throw 'Seed must be an integer from 1 through 4294967295, or omitted for a random seed.'
    }
    if ([string]::IsNullOrWhiteSpace($OutputPath)) { throw 'An output path for the temporary CSD is required.' }

    $template = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'evolving_drone_template.csd') -Raw
    $pitchText = $pitchClasses -join ', '
    $prepared = $template.Replace('__DURATION__', $durationText).Replace('__SEED__', $seedValue.ToString($culture))
    $prepared = $prepared.Replace('<CsInstruments>', "<CsInstruments>`r`n#define PITCH_CLASSES #$pitchText#")
    [System.IO.File]::WriteAllText($OutputPath, $prepared, [System.Text.UTF8Encoding]::new($false))

    Write-Output "Duration:      $durationText seconds"
    Write-Output "Pitch set:     $PitchSet"
    Write-Output ('Pitch classes: ' + ($pitchClasses -join ','))
    Write-Output "Seed:          $seedValue"
    if ($pitchClasses.Count -gt 8) {
        Write-Output 'The eight group roots use the first eight entries of this list.'
    }
} catch {
    [Console]::Error.WriteLine('Drone setup failed: ' + $_.Exception.Message)
    exit 1
}
