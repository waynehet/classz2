$headers = @{
    'User-Agent' = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
}

$images = @(
    @{name='theodore_roosevelt.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/1/1c/President_Theodore_Roosevelt%2C_1904.jpg'},
    @{name='george_carlin.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/a/a8/George_Carlin_1992.jpg'},
    @{name='arnold_toynbee.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/7/7c/Arnold_J._Toynbee%2C_c._1930s.jpg'},
    @{name='hegel.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/0/08/Hegel_portrait_by_Schlesinger_1831.jpg'},
    @{name='sir_francis_bacon.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/1/11/Francis_Bacon%2C_Viscount_St_Alban_from_NPG_%282%29.jpg'},
    @{name='henri_bergson.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/4/49/Henri_Bergson.jpg'},
    @{name='kurt_lewin.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/4/42/Kurt_Lewin.jpg'},
    @{name='herman_cain.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/7/7a/Herman_Cain_2008.jpg'},
    @{name='james_baldwin.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/8/81/James_Baldwin_1955.jpg'},
    @{name='groucho_marx.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Groucho_Maris_1955.jpg/400px-Groucho_Maris_1955.jpg'},
    @{name='dwight_eisenhower.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Dwight_Eisenhower%2C_official_photo_portrait%2C_May_1959.jpg/400px-Dwight_Eisenhower%2C_official_photo_portrait%2C_May_1959.jpg'},
    @{name='william_holman_hunt.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/thumb/8/87/William_Holman_Hunt_-_Self-Portrait_-_Google_Art_Project.jpg/400px-William_Holman_Hunt_-_Self-Portrait_-_Google_Art_Project.jpg'},
    @{name='branford_marsalis.jpg'; url='https://upload.wikimedia.org/wikipedia/commons/thumb/3/35/Wynton_Marsalis_001.jpg/400px-Wynton_Marsalis_001.jpg'}
)

$outDir = 'C:\Users\wayne\Projects\classz2\public\assets'

foreach ($img in $images) {
    Write-Host "Downloading $($img.name)..."
    try {
        Invoke-WebRequest -Uri $img.url -Headers $headers -OutFile "$outDir\$($img.name)" -TimeoutSec 30
        Write-Host "  Success!"
    } catch {
        Write-Host "  Failed: $_"
    }
    Start-Sleep -Seconds 2
}