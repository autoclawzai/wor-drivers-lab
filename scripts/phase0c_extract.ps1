# Phase 0c (Windows runner): extract rtwlanu.sys / netrtwlanu.inf from the nested InstallShield exe.
$ErrorActionPreference = "Continue"
$root = Join-Path $PWD "work"
$out  = Join-Path $PWD "out"
New-Item -ItemType Directory -Force $root, $out, "$out\drv" | Out-Null
$log = Join-Path $out "extract_log.txt"
function Log($m) { $line = "[{0}] {1}" -f (Get-Date -Format s), $m; $line | Tee-Object -FilePath $log -Append }

$zip = Join-Path $root "win.zip"
Invoke-WebRequest -UserAgent "Mozilla/5.0" -OutFile $zip -Uri "https://static.tp-link.com/2018/201808/20180820/TL-WN722N(EUUSES)_V3_180807_Win.zip"
Log ("zip sha256 " + (Get-FileHash $zip -Algorithm SHA256).Hash)
Expand-Archive $zip -DestinationPath "$root\win" -Force
7z x -y "-o$root\outer" "$root\win\Setup.exe" | Out-Null
$inner = Get-ChildItem "$root\outer" -Recurse -Filter Setup.exe | Where-Object { $_.FullName -like "*Driver Files*" } | Select-Object -First 1
Log ("inner exe: " + $inner.FullName + " size " + $inner.Length)

# attempt 1: InstallShield extract_all
$a1 = Join-Path $root "is_extract_all"
New-Item -ItemType Directory -Force $a1 | Out-Null
$p = Start-Process -FilePath $inner.FullName -ArgumentList "/extract_all:`"$a1`"" -PassThru -WindowStyle Hidden
if (-not $p.WaitForExit(120000)) { $p.Kill(); Log "attempt1 timeout" } else { Log "attempt1 exit $($p.ExitCode)" }

# attempt 2: /b extract path + silent response file
$a2 = Join-Path $root "is_b"
New-Item -ItemType Directory -Force $a2 | Out-Null
$iss = Join-Path $inner.DirectoryName "setup.iss"
$p = Start-Process -FilePath $inner.FullName -ArgumentList "/b`"$a2`"", "/s", "/f1`"$iss`"", "/f2`"$root\is_silent.log`"" -PassThru -WindowStyle Hidden
if (-not $p.WaitForExit(180000)) { $p.Kill(); Log "attempt2 timeout" } else { Log "attempt2 exit $($p.ExitCode)" }
if (Test-Path "$root\is_silent.log") { Get-Content "$root\is_silent.log" | Out-File "$out\is_silent.log" }

# collect: search likely places for the driver files
$roots = @($root, $env:TEMP, "C:\Program Files", "C:\Program Files (x86)", "C:\ProgramData", "C:\Windows\System32\drivers", "C:\Windows\INF", "C:\Windows\System32\DriverStore\FileRepository")
$pat = "rtwlanu*", "netrtwlanu*", "RtlExtUI*", "Rtlihvs*", "rtlCoInst*"
$found = foreach ($r in $roots) { if (Test-Path $r) { Get-ChildItem $r -Recurse -Include $pat -File -ErrorAction SilentlyContinue } }
$found | Sort-Object FullName -Unique | ForEach-Object {
    Log ("FOUND {0} {1} bytes" -f $_.FullName, $_.Length)
    $dest = Join-Path "$out\drv" ($_.FullName -replace '[:\\ ]', '_')
    Copy-Item $_.FullName $dest -ErrorAction SilentlyContinue
}
Get-ChildItem $a1, $a2 -Recurse -File -ErrorAction SilentlyContinue | Select-Object FullName, Length | Format-Table -AutoSize | Out-String -Width 250 | Out-File "$out\extract_tree.txt"
Log "done"
