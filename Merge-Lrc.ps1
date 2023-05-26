<#
.SYNOPSIS
Merge lrc files.
.DESCRIPTION
Merge lrc files.
.PARAMETER Path
Path to one or more locations. Wildcards are permitted.
.PARAMETER MergeMethod
Merge method. Default is 'Merge'. 'Merge' is to merge all lines with the same time. 'Intersect' is to merge all lines with the same time and split the lines with different time evenly. 'Union' is to merge all lines with the same time and split the lines with different time.
.PARAMETER SplitChar
Split character. Default is ' '.
.PARAMETER MaxInterval
Max interval for 'Intersect' method. Default is 10 (Second).
.PARAMETER Offset
Offset when meet max interval. Default is 1000 (Millisecond).
.INPUTS
System.String[]
.OUTPUTS
Lrc file.
.EXAMPLE
PS C:\> Merge-Lrc -Path "C:\Users\user\Music\*.lrc" -MergeMethod "Merge" -SplitChar " "
This example merges all lrc files in the folder "C:\Users\user\Music\".
.EXAMPLE
PS C:\> Merge-Lrc -Path "C:\Users\user\Music\*.lrc" -MergeMethod "Intersect" -SplitChar " " | Out-File "C:\Users\user\Music\merged.lrc"
This example merges all lrc files in the folder "C:\Users\user\Music\" and saves the result to "C:\Users\user\Music\merged.lrc".
#>

#Requires -Version 7
using namespace System.Collections.Generic
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true,
        ValueFromPipeline = $true,
        ValueFromPipelineByPropertyName = $true,
        HelpMessage = "Path to one or more locations. Wildcards are permitted.")]
    [ValidateNotNullOrEmpty()]
    [SupportsWildcards()]
    [Alias("PSPath")]
    [string[]]
    $Path,
    [Parameter(
        HelpMessage = "Merge method. Default is 'Merge'.")]
    [ValidateSet("Merge", "Intersect", "Union")]
    [string]
    $MergeMethod = "Merge",
    [Parameter(HelpMessage = "Split character. Default is ' '.")]
    [string]
    $SplitChar = " ",
    [Parameter(HelpMessage = "Max interval for 'Intersect' method. Default is 10 (Second).")]
    $MaxInterval = 10,
    [Parameter(HelpMessage = "Offset when meet max interval. Default is 1000 (Millisecond).")]
    $Offset = 1000
)

class Lrc {
    [SortedDictionary[int, List[string]]] $Lines
}

function Get-Lrc ($Path) {
    $files = Get-ChildItem -Path $Path
    return $files | ForEach-Object {
        $lrc = [Lrc]::new()
        $lrc.Lines = [SortedDictionary[int, List[string]]]::new()
        $lines = Get-Content -Path $_.FullName
        $lines | ForEach-Object {
            $line = $_
            $lineContent = [regex]::Match($line, '(?:\[(\d+:\d+\.\d+)\])+(.*)')
            if ($lineContent.Success) {
                $lineContent.Groups[1].Captures | ForEach-Object {
                    $time = [timespan]::ParseExact($_.Value, 'mm\:ss\.ff', [cultureinfo]::GetCultureInfo('en-US')).TotalMilliseconds
                    if ($lrc.Lines.ContainsKey($time)) {
                        $lrc.Lines[$time].Add($lineContent.Groups[2].Value)
                    }
                    else {
                        $list = [List[string]]::new()
                        $list.Add($lineContent.Groups[2].Value)
                        $lrc.Lines.Add($time, $list)
                    }
                }
            }
        }
        return $lrc
    }
}

function Merge-Lrc ($Lrcs) {
    if ($Lrcs.Count -eq 0) {
        return [Lrc]::new()
    }
    if ($Lrcs.Count -eq 1) {
        return $Lrcs[0]
    }
    $mergedLrc = $Lrcs[0]
    $Lrcs = $Lrcs | Select-Object -Skip 1
    $Lrcs | ForEach-Object {
        $lrc = $_
        $lrc.Lines.Keys | ForEach-Object {
            $_
            $time = $_
            if ($mergedLrc.Lines.ContainsKey($time)) {
                $mergedLrc.Lines[$time].AddRange($lrc.Lines[$time])
            }
            else {
                $mergedLrc.Lines.Add($time, $lrc.Lines[$time])
            }
        }
    }
    return $mergedLrc
}

function Save-Lrc ($Lrc, $MergeMethod = "Merge", $SplitChar = " ", $MaxInterval = 10, $Offset = 1000) {
    switch ($MergeMethod) {
        "Merge" {
            return $Lrc.Lines.Keys | ForEach-Object {
                $time = $_
                "[$([timespan]::FromMilliseconds($time).ToString('mm\:ss\.ff'))]$([string]::Join($SplitChar, $Lrc.Lines[$time]))"
            }
        }
        "Intersect" {
            $times = $Lrc.Lines.Keys | Select-Object
            $out = [List[string]]::new()
            for ($i = 0; $i -lt $times.Count; $i++) {
                $lines = $Lrc.Lines[$times[$i]] | Select-Object
                if ($lines.Count -eq 1) {
                    $out.Add("[$([timespan]::FromMilliseconds($times[$i]).ToString('mm\:ss\.ff'))]$($lines)")
                }
                else {
                    if ($i -eq ($times.Count - 1)) {
                        $currentTime = $times[$i]
                        $interval = $Offset
                        for ($j = 0; $j -lt $lines.Count; $j++) {
                            $out.Add("[$([timespan]::FromMilliseconds($currentTime + $j * $interval).ToString('mm\:ss\.ff'))]$($lines[$j])")
                        }
                    }
                    else {
                        $currentTime = $times[$i]
                        $nextTime = $times[$i + 1]
                        $interval = ($nextTime - $currentTime) / ($lines.Length)
                        if ($nextTime - $currentTime -gt $MaxInterval * 1000) {
                            $interval = $Offset
                        }
                        for ($j = 0; $j -lt $lines.Count; $j++) {
                            $out.Add("[$([timespan]::FromMilliseconds($currentTime + $j * $interval).ToString('mm\:ss\.ff'))]$($lines[$j])")
                        }
                    }
                }
            }
            return $out
        }
        "Union" {
            return $Lrc.Lines.Keys | ForEach-Object {
                $time = $_
                $Lrc.Lines[$time] | ForEach-Object {
                    "[$([timespan]::FromMilliseconds($time).ToString('mm\:ss\.ff'))]$_"
                }
            }
        }
    }
}
$lrcs = Get-Lrc -Path $Path
if ($lrcs.Count -eq 0) {
    Write-Error "No lrc file found."
    return
}
$mergedLrc = Merge-Lrc -Lrcs $lrcs
return Save-Lrc -Lrc $mergedLrc -MergeMethod $MergeMethod -SplitChar $SplitChar -MaxInterval $MaxInterval -Offset $Offset
