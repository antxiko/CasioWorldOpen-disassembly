# omsx_vram_hoyo.tcl - Vuelca la VRAM de un hoyo CONCRETO de Casio World Open.
#
# La partida siempre empieza por el hoyo 1, y el 1 NO es de los que se dibujan
# espejados. Para comprobar el espejo hay que llevar al cartucho a uno de los
# ocho que si lo son (2, 4, 5, 6, 8, 12, 13 y 17), y jugarselos no es opcion.
#
# En vez de eso, UN SOLO punto de ruptura en lee_la_ficha_del_hoyo (0x4586)
# que, la primera vez que salta, escribe en (0xE0B4) el hoyo que se le pida y
# se quita. De ahi salen la ficha de datos_por_hoyo -y con ella el bit 7 de
# (0xE0A0), que es el espejo-, el puntero de tabla_planos_de_hoyo en 0x5DFB y
# la lista de objetos en 0x6289, asi que el cartucho monta ese hoyo como si le
# tocara. Salta UNA vez, no cada cuadro.
#
# Variables de entorno:
#   CWO_HOYO     el hoyo, de 1 a 18
#   CWO_SALIDA   carpeta de salida
#
#   "C:/Program Files/openMSX/openmsx.exe" -machine Philips_VG_8020 \
#       -cart casioworldopen.rom -script tools/omsx_vram_hoyo.tcl

proc opcion {nombre porDefecto} {
    global env
    if {[info exists env($nombre)]} { return $env($nombre) }
    return $porDefecto
}

set ::SALIDA [opcion CWO_SALIDA {C:/Users/Antxiko/Documents/DES_ASM/desensamblados/CASIOWORLDOPEN_DISAM/work/omsx}]
set ::HOYO [opcion CWO_HOYO 1]
file mkdir $::SALIDA
set ::n 0
set ::puesto 0

proc vuelca {etiqueta} {
    set i [format {h%02dd%02d} $::HOYO $::n]
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
    foreach {nombre dir} {hoyo 0xE0B4 terreno 0xE0A0 par 0xE09F
                          p1 0xE0A1 p2 0xE0A2 p3 0xE0A3 p4 0xE0A4} {
        puts $f [format {%s %d} $nombre [debug read memory $dir]]
    }
    close $f
    # La RAM que importa: 0xE800 es la lista acumulada de codigos de tile y
    # 0xEA00 el mapa de indices de la vista en perspectiva (19x21).
    set ram [debug read_block memory 0xE000 4096]
    set f [open $::SALIDA/ram_$i.bin w]
    fconfigure $f -translation binary
    puts -nonewline $f $ram
    close $f
    catch { screenshot -raw $::SALIDA/pant_$i.png }
}

# El espacio es lo que el cartucho toma por disparo para pasar del titulo.
proc pulsa {} {
    keymatrixdown 8 0x01
    after time 0.2 suelta
}
proc suelta {} {
    keymatrixup 8 0x01
}

# El punto de ruptura: salta la primera vez que el cartucho lee la ficha del
# hoyo, cambia el numero y se borra. Nada de condiciones por cuadro.
set ::bp [debug set_bp 0x4586 {} {
    if {$::puesto == 0} {
        set ::puesto 1
        debug write memory 0xE0B4 $::HOYO
        debug remove_bp $::bp
    }
}]

after time  7.5 { pulsa }
after time  8.5 { pulsa }
after time  9.5 { pulsa }
after time 11.0 { pulsa }
after time 13.0 { pulsa }
after time 17.0 { vuelca hoyo }
after time 19.0 { vuelca hoyo }
after time 20.0 { exit }

after realtime 180 {
    puts {PERRO GUARDIAN a los 180 s reales}
    exit
}
