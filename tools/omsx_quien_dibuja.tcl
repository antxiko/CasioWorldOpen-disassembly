# Quien llama al dibujante de tiles (L_5E66) y con que parametros.
# Se anota HL (codigo de tile), DE (destino) y la direccion de retorno, que es
# la que dice QUE rutina esta pintando. Se corta solo a las 4000 anotaciones
# para no congelar el emulador.
set ::SALIDA {C:/Users/Antxiko/Documents/DES_ASM/CASIOWORLDOPEN_DISAM/work/omsx/quien2.log}
set ::f [open $::SALIDA w]
set ::n 0
set ::bp {}

proc anota {} {
    if {$::n > 4000} {
        if {$::bp ne {}} { debug remove_bp $::bp ; set ::bp {} }
        close $::f
        return
    }
    incr ::n
    set sp [reg SP]
    set lo [debug read memory $sp]
    set hi [debug read memory [expr {$sp + 1}]]
    set ret [expr {$lo + 256 * $hi}]
    puts $::f [format {%04X hl=%04X de=%04X} $ret [reg HL] [reg DE]]
}

set ::bp [debug set_bp 0x5B61 {} {anota}]

after time 30 {
    if {$::bp ne {}} { debug remove_bp $::bp }
    catch { close $::f }
    puts "anotadas $::n llamadas"
    exit
}
after realtime 180 { catch { close $::f } ; exit }
