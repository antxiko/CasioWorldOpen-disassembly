"""El swing, JUGADO: los GIF de work/swing.bin (tools/guiones/swing.tcl, grabado con tools/lanza_graba.ps1 en
C-BIOS_MSX1_JP, -bp 0x4B8A -ram "0xE000 0x1000"), pintados con tools/vdp.py; cada imagen dura el tiempo emulado que
dura en la grabacion. Imprime tambien los cambios de fotograma del swing (0xE06E) con su cuadro y su tiempo.

Uso: swing_gif.py docs/imagenes
"""
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import vdp          # noqa: E402

GRAB = os.path.join(os.path.dirname(AQUI), "work", "swing.bin")


def tramo():
    """Del primer fotograma 1 del swing a 60 cuadros despues del 6."""
    desde = hasta = None
    antes = None
    for n, c in enumerate(vdp.cuadros(GRAB)):
        f = c["ram"][0x6E]
        if f != antes and f != 0xFF:
            print("cuadro %5d  t=%.3f  fotograma %d" % (n, c["t"], f))
            if f == 1 and desde is None:
                desde = n - 20
            if f == 6:
                hasta = n + 60
        antes = f
    return desde, hasta


def main(salida):
    desde, hasta = tramo()
    for nombre, cada, escala, recorte in (("swing.gif", 2, 1, None),
                                          ("swing_golfista.gif", 1, 3, (24, 72, 120, 152))):
        n, t = vdp.gif(GRAB, os.path.join(salida, nombre), desde, hasta, cada, escala, recorte)
        print("%-20s %d imagenes, %.2f s" % (nombre, n, t))


if __name__ == "__main__":
    main(sys.argv[1])
