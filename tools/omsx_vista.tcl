# omsx_vista.tcl - Congela el estado EXACTO en el que se pinta una fila de la
# vista en perspectiva del campo.
#
# Hace falta porque los buffers de RAM se reutilizan tres veces por cuadro: la
# lista acumulada de codigos de tile vive en 0xE800, pero el scroll usa esa
# misma zona como cache de patrones traidos de la VRAM, y 0xEA00 es a la vez
# el mapa de indices de la vista y un buffer de patrones. Volcar "en un
# momento cualquiera" no dice nada; hay que parar donde toca.
#
# Punto de ruptura en pinta_veintiuna_columnas (0x5B41). La primera vez que
# salta se vuelca la RAM entera de 0xE000 y se anotan HL (el puntero al mapa)
# y DE (la celda de destino). Ademas se anotan las primeras llamadas a
# tile_por_indice (0x5B61) con el byte leido y el codigo que sale.
#
# Variables de entorno: CWO_HOYO, CWO_SALIDA

proc opcion {nombre porDefecto} {
    global env
    if {[info exists env($nombre)]} { return $env($nombre) }
    return $porDefecto
}

set ::SALIDA [opcion CWO_SALIDA {C:/Users/Antxiko/Documents/DES_ASM/desensamblados/CASIOWORLDOPEN_DISAM/work/omsx}]
set ::HOYO [opcion CWO_HOYO 1]
file mkdir $::SALIDA
set ::puesto 0
set ::hecho 0
set ::n 0
set ::log [open $::SALIDA/vista_h$::HOYO.log w]

proc pulsa {} { keymatrixdown 8 0x01 ; after time 0.2 { keymatrixup 8 0x01 } }

# Fuerza el hoyo, una sola vez.
set ::bph [debug set_bp 0x4586 {} {
    if {$::puesto == 0} {
        set ::puesto 1
        debug write memory 0xE0B4 $::HOYO
        debug remove_bp $::bph
    }
}]

# El estado en el que se pinta la vista.
set ::bpv [debug set_bp 0x5B41 {} {
    if {$::hecho == 0} {
        set ::hecho 1
        puts $::log [format {pinta_veintiuna_columnas HL=%04X DE=%04X E0A0=%02X E0AE=%04X} \
            [reg HL] [reg DE] [debug read memory 0xE0A0] \
            [expr {[debug read memory 0xE0AE] + 256*[debug read memory 0xE0AF]}]]
        set ram [debug read_block memory 0xE000 4096]
        set f [open $::SALIDA/vista_ram_h$::HOYO.bin w]
        fconfigure $f -translation binary
        puts -nonewline $f $ram
        close $f
        set v [debug read_block VRAM 0 16384]
        set f [open $::SALIDA/vista_vram_h$::HOYO.bin w]
        fconfigure $f -translation binary
        puts -nonewline $f $v
        close $f
        debug remove_bp $::bpv
    }
}]

# Las primeras lecturas del mapa: puntero, byte leido y codigo que sale.
set ::bpt [debug set_bp 0x5B61 {} {
    set hl0 [reg HL]
    if {$::hecho == 1 && $::n < 420 && $hl0 >= 0xEA00 && $hl0 < 0xEB8F} {
        incr ::n
        set hl [reg HL]
        set idx [debug read memory $hl]
        set p [expr {0xE800 + 2*$idx}]
        set code [expr {[debug read memory $p] + 256*[debug read memory [expr {$p+1}]]}]
        puts $::log [format {  tile HL=%04X DE=%04X idx=%3d code=%d} $hl [reg DE] $idx $code]
    }
}]

after time  7.5 { pulsa }
after time  8.5 { pulsa }
after time  9.5 { pulsa }
after time 11.0 { pulsa }
after time 13.0 { pulsa }
after time 18.0 { catch { close $::log } ; exit }
after realtime 180 { catch { close $::log } ; exit }
