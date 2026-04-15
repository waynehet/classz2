# Vivaldi Bookmark Extractor
# Extracts bookmarks from "Wayne's Stuff" folder and saves to JSON

$ErrorActionPreference = "Stop"

$bookmarksPath = "$env:LOCALAPPDATA\Vivaldi\User Data\Default\Bookmarks"
$outputPath = "src\data\bookmarks.json"

Write-Host "Reading Vivaldi bookmarks from: $bookmarksPath"

if (-not (Test-Path $bookmarksPath)) {
    Write-Host "ERROR: Bookmarks file not found at $bookmarksPath"
    exit 1
}

$bookmarksJson = Get-Content $bookmarksPath -Raw -Encoding UTF8 | ConvertFrom-Json

function Find-WaynesStuff {
    param($roots, [string]$targetName = "Wayne's Stuff")
    
    foreach ($folder in $roots) {
        if ($folder.name -eq $targetName) {
            return $folder
        }
    }
    return $null
}

function Extract-Bookmarks {
    param($node, [string]$path = "")
    
    $results = @{
        name = $node.name
        type = $node.type
        url = $node.url
        children = @()
    }
    
    if ($node.children) {
        foreach ($child in $node.children) {
            $results.children += Extract-Bookmarks -node $child -path ($path + "\" + $node.name)
        }
    }
    
    return $results
}

# Find "Wayne's Stuff" folder
$roots = $bookmarksJson.roots
$waynesStuff = Find-WaynesStuff -roots $roots

if (-not $waynesStuff) {
    Write-Host "ERROR: 'Wayne's Stuff' folder not found"
    exit 1
}

Write-Host "Found 'Wayne's Stuff' folder"

# Extract bookmarks from Wayne's Stuff (skip the root folder itself, include children)
$extracted = @{
    name = $waynesStuff.name
    type = $waynesStuff.type
    children = @()
}

foreach ($child in $waynesStuff.children) {
    $child
    $extracted.children += Extract-Bookmarks -node $child -path ("Wayne's Stuff")
}

$data = @{
    root = $extracted
    extracted = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

# Ensure output directory exists
$outputDir = Split-Path -Parent $outputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$data | ConvertTo-Json -Depth 100 | Set-Content -Path $outputPath -Encoding UTF8

Write-Host "SUCCESS: Bookmarks extracted to $outputPath"
Write-Host "Extracted $($extracted.children.Count) top-level folders"