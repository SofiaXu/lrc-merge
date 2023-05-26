```
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
```

# Merge-Lrc

## 介绍

这是一个用于合并歌词的小工具，可以将多个歌词文件合并成一个歌词文件。

## TL;DR

```powershell
.\Merge-Lrc.ps1 -Path "C:\Users\user\Music\*.lrc" -MergeMethod "Merge" -SplitChar " " | Out-File "C:\Users\user\Music\merged.lrc"
```

## 参数说明

| 参数名      | 是否可选 | 默认值 | 说明                                                                                                                                             |
| ----------- | -------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Path        | 否       | 无     | 歌词文件路径，支持通配符。                                                                                                                       |
| MergeMethod | 是       | Merge  | 合并方法。Merge 为合并所有时间相同的行，Intersect 为合并所有时间相同的行并将时间不同的行均分，Union 为合并所有时间相同的行并将时间不同的行合并。 |
| SplitChar   | 是       | 空格   | 分隔符。                                                                                                                                         |
| MaxInterval | 是       | 10     | Intersect 方法的最大间隔。如果两句歌词超过这个间隔将使用 Offset 中定义的长度来确定下一句歌词的时间。                                             |
| Offset      | 是       | 1000   | Intersect 方法的 Offset。最后一句歌词默认使用这个值。如果两句歌词超过这个间隔将使用 Offset 中定义的长度来确定下一句歌词的时间。                  |

## 示例

- 将文件夹中的所有歌词文件合并成一个歌词文件

```powershell
.\Merge-Lrc.ps1 -Path "C:\Users\user\Music\*.lrc" -MergeMethod "Merge" -SplitChar " "
```

- 将文件夹中的所有歌词文件合并成一个歌词文件并保存

```powershell
.\Merge-Lrc.ps1 -Path "C:\Users\user\Music\*.lrc" -MergeMethod "Merge" -SplitChar " " | Out-File "C:\Users\user\Music\merged.lrc"
```

- 将一个混乱的歌词文件整理合并并保存

```powershell
.\Merge-Lrc.ps1 -Path "C:\Users\user\Music\test.lrc" -MergeMethod "Intersect" -SplitChar " " | Out-File "C:\Users\user\Music\test.lrc"
```

- 将一个文件夹下所有的混乱的歌词文件整理合并并保存

```powershell
dir | % { .\Merge-Lrc.ps1 -Path $_.FullName -MergeMethod "Intersect" -SplitChar " " | Out-File $_.FullName }
```

## 合并方法结果

- 输入文件

```lrc
[00:00.00] test
[00:00.00] test
[00:00.00] test
[00:01.00] test
[00:01.00] test
[00:01.00] test
```

- Merge

```lrc
[00:00.00] test test test
[00:01.00] test test test
```

- Intersect

```lrc
[00:00.00] test
[00:00.33] test
[00:00.66] test
[00:01.00] test
[00:01.33] test
[00:01.66] test
```

- Union

```lrc
[00:00.00] test
[00:00.00] test
[00:00.00] test
[00:01.00] test
[00:01.00] test
[00:01.00] test
```
