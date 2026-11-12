#!/usr/bin/env python3
"""El TMS9918 en Python: lo grabado en openMSX (tools/omsx_graba.tcl), pintado.

Pinta la pantalla con el modo y las tablas que dicen los registros, no
supuestos:

    modo      M1 = R1 bit 4, M2 = R1 bit 3, M3 = R0 bit 1
    nombres   R2 * 0x400
    G1        patrones R4 * 0x800, color R3 * 0x40 (un byte por cada 8 patrones)
    G2        patrones base (R4 & 0x04) << 11, mascara ((R4 & 3) << 8) | 0xFF
              color base (R3 & 0x80) << 6, mascara ((R3 & 0x7F) << 3) | 0x07
    sprites   atributos R5 * 0x80, patrones R6 * 0x800
    fondo     R7 & 0x0F (el color 0 es transparente: deja ver el fondo)

Con la pantalla apagada (R1 bit 6 a cero) sale el color de fondo entero.

Uso (modulo):  for c in cuadros("work/x.bin"): im = imagen(c["vram"], c["regs"])
Uso (orden):   vdp.py <grabacion.bin> <salida.gif|.png> [--desde N] [--hasta N] [--cada K] [--escala E]
"""
import struct
import sys

PALETA = [
    (0, 0, 0), (0, 0, 0), (33, 200, 66), (94, 220, 120),
    (84, 85, 237), (125, 118, 252), (212, 82, 77), (66, 235, 245),
    (252, 85, 84), (255, 121, 120), (212, 193, 84), (230, 206, 128),
    (33, 176, 59), (201, 91, 186), (204, 204, 204), (255, 255, 255),
]

RAM_N = 0x1000         # lo que se graba: GRABA_RAM = "0xE000 0x1000"


def cuadros(ruta, ram_n=RAM_N):
    """Por cada cuadro: dict(regs, ram, psg, t, vram): t es el tiempo emulado y
    la VRAM es la entera de ese cuadro."""
    d = open(ruta, "rb").read()
    vram = bytearray(0x4000)
    i = 0
    while i < len(d):
        assert d[i:i + 1] == b"V", i
        i += 1
        regs = d[i:i + 8]
        i += 8
        ram = d[i:i + ram_n]
        i += ram_n
        psg = d[i:i + 16]
        i += 16
        t, = struct.unpack("<d", d[i:i + 8])
        i += 8
        k = d[i]
        i += 1
        for _ in range(k):
            n = d[i]
            vram[n * 1024:(n + 1) * 1024] = d[i + 1:i + 1025]
            i += 1025
        yield {"regs": bytes(regs), "ram": ram, "psg": psg, "t": t, "vram": bytes(vram)}


def modo(regs):
    m1 = (regs[1] >> 4) & 1
    m2 = (regs[1] >> 3) & 1
    m3 = (regs[0] >> 1) & 1
    if m1:
        return "T"
    if m2:
        return "MC"
    return "G2" if m3 else "G1"


