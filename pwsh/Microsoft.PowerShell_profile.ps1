oh-my-posh init pwsh --config "~/hul10.omp.json" | Invoke-Expression
Import-Module TabExpansionPlusPlus
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
$env:FZF_DEFAULT_OPTS = '--height 40% --layout=reverse --border --color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6,marker:#ff79c6,spinner:#ffb86c,header:#6272a4'
$PSDefaultParameterValues['Select-String:EmphasisColor'] = 'Magenta'
# --- 常用别名 ---
Set-Alias -Name man -Value Get-Help
Set-Alias -Name find -Value find-name
# 初始化 zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# --- 带参数命令 ---

# lsd增强配置
# ls：彩色列表显示
function ls { lsd --icon always --color always $args }
# ll：详细列表（显示大小、时间、权限）
function ll { lsd -l --header $args }
# la：显示隐藏文件
function la { lsd -a $args }
# lt：树状视图（看项目结构神技，限深3层防止刷屏）
function lt { lsd --tree --depth 3 $args }

function touch { New-Item -ItemType File -Path $args }
function export { $name, $value = $args[0].Split('='); Set-Item -Path "Env:$name" -Value $value }
function which {
    param($name)
    (Get-Command $name -ErrorAction SilentlyContinue).Source
}
function ports {
    Get-NetTCPConnection -State Establish,Listen | Select-Object LocalAddress,LocalPort,RemoteAddress,State
}
function find-name {
    param($name)
    Get-ChildItem -Recurse -Filter "*$name*" -ErrorAction SilentlyContinue
}
function head { param($Path, $n = 10); Get-Content $Path -TotalCount $n }
function tailf { param($Path); Get-Content $Path -Wait -Tail 10 }
function df {
    Get-Volume | Select-Object DriveLetter, FileSystemLabel, 
    @{Name="Size(GB)";Expression={"{0:N2}" -f ($_.Size/1GB)}},
    @{Name="FreeSpace(GB)";Expression={"{0:N2}" -f ($_.SizeRemaining/1GB)}},
    @{Name="Usage(%)";Expression={"{0:N2}" -f ((1 - $_.SizeRemaining/$_.Size)*100)}} | 
    Format-Table -AutoSize
}
function top { btop }
function watch {
    param([scriptblock]$s, [int]$n = 2)
    while($true) {
        clear-host
        Write-Host "Watching command: $s (Every $n seconds) - Press Ctrl+C to stop" -ForegroundColor Yellow
        & $s
        Start-Sleep -Seconds $n
    }
}
function image {
    param(
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]$Path,
        [string]$Size = "80x30" # 默认尺寸：宽80，高30
    )
    if (-not $Path) {
        Write-Host "🧛‍♂️ 用法: image <路径> [-Size 宽x高]" -ForegroundColor Magenta
        return
    }
    foreach ($f in $Path) {
        if (Test-Path $f) {
            & chafa --size $Size $f
            Write-Host "预览尺寸: $Size | 文件: $f" -ForegroundColor Cyan
        }
    }
    Write-Host -NoNewline "$([char]27)[0m"
}
# 使用 zoxide 跳转并列出文件
function zi {
    # 这样写可以确保即使中途 Esc 退出搜索，也不会报错
    $path = zoxide query -i
    if ($path -and (Test-Path $path)) {
        Set-Location $path
        lsd --grid # 跳转后用网格模式列出，比单列显示更省空间
    }
}
function Lock-FastFetch {
    Write-Host -NoNewline ([char]27 + "[?25l")
    [System.Console]::Clear()
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    fastfetch
    $raw = $Host.UI.RawUI
    $raw.BufferSize = New-Object System.Management.Automation.Host.Size ($raw.WindowSize.Width, $raw.WindowSize.Height)
    $raw.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
}
