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
