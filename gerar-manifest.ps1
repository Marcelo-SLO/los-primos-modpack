param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$MinecraftVersion = "26.2"
$FabricVersion = "0.19.5"

$GitHubUser = "Marcelo-SLO"
$Repository = "los-primos-modpack"
$Branch = "main"

$Root = $PSScriptRoot
$FilesDirectory = Join-Path $Root "files"
$ManifestPath = Join-Path $Root "manifest.json"

if (-not (Test-Path $FilesDirectory)) {
    throw "A pasta 'files' não existe."
}

$manifestFiles = @()

$files = Get-ChildItem `
    -Path $FilesDirectory `
    -File `
    -Recurse |
    Where-Object {
        $_.Name -ne ".gitkeep"
    } |
    Sort-Object FullName

foreach ($file in $files) {

    $relativePath = $file.FullName.Substring(
        $FilesDirectory.Length
    ).TrimStart('\', '/')

    $relativePath = $relativePath.Replace('\', '/')

    $hash = (
        Get-FileHash `
            -Path $file.FullName `
            -Algorithm SHA256
    ).Hash.ToLowerInvariant()

    $urlPath = "files/$relativePath"

    $url =
        "https://raw.githubusercontent.com/" +
        "$GitHubUser/$Repository/$Branch/$urlPath"

    $manifestFiles += [ordered]@{
        Path     = $relativePath
        Url      = $url
        Sha256   = $hash
        Required = $true
    }
}

$manifest = [ordered]@{
    ModpackName         = "Los Primos"
    Version             = $Version
    MinecraftVersion    = $MinecraftVersion
    FabricLoaderVersion = $FabricVersion
    Files               = $manifestFiles
}

$json = $manifest |
    ConvertTo-Json -Depth 10

[System.IO.File]::WriteAllText(
    $ManifestPath,
    $json,
    [System.Text.UTF8Encoding]::new($false)
)

Write-Host ""
Write-Host "========================================"
Write-Host " LOS PRIMOS - MANIFESTO GERADO"
Write-Host "========================================"
Write-Host ""
Write-Host "Versao: $Version"
Write-Host "Minecraft: $MinecraftVersion"
Write-Host "Fabric: $FabricVersion"
Write-Host "Arquivos encontrados: $($manifestFiles.Count)"
Write-Host ""