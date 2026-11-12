# lanza_graba.ps1 -rom x.rom -guion guion.tcl -salida work/x.bin [-bp 0x0038] [-ram "0xE000 0x1000"] [-maquina Philips_VG_8020] [-rom2 otro.rom]
# -rom2: otro cartucho en el segundo slot (aqui, el primer Iga Ninpouchou)
# UN openMSX con tools/omsx_graba.tcl, fuera del sandbox, minimizado
param([string]$rom, [string]$guion, [string]$salida, [string]$bp = "0x0038", [string]$ram = "0xE000 0x1000", [string]$bp2 = "", [string]$maquina = "Philips_VG_8020", [string]$rom2 = "")
$env:GRABA_SALIDA = $salida
$env:GRABA_GUION = $guion
$env:GRABA_BP = $bp
$env:GRABA_RAM = $ram
if ($bp2) { $env:GRABA_BP2 = $bp2 } else { Remove-Item Env:GRABA_BP2 -ErrorAction SilentlyContinue }
$args_ = @("-machine", $maquina, "-cart", $rom, "-script", "tools/omsx_graba.tcl")
if ($rom2) { $args_ = @("-machine", $maquina, "-cart", $rom, "-cartb", $rom2, "-script", "tools/omsx_graba.tcl") }
Start-Process -FilePath "C:\Program Files\openMSX\openmsx.exe" -ArgumentList $args_ -Wait -WindowStyle Minimized
