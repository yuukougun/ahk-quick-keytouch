<#
  quick-keytouch.ahk をログオン時に自動起動するよう登録する。

  使い方（リポジトリのフォルダで実行）:
    通常権限で起動 : powershell -ExecutionPolicy Bypass -File .\setup-startup.ps1
    管理者で起動   : powershell -ExecutionPolicy Bypass -File .\setup-startup.ps1 -Admin   （管理者の PowerShell で実行）
    登録解除       : powershell -ExecutionPolicy Bypass -File .\setup-startup.ps1 -Uninstall （タスクも消すなら管理者で実行）

  通常権限      : スタートアップフォルダに、このリポジトリの .ahk へのショートカットを作る
  -Admin        : タスクスケジューラに「ログオン時・最上位の特権で実行」のタスクを登録する
                  （スタートアップフォルダの管理者実行ショートカットは Windows に起動を止められるため）
#>
param(
    [switch]$Admin,
    [switch]$Uninstall
)

$ErrorActionPreference = 'Stop'

$scriptPath   = Join-Path $PSScriptRoot 'quick-keytouch.ahk'
$taskName     = 'ahk-quick-keytouch'
$startupDir   = [Environment]::GetFolderPath('Startup')
$shortcutPath = Join-Path $startupDir 'quick-keytouch.lnk'

function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Get-AhkExe {
    $dir = (Get-ItemProperty 'HKLM:\SOFTWARE\AutoHotkey' -ErrorAction SilentlyContinue).InstallDir
    if (-not $dir) { $dir = Join-Path $env:ProgramFiles 'AutoHotkey' }
    # v2 のインストーラーは本体を v2 フォルダに置く
    $name = if ([Environment]::Is64BitOperatingSystem) { 'AutoHotkey64.exe' } else { 'AutoHotkey32.exe' }
    $exe = Join-Path $dir "v2\$name"
    if (-not (Test-Path $exe)) { throw "AutoHotkey v2 が見つかりません: $exe" }
    $exe
}

function Remove-Shortcut {
    if (Test-Path $shortcutPath) {
        Remove-Item $shortcutPath
        Write-Host "ショートカットを削除しました: $shortcutPath"
    }
}

function Remove-Task {
    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        if (-not (Test-IsAdmin)) {
            Write-Warning "タスク '$taskName' の削除には管理者権限が必要です。管理者の PowerShell で -Uninstall を実行してください。"
            return
        }
        Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        Write-Host "タスクを削除しました: $taskName"
    }
}

if ($Uninstall) {
    Remove-Shortcut
    Remove-Task
    return
}

if (-not (Test-Path $scriptPath)) { throw "スクリプトが見つかりません: $scriptPath" }

if ($Admin) {
    if (-not (Test-IsAdmin)) { throw '-Admin は管理者として開いた PowerShell で実行してください。' }

    $ahk      = Get-AhkExe
    $action   = New-ScheduledTaskAction -Execute $ahk -Argument "`"$scriptPath`"" -WorkingDirectory $PSScriptRoot
    $trigger  = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
    $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest
    # 既定だと「バッテリー駆動時は起動しない」「3日で停止」になるので外す
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero) -MultipleInstances IgnoreNew

    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Write-Host "タスクを登録しました（管理者で起動）: $taskName"

    # 二重起動を防ぐため、通常権限のショートカットは消しておく
    Remove-Shortcut
}
else {
    $shell = New-Object -ComObject WScript.Shell
    $lnk = $shell.CreateShortcut($shortcutPath)
    $lnk.TargetPath       = $scriptPath
    $lnk.WorkingDirectory = $PSScriptRoot
    $lnk.Save()
    Write-Host "ショートカットを作成しました: $shortcutPath -> $scriptPath"

    if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
        Write-Warning "管理者起動のタスク '$taskName' も残っています。二重起動を避けるため、管理者で -Uninstall してから実行し直してください。"
    }
}
