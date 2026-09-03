# omsx_quien_sprites.tcl - Quien llena la tabla de PATRONES DE SPRITE del VDP.
#
# En la pantalla de juego hay 58 sprites de 16x16 cargados (1872 bytes desde
# VRAM 0x3800), pero 0x60A2 solo copia los diez primeros. El golfista son los
# patrones 96 a 124 -ocho sprites superpuestos, uno por color- y no salen de
# ahi. Esto anota cada LDIRVM (BIOS 0x005C) cuyo destino cae en la tabla de
# patrones de sprite, con el origen y la direccion de retorno, que es la que
# dice QUE rutina lo ha escrito.
#
# Variables de entorno: CWO_HOYO, CWO_SALIDA

proc opcion {nombre porDefecto} {
    global env
    if {[info exists env($nombre)]} { return $env($nombre) }
    return $porDefecto
}

set ::SALIDA [opcion CWO_SALIDA {C:/Users/Antxiko/Documents/DES_ASM/CASIOWORLDOPEN_DISAM/work/omsx}]
set ::HOYO [opcion CWO_HOYO 5]
file mkdir $::SALIDA
set ::log [open $::SALIDA/sprites_h$::HOYO.log w]
set ::n 0
set ::puesto 0
set ::visto {}

proc pulsa {} { keymatrixdown 8 0x01 ; after time 0.2 { keymatrixup 8 0x01 } }

set ::bph [debug set_bp 0x4586 {} {
    if {$::puesto == 0} {
        set ::puesto 1
        debug write memory 0xE0B4 $::HOYO
        debug remove_bp $::bph
    }
}]

# LDIRVM: HL origen, DE destino VRAM, BC cuenta.
set ::bp [debug set_bp 0x005C {} {
    set de [reg DE]
    if {(($de >= 0x3800 && $de < 0x4000) || ($de >= 0x1B00 && $de < 0x1C00)) && $::n < 300} {
        set sp [reg SP]
        set ret [expr {[debug read memory $sp] + 256*[debug read memory [expr {$sp+1}]]}]
        set clave [format {%04X-%04X} $ret $de]
        if {[lsearch -exact $::visto $clave] < 0} {
            lappend ::visto $clave
            incr ::n
            puts $::log [format {ret=%04X  origen=%04X  destino=%04X  bytes=%d} \
                $ret [reg HL] $de [reg BC]]
        }
    }
}]

after time  7.5 { pulsa }
after time  8.5 { pulsa }
after time  9.5 { pulsa }
after time 11.0 { pulsa }
after time 13.0 { pulsa }
after time 22.0 { catch { close $::log } ; exit }
after realtime 180 { catch { close $::log } ; exit }
