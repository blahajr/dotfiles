try {
    [Console]::InputEncoding  = [System.Text.Encoding]::UTF8
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    chcp 65001 > $null
} catch {}

Clear-Host


if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch -c "$HOME\.config\fastfetch\config.jsonc"
}


oh-my-posh init pwsh `
    --config "$HOME\.config\psh\config.toml" | Invoke-Expression


Invoke-Expression (& {
    zoxide init powershell | Out-String
})


Import-Module PSFzf
Import-Module Terminal-Icons

# PSFzf
Set-PsFzfOption `
    -EnableFd `
    -PSReadlineChordProvider 'Ctrl+t' `
    -PSReadlineChordReverseHistory 'Ctrl+r'

# FZF defaults
$env:FZF_DEFAULT_COMMAND = @"
fd --type f `
   --hidden `
   --exclude .git `
   --exclude venv `
   --exclude .venv `
   --exclude node_modules `
   --exclude dist `
   --exclude build
"@

$env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND

# opens in vsc
function vf {
    $file = fzf

    if ($file) {
        code $file
    }
}

#cd 
function cf {
    $dir = fd --type d | fzf

    if ($dir) {
        Set-Location $dir
    }
}