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
[00:10.00][00:00.00][00:01.00]This is the original text.
[00:05.00]This is the next text.
[00:05.00]这是第二句。
[00:10.00][00:00.00][00:01.00]这是中文翻译。
```

- Merge

```lrc
[00:00.00]This is the original text. 这是中文翻译。
[00:01.00]This is the original text. 这是中文翻译。
[00:05.00]This is the next text. 这是第二句。
[00:10.00]This is the original text. 这是中文翻译。
```

- Intersect

```lrc
[00:00.00]This is the original text.
[00:00.50]这是中文翻译。
[00:01.00]This is the original text.
[00:03.00]这是中文翻译。
[00:05.00]This is the next text.
[00:07.50]这是第二句。
[00:10.00]This is the original text.
[00:11.00]这是中文翻译。
```

- Union

```lrc
[00:00.00]This is the original text.
[00:00.00]这是中文翻译。
[00:01.00]This is the original text.
[00:01.00]这是中文翻译。
[00:05.00]This is the next text.
[00:05.00]这是第二句。
[00:10.00]This is the original text.
[00:10.00]这是中文翻译。
```
