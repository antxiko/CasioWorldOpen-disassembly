# omsx_mide_e09a.tcl - Mide (0xE09A)/(0xE09C) y el PC en varios instantes
# del arranque de Casio World Open, para saber que cuenta usa de verdad
# L_411A en vez de seguir adivinando en estatico.

set ::SALIDA {C:/Users/Antxiko/Documents/DES_ASM/desensamblados/CASIOWORLDOPEN_DISAM/work/omsx}
file mkdir $::SALIDA
set ::f [open $::SALIDA/e09a.log w]

proc mide {etiqueta} {
    set e09a [debug read memory 0xE09A]
    set e09b [debug read memory 0xE09B]
    set e09c [debug read memory 0xE09C]
    set e09d [debug read memory 0xE09D]
    set pc [reg PC]
    puts $::f [format {t=%6.2f  %-12s PC=%04X E09A=%02X%02X E09C=%02X%02X} \
        [machine_info time] $etiqueta $pc $e09b $e09a $e09d $e09c]
    flush $::f
}

for {set t 0.3} {$t < 12.0} {set t [expr {$t + 0.3}]} {
    after time $t [list mide arranque]
}
after time 12.2 { close $::f ; exit }

after realtime 60 {
    puts {PERRO GUARDIAN a los 60 s reales}
    exit
}
