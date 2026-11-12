# SWING: una partida de uno, sin forzar nada, solo la barra, guiada por la RAM (no por el tiempo):
#   - arriba a los 9 s y la barra cada 2 s hasta que empieza el golpe (0xE06C = 0x20, la barra de fuerza 0xE092
#     sube de 5 en 5);
#   - 36 cuadros despues, la barra fija la fuerza (con 0x40 o mas el swing pasa por el fotograma 3);
#   - cuando sube la otra cuenta (0xE06C = 0x08), 90 cuadros despues, la barra da el golpe;
#   - 300 cuadros despues, se acaba.
# Se graba cada cuadro desde la interrupcion (0x4B8A) para medir el ritmo del swing (0xE06E, el fotograma 1-6).
proc m {a} { return [debug read memory $a] }
proc pulsa {} { keymatrixdown 8 0x01 ; after time 0.1 { keymatrixup 8 0x01 } }
after time  9.0 { keymatrixdown 8 0x20 }
after time  9.3 { keymatrixup 8 0x20 }
proc guion {n} {
    set e [m 0xE06C]
    if {![info exists ::fuerza]} {
        if {$e == 0x20} { set ::fuerza [expr {$n + 36}] } elseif {$n % 120 == 0 && [machine_info time] > 10} { pulsa }
        return 0
    }
    if {$n == $::fuerza} { pulsa }
    if {![info exists ::golpe] && $e == 0x08} { set ::golpe [expr {$n + 90}] }
    if {[info exists ::golpe] && $n == $::golpe} { pulsa }
    return [expr {[info exists ::golpe] && $n >= $::golpe + 300}]
}
