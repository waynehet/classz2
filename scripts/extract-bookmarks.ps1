# Vivaldi Bookmark Extractor
# Extracts bookmarks from "Wayne's Stuff" folder and saves to JSON

$ErrorActionPreference = "Stop"

$bookmarksPath = "$env:LOCALAPPDATA\Vivaldi\User Data\Default\Bookmarks"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = (Get-Item $scriptDir).Parent.FullName
$outputPath = Join-Path $rootDir "src\data\bookmarks.json"
$mdPath = Join-Path $rootDir "src\content\bookmarks\links.md"

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

# Find "Wayne's Stuff" folder - it's nested inside the "Bookmarks" folder
$bookmarksFolder = $bookmarksJson.roots.bookmark_bar.children | Where-Object { $_.name -eq "Bookmarks" -and $_.type -eq "folder" }
if ($bookmarksFolder) {
    $waynesStuff = $bookmarksFolder.children | Where-Object { $_.name -eq "Wayne's Stuff" }
}

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

# Generate Markdown
$markdown = "# Links`n`n"
$markdown += "Extracted: $($data.extracted)`n`n"

function Add-MarkdownNode {
    param($node, [int]$depth = 0)
    
    $result = ""
    
    if ($node.type -eq 'folder' -and $node.children) {
        if ($depth -gt 0) {
            $headerLevel = if ($depth -eq 1) { "##" } else { "###" }
            $result += "`n$headerLevel $($node.name)`n"
        }
        
        foreach ($child in $node.children) {
            $result += Add-MarkdownNode -node $child -depth ($depth + 1)
        }
    }
    elseif ($node.type -eq 'url' -and $node.url) {
        $title = if ($node.name) { $node.name } else { "Untitled" }
        $result += "- [$title]($($node.url))`n"
    }
    
    return $result
}

foreach ($child in $extracted.children) {
    if ($child.type -eq 'folder') {
        $markdown += Add-MarkdownNode -node $child -depth 1
    }
    elseif ($child.type -eq 'url' -and $child.url) {
        $markdown += "`n## Other`n"
        $title = if ($child.name) { $child.name } else { "Untitled" }
        $markdown += "- [$title]($($child.url))`n"
    }
}

# Save JSON (for potential other uses)
$data | ConvertTo-Json -Depth 100 | Set-Content -Path $outputPath -Encoding UTF8

# Save Markdown
$markdown | Set-Content -Path $mdPath -Encoding UTF8

Write-Host "SUCCESS: Bookmarks extracted"
Write-Host "  JSON: $outputPath"
Write-Host "  Markdown: $mdPath"
Write-Host "  Extracted $($extracted.children.Count) top-level folders"