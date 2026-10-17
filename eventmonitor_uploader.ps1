# EventMonitor screenshot uploader — PowerShell (nativo do Windows, nao instala nada)
#
# Observa %USERPROFILE%\Zomboid\Screenshots e envia cada PNG novo para o bot:
#   powershell -ExecutionPolicy Bypass -File eventmonitor_uploader.ps1 -Url http://172.25.64.1:3100/upload
#
# Sem -Url: modo teste (so lista os novos arquivos).
# Rodar dentro de um .bat no inicializador do Windows para ficar permanente:
#   start /min powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "c:\caminho\eventmonitor_uploader.ps1" -Url "http://172.25.64.1:3100/upload"

param(
    [string]$Url = "",
    [int]$IntervalSeconds = 5
)

# URL padrao vem de config.txt ao lado do script (gerado pelo install.bat)
if ($Url -eq "") {
    $cfg = Join-Path $PSScriptRoot "config.txt"
    if (Test-Path $cfg) {
        try { $Url = (Get-Content $cfg -Raw).Trim() } catch { $Url = "" }
    }
}
# destino SEMPRE do endpoint.txt (definido pelo servidor no jogo);
# -Url divergente bloqueia (consentimento esta ligado a URL do servidor)
if ($Url -ne "" -and $Url -ne (Get-Endpoint)) {
    Write-Host "BLOQUEADO: -Url diverge do endpoint definido pelo servidor (endpoint.txt)"
    $Url = ""
}
if ($Url -eq "") { $Url = Get-Endpoint }

$Shots = Join-Path $env:USERPROFILE "Zomboid\Screenshots"
# Arquivos gravados pelo MOD no jogo (Zomboid\Lua\EventMonitor\):
#   endpoint.txt -> URL de upload definida pelo SERVIDOR em que o jogador esta
#   consent.txt  -> "yes|<url>" (aceito PARA essa url) ou "no"
# Envio so acontece se consent.txt for "yes|" + EXATAMENTE a url do endpoint.txt.
$ConsentFile = Join-Path $env:USERPROFILE "Zomboid\Lua\EventMonitor\consent.txt"
$EndpointFile = Join-Path $env:USERPROFILE "Zomboid\Lua\EventMonitor\endpoint.txt"

function Get-Endpoint {
    if (-not (Test-Path $EndpointFile)) { return "" }
    try { return (Get-Content $EndpointFile -Raw).Trim() } catch { return "" }
}

function Test-Consent([string]$target) {
    if ([string]::IsNullOrEmpty($target)) { return $false }
    if (-not (Test-Path $ConsentFile)) { return $false }
    try {
        return ((Get-Content $ConsentFile -Raw).Trim().ToLower() -eq ("yes|" + $target.ToLower()))
    } catch { return $false }
}
if (-not (Test-Path $Shots)) { New-Item -ItemType Directory -Path $Shots | Out-Null }

Write-Host "observando $Shots"
$seen = @{}
Get-ChildItem -Path $Shots -Filter *.png -ErrorAction SilentlyContinue | ForEach-Object { $seen[$_.Name] = $true }
Write-Host ("{0} screenshots antigas ignoradas" -f $seen.Count)

while ($true) {
    $news = Get-ChildItem -Path $Shots -Filter *.png -ErrorAction SilentlyContinue |
        Where-Object { -not $seen.ContainsKey($_.Name) }
    foreach ($f in $news) {
        # espera o arquivo terminar de ser gravado
        $s1 = $f.Length
        Start-Sleep -Seconds 1
        $f.Refresh()
        if ($f.Length -ne $s1) { continue }
        $seen[$f.Name] = $true
        if ($Url -eq "") {
            Write-Host ("[teste] novo: {0} ({1} bytes)" -f $f.Name, $f.Length)
            continue
        }
        if (-not (Test-Consent $Url)) {
            Write-Host ("ignorado (consentimento 'yes|<url>' nao confere com o endpoint atual): {0}" -f $f.Name)
            continue
        }
        try {
            # curl.exe vem com o Windows 10/11 — multipart sem dependencias
            & curl.exe -sS -m 30 -X POST $Url `
                -F "caption=[EventMonitor] $($f.BaseName)" `
                -F "file=@$($f.FullName);type=image/png" | Out-Null
            Write-Host ("enviado: {0}" -f $f.Name)
        } catch {
            Write-Host ("ERRO enviando {0}: {1}" -f $f.Name, $_.Exception.Message)
        }
    }
    Start-Sleep -Seconds $IntervalSeconds
}
