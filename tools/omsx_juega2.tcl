# omsx_juega2.tcl - Igual que omsx_juega.tcl pero tambien vuelca los
# registros del VDP para confirmar el modo de pantalla real del juego.

set ::SALIDA {C:/Users/Antxiko/Documents/DES_ASM/desensamblados/CASIOWORLDOPEN_DISAM/work/omsx}
file mkdir $::SALIDA
set ::n 0

proc vuelca {etiqueta} {
    set i [format %02d $::n]
    incr ::n
    set datos [debug read_block VRAM 0 16384]
    set f [open $::SALIDA/k_vram_$i.bin w]
    fconfigure $f -translation binary
    puts -nonewline $f $datos
    close $f
    set r {}
    for {set k 0} {$k < 8} {incr k} {
        lappend r [format %02X [debug read {VDP regs} $k]]
    }
    set f [open $::SALIDA/k_info_$i.txt w]
    puts $f [format {etiqueta %s} $etiqueta]
    puts $f [format {tiempo %s} [machine_info time]]
    puts $f [format {regs %s} [join $r { }]]
    close $f
    catch { screenshot -raw $::SALIDA/k_pant_$i.png }
}

proc pulsa {} {
    keymatrixdown 8 0x01
    after time 0.2 suelta
}
proc suelta {} {
    keymatrixup 8 0x01
}

after time  7.5 { pulsa }
after time  8.5 { pulsa }
after time  9.5 { pulsa }
after time 11.0 { pulsa }
after time 13.0 { pulsa }
after time 14.5 { vuelca juego }
after time 15.0 { exit }

after realtime 60 {
    puts {PERRO GUARDIAN a los 60 s reales}
    exit
}
