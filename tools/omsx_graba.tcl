# omsx_graba.tcl - el cartucho grabado en openMSX, cuadro a cuadro, para pintarlo
# con tools/vdp.py. En cada entrada de la interrupcion (GRABA_BP, la direccion
# del gancho del juego) se graba:
#   V  los 8 registros del VDP, la RAM de GRABA_RAM (desde, cuantos), los 16
#      registros del PSG, el tiempo emulado (double) y los
#      trozos de 1 KB de la VRAM que han cambiado desde el anterior (cuantos en
#      un byte, cada uno con su numero en un byte)
#
# GRABA_SALIDA  el fichero
# GRABA_GUION   un fichero Tcl que define `proc guion {n} {...}`: se llama en
#               cada cuadro con su numero y devuelve 1 para acabar
set ::f [open $::env(GRABA_SALIDA) w]
fconfigure $::f -translation binary
set throttle off
set ::n 0
set ::previa ""
set ::ram_ini [lindex $::env(GRABA_RAM) 0]
set ::ram_n [lindex $::env(GRABA_RAM) 1]
proc m {a} { return [debug read memory $a] }
proc tecla {fila bit} { keymatrixdown $fila $bit }
proc suelta {fila bit} { keymatrixup $fila $bit }
source $::env(GRABA_GUION)
proc entra {} {
    set v [debug read_block VRAM 0 0x4000]
    set trozos ""
    set k 0
    for {set i 0} {$i < 16} {incr i} {
        set t [string range $v [expr {$i * 1024}] [expr {$i * 1024 + 1023}]]
        if {$::previa eq "" || ![string equal $t [string range $::previa [expr {$i * 1024}] [expr {$i * 1024 + 1023}]]]} {
            append trozos [binary format c $i] $t
            incr k
        }
    }
    set ::previa $v
    puts -nonewline $::f "V[debug read_block {VDP regs} 0 8][debug read_block memory $::ram_ini $::ram_n][debug read_block {PSG regs} 0 16][binary format d [machine_info time]][binary format c $k]$trozos"
    incr ::n
    if {[guion $::n]} { close $::f; exit }
}
debug set_bp $::env(GRABA_BP) {} { entra }
# GRABA_BP2: mas sitios donde grabar, para lo que el juego pinta con las
# interrupciones cortadas (los carteles y sus esperas)
if {[info exists ::env(GRABA_BP2)]} {
    foreach b $::env(GRABA_BP2) { debug set_bp $b {} { entra } }
}
after time 1800 {close $::f; exit}
