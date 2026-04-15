$bookmarksPath = "$env:LOCALAPPDATA\Vivaldi\User Data\Default\Bookmarks"
$b = Get-Content $bookmarksPath -Raw -Encoding UTF8 | ConvertFrom-Json
$bookmarksFolder = $b.roots.bookmark_bar.children[1]
Write-Host "Checking 'Bookmarks' folder (id=$($bookmarksFolder.id))"
Write-Host "Children count: $($bookmarksFolder.children.Count)"
for ($i = 0; $i -lt 10; $i++) {
    $c = $bookmarksFolder.children[$i]
    Write-Host "Child $i : $($c.name) (type=$($c.type))"
}