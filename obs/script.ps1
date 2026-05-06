
$obsPath = "$env:USERPROFILE\.config\obs\config"

$username = $env:USERNAME

Write-Host "Using username: $username"

Get-ChildItem -Path $obsPath -Recurse -File | ForEach-Object {

    $file = $_.FullName

    try {
        $content = Get-Content $file -Raw

        if ($content -match "%user%") {

            Copy-Item $file "$file.bak" -Force

            $newContent = $content -replace "%user%", $username

            Set-Content -Path $file -Value $newContent -Encoding UTF8

            Write-Host "Updated: $file"
        }
    }
    catch {
        Write-Warning "Failed to process $file : $_"
    }
}