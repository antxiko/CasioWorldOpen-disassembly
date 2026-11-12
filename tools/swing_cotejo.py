"""Cotejo del swing: en cada cuadro de work/swing.bin con fotograma (0xE06E 1-6), los sprites del golfista en la tabla
de atributos GRABADA (desde la entrada 10, la que llena el buffer 0xE0EA) contra lo que da la ROM con la cuenta de
0x4F8A: Y = (0xE098) - t0, X = (0xE099) - t1, patron = 0x60 + 4 x pieza, color = t2 (el 8 sale 7 con el bit 6 de
0xE000 a cero); el golfista lo elige (0xE097): menos de 8, 8, mas de 8. La tabla de atributos va un cuadro por
detras de la RAM: se coteja con la RAM de hasta tres cuadros antes y se dice con cual casa."""
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import vdp                      # noqa: E402
import graficos                 # noqa: E402

RAIZ = os.path.dirname(AQUI)
rom = graficos.Rom(open(os.path.join(RAIZ, "casioworldopen.rom"), "rb").read(), 0x4000)


def de_la_rom(ram, f):
    e097 = ram[0x97]
    cual = 0 if e097 < 8 else (1 if e097 == 8 else 2)
    _, listas, ancho, tabla, _ = graficos.GOLFISTAS[cual]
    out = []
    for k in range(ancho):
        i = rom.b(listas + (f - 1) * ancho + k)
        if i == 0:
            break
        o = tabla + (i - 1) * 3
        col = rom.b(o + 2)
        if not (ram[0] & 0x40) and col == 8:
            col = 7
        out.append(((ram[0x98] - rom.b(o)) & 0xFF, (ram[0x99] - rom.b(o + 1)) & 0xFF, 0x60 + 4 * (i - 1), col))
    return out, cual


def forma(lista):
    """Las piezas relativas a la primera: el dibujo, sin la posicion (que la vista corre al seguir a la bola)."""
    y0, x0 = lista[0][0], lista[0][1]
    return [((y - y0) & 0xFF, (x - x0) & 0xFF, p, col) for y, x, p, col in lista]


def main():
    """0x4F8A compone el golfista al cambiar de fotograma; la VRAM va unos cuadros detras (vale el fotograma de
    antes), y tras el golpe la vista sigue a la bola y el golfista entero baja hasta salir (Y 0xC2): se coteja la
    FORMA de cada cuadro grabado contra la del fotograma de ahora y la del de antes."""
    vistos = {}
    antes = None
    ahora = previa = None
    for n, c in enumerate(vdp.cuadros(os.path.join(RAIZ, "work", "swing.bin"))):
        ram = c["ram"]
        if 1 <= ram[0x6E] <= 6 and (antes is None or ram[0x6E] != antes[0x6E]):
            previa, ahora = ahora, (ram[0x6E], de_la_rom(ram, ram[0x6E])[0])
        if ahora:
            sat = (c["regs"][5] & 0x7F) * 0x80 + 4 * 10
            g = [tuple(c["vram"][sat + 4 * k:sat + 4 * k + 4]) for k in range(9)]
            g = [(y, x, p, col & 0x0F) for y, x, p, col in g]
            if g[0][0] == 0xC2:
                que = "el golfista ya fuera (Y 0xC2)"
            elif forma(g[:len(ahora[1])]) == forma(ahora[1]):
                que = "la forma del fotograma de ahora"
            elif previa and forma(g[:len(previa[1])]) == forma(previa[1]):
                que = "la forma del de antes (%d)" % previa[0]
            else:
                que = "NINGUNA"
            d = vistos.setdefault(ahora[0], {})
            d[que] = d.get(que, 0) + 1
        antes = ram
    for f in sorted(vistos):
        print("fotograma %d: %s" % (f, "; ".join("%d cuadros con %s" % (v, k) for k, v in sorted(vistos[f].items()))))


if __name__ == "__main__":
    main()