def tela(vram, regs, con_sprites=True):
    """Los 256x192 puntos, como indices de color 0-15."""
    fondo = regs[7] & 0x0F
    t = [[fondo] * 256 for _ in range(192)]
    if not regs[1] & 0x40:
        return t
    nombres = (regs[2] & 0x0F) * 0x400
    md = modo(regs)
    if md in ("G1", "G2"):
        if md == "G2":
            pat_base = (regs[4] & 0x04) << 11
            pat_masc = ((regs[4] & 0x03) << 8) | 0xFF
            col_base = (regs[3] & 0x80) << 6
            col_masc = ((regs[3] & 0x7F) << 3) | 0x07
        for fila in range(24):
            for col in range(32):
                n = vram[nombres + fila * 32 + col]
                if md == "G2":
                    idx = ((fila // 8) << 8) | n
                    pa = pat_base + (idx & pat_masc) * 8
                    co = col_base + (idx & col_masc) * 8
                    colores = vram[co:co + 8]
                else:
                    pa = (regs[4] & 0x07) * 0x800 + n * 8
                    colores = bytes([vram[(regs[3] * 0x40 + (n >> 3)) & 0x3FFF]]) * 8
                for f in range(8):
                    p, c = vram[pa + f], colores[f]
                    tinta, tras = c >> 4, c & 0x0F
                    fila_t = t[fila * 8 + f]
                    for b in range(8):
                        v = tinta if p & (0x80 >> b) else tras
                        fila_t[col * 8 + b] = v if v else fondo
    elif md == "MC":
        pat = (regs[4] & 0x07) * 0x800
        for fila in range(24):
            for col in range(32):
                n = vram[nombres + fila * 32 + col]
                for k in range(2):
                    c = vram[pat + n * 8 + (fila & 3) * 2 + k]
                    for y in range(4):
                        for x in range(8):
                            v = (c >> 4) if x < 4 else (c & 0x0F)
                            t[fila * 8 + k * 4 + y][col * 8 + x] = v if v else fondo
    if con_sprites and md != "T":
        sprites(vram, regs, t)
    return t


def sprites(vram, regs, t):
    """Los 32 sprites, del ultimo al primero (el de menor numero queda encima),
    con el tope del TMS9918: cuatro por linea, el quinto y siguientes no salen."""
    attr = (regs[5] & 0x7F) * 0x80
    base = (regs[6] & 0x07) * 0x800
    grande = bool(regs[1] & 0x02)
    ampliado = bool(regs[1] & 0x01)
    lado = (16 if grande else 8) * (2 if ampliado else 1)
    puestos = []
    for s in range(32):
        y = vram[attr + s * 4]
        if y == 0xD0:
            break
        x = vram[attr + s * 4 + 1]
        pat = vram[attr + s * 4 + 2]
        col = vram[attr + s * 4 + 3]
        if col & 0x80:
            x -= 32
        y = (y + 1) & 0xFF
        if y > 192:
            y -= 256
        puestos.append((s, x, y, pat & 0xFC if grande else pat, col & 0x0F))
    permitido = [set() for _ in range(192)]
    for py in range(192):
        n = 0
        for s, x, y, pat, tinta in puestos:
            if y <= py < y + lado:
                if n == 4:
                    break
                permitido[py].add(s)
                n += 1
    paso = 2 if ampliado else 1
    for s, x, y, pat, tinta in reversed(puestos):
        if not tinta:
            continue
        d = base + pat * 8
        for cuarto in range(4 if grande else 1):
            ox = (cuarto // 2) * 8 * paso
            oy = (cuarto % 2) * 8 * paso
            for f in range(8):
                b8 = vram[(d + cuarto * 8 + f) & 0x3FFF]
                if not b8:
                    continue
                for b in range(8):
                    if not (b8 & (0x80 >> b)):
                        continue
                    for dy in range(paso):
                        py = y + oy + f * paso + dy
                        if not (0 <= py < 192) or s not in permitido[py]:
                            continue
                        for dx in range(paso):
                            px_ = x + ox + b * paso + dx
                            if 0 <= px_ < 256:
                                t[py][px_] = tinta


def imagen(vram, regs, escala=2, con_sprites=True):
    from PIL import Image
    t = tela(vram, regs, con_sprites)
    im = Image.new("P", (256, 192))
    pal = []
    for c in PALETA:
        pal += list(c)
    im.putpalette(pal + [0] * (768 - len(pal)))
    im.putdata([v for fila in t for v in fila])
    if escala > 1:
        im = im.resize((256 * escala, 192 * escala), Image.NEAREST)
    return im


class Gif:
    """Imagenes con su duracion; las iguales seguidas se juntan en una."""

    def __init__(self, ms=1000.0 / 60):
        self.ms = ms
        self.imgs, self.durs, self.ultima = [], [], None

    def pon(self, im, cuadros=1):
        b = im.tobytes()
        if b == self.ultima:
            self.durs[-1] += self.ms * cuadros
            return
        self.ultima = b
        self.imgs.append(im.copy())
        self.durs.append(self.ms * cuadros)

    def __len__(self):
        return len(self.imgs)

    def guarda(self, ruta, tope_ms=None):
        durs = [min(d, tope_ms) if tope_ms else d for d in self.durs]
        # el GIF cuenta en centesimas: se reparte el redondeo para no derivar
        out, acum, hecho = [], 0.0, 0
        for d in durs:
            acum += d
            v = int(round(acum / 10.0)) * 10 - hecho
            out.append(max(v, 20))
            hecho += out[-1]
        self.imgs[0].save(ruta, save_all=True, append_images=self.imgs[1:],
                          duration=out, loop=0, optimize=False, disposal=1)


def gif(ruta, salida, desde=0, hasta=10 ** 9, cada=2, escala=1, recorte=None, tope_ms=None):
    """El GIF de los cuadros [desde, hasta] de una grabacion, uno de cada
    `cada`, cada imagen con el tiempo EMULADO que dura (lo apunta la grabacion:
    los tramos con las interrupciones cortadas duran lo que duraron)."""
    g = Gif()
    cs = list(cuadros(ruta))
    hasta = min(hasta, len(cs) - 2)
    for n in range(desde, hasta + 1, cada):
        sig = min(n + cada, len(cs) - 1)
        ms = (cs[sig]["t"] - cs[n]["t"]) * 1000.0
        im = imagen(cs[n]["vram"], cs[n]["regs"], escala)
        if recorte:
            im = im.crop(tuple(v * escala for v in recorte))
        g.pon(im, ms / g.ms)
    g.guarda(salida, tope_ms)
    return len(g), (cs[hasta]["t"] - cs[desde]["t"])


def main():
    a = sys.argv[1:]
    ruta, salida = a[0], a[1]
    op = {"--desde": 0, "--hasta": 10 ** 9, "--cada": 2, "--escala": 1}
    i = 2
    while i < len(a):
        op[a[i]] = int(a[i + 1])
        i += 2
    if salida.endswith(".png"):
        for n, c in enumerate(cuadros(ruta)):
            if n == op["--desde"]:
                imagen(c["vram"], c["regs"], op["--escala"]).save(salida)
                print(salida, "modo", modo(c["regs"]), "regs", c["regs"].hex())
                return
        return
    n, s = gif(ruta, salida, op["--desde"], op["--hasta"], op["--cada"], op["--escala"])
    print("%s: %d imagenes, %.1f s" % (salida, n, s))


if __name__ == "__main__":
    main()
