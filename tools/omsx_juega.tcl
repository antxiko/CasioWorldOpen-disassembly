# omsx_juega.tcl - Pulsa el boton de disparo del joystick para pasar de la
# pantalla de titulo de Casio World Open, y vuelca VRAM+RAM (0xE09A/0xE09C)
# en varios instantes para ver el hoyo real cargado.

set ::SALIDA {C:/Users/Antxiko/Documents/DES_ASM/CASIOWORLDOPEN_DISAM/work/omsx}
file mkdir $::SALIDA
set ::n 0

proc vuelca {etiqueta} {
    set i [format %02d $::n]
    incr ::n
    set datos [debug read_block VRAM 0 16384]
    set f [open $::SALIDA/j_vram_$i.bin w]
    fconfigure $f -translation binary
    puts -nonewline $f $datos
    close $f
    set e09a [debug read memory 0xE09A]
    set e09b [debug read memory 0xE09B]
    set e09c [debug read memory 0xE09C]
    set e09d [debug read memory 0xE09D]
    set f [open $::SALIDA/j_info_$i.txt w]
    puts $f [format {etiqueta %s} $etiqueta]
    puts $f [format {tiempo %s} [machine_info time]]
    puts $f [format {E09A=%02X%02X E09C=%02X%02X} $e09b $e09a $e09d $e09c]
    close $f
    catch { screenshot -raw $::SALIDA/j_pant_$i.png }
}

# gatillo del joystick 1 = "pinstate" del puerto de joystick; mas simple:
# simular la tecla de espacio, que muchos juegos MSX tratan como disparo
proc pulsa {} {
    keymatrixdown 8 0x01
    after time 0.2 suelta
}
proc suelta {} {
    keymatrixup 8 0x01
}

after time  7.0 { vuelca titulo }
after time  7.5 { pulsa }
after time  8.5 { pulsa }
after time  9.5 { pulsa }
after time 10.0 { vuelca tras_pulsar }
after time 11.0 { pulsa }
after time 12.0 { vuelca tras_pulsar2 }
after time 13.0 { pulsa }
after time 14.5 { vuelca tras_pulsar3 }
after time 15.0 { exit }

after realtime 60 {
    puts {PERRO GUARDIAN a los 60 s reales}
    exit
}
