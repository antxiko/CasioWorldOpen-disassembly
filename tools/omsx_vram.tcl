# omsx_vram.tcl - Vuelca la VRAM de verdad de Casio World Open para
# comprobar contra el emulador (no solo leer el listado) que modo de
# pantalla usa de verdad y que hay en la tabla de nombres.
#
# No pone NINGUN punto de ruptura: los volcados van por reloj emulado.
#
# Variables de entorno:
#   CWO_SALIDA  carpeta de salida (por defecto work/omsx)

proc opcion {nombre porDefecto} {
    global env
    if {[info exists env($nombre)]} { return $env($nombre) }
    return $porDefecto
}

set ::SALIDA [opcion CWO_SALIDA {C:/Users/Antxiko/Documents/DES_ASM/CASIOWORLDOPEN_DISAM/work/omsx}]
file mkdir $::SALIDA
set ::n 0

proc vuelca {etiqueta} {
    set i [format %02d $::n]
    incr ::n
    set datos [debug read_block VRAM 0 16384]
    set f [open $::SALIDA/vram_$i.bin w]
    fconfigure $f -translation binary
    puts -nonewline $f $datos
    close $f
    set r {}
    for {set k 0} {$k < 8} {incr k} {
        lappend r [format %02X [debug read {VDP regs} $k]]
    }
    set f [open $::SALIDA/info_$i.txt w]
    puts $f [format {etiqueta %s} $etiqueta]
    puts $f [format {tiempo %s} [machine_info time]]
    puts $f [format {regs %s} [join $r { }]]
    close $f
    catch { screenshot -raw $::SALIDA/pant_$i.png }
}

after time  1.0 { vuelca arranque }
after time  2.0 { vuelca arranque }
after time  3.5 { vuelca arranque }
after time  5.0 { vuelca arranque }
after time  8.0 { vuelca arranque }
after time 12.0 { vuelca arranque }
after time 12.5 { exit }

after realtime 60 {
    puts {PERRO GUARDIAN a los 60 s reales}
    exit
}
