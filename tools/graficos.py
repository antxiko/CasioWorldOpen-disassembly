#!/usr/bin/env python3
"""Dibuja las imagenes de Casio World Open desde los bytes del cartucho.

Aqui no hay ni una captura ni un retoque. Todo sale de ejecutar en Python lo
mismo que corre el Z80: el montador de la pantalla de titulo (0x41A9 con su
ayudante L_44E5), el descompresor de sprites (L_A8FB) y el recorrido de las
listas de objetos de cada hoyo (L_610B con L_6277).

La prueba no es que las imagenes "se vean bien": lo montado aqui se compara
byte a byte contra la VRAM del emulador con `comprueba`. La pantalla de titulo
sale con los 304 bytes del logotipo y los 32 de color IDENTICOS, y 766 de sus
768 celdas de nombre iguales.

Uso:
    graficos.py <rom> <org> <carpeta_de_salida>
    graficos.py <rom> <org> comprueba <carpeta_con_vram_NN.bin>
"""
import os
import struct
import sys
import zlib

PALETA = [
    (0, 0, 0), (0, 0, 0), (62, 184, 73), (116, 208, 125),
    (89, 85, 224), (128, 118, 241), (185, 94, 81), (101, 219, 239),
    (219, 101, 89), (255, 137, 125), (204, 195, 94), (222, 208, 135),
    (58, 162, 65), (183, 102, 181), (204, 204, 204), (255, 255, 255),
]

FONDO = (0x20, 0x20, 0x30)
SEPARA = (0x2A, 0x2A, 0x38)

# Las direcciones salen del listado, no de mirar el binario a ojo.
TITULO_PATRON_A = 0x42F9   # ld hl,042f9h en 0x41A9  -> VRAM 0x0200, 8 bytes
LOGOTIPO = 0x4301          # ld hl,04301h en 0x41B4  -> VRAM 0x0408, 304 bytes
BLOQUE_3X3 = 0x4431        # ld hl,04431h en 0x41DD  -> nombres 0x186E
BLOQUE_16X4 = 0x443A       # ld hl,0443ah en 0x41E9  -> nombres 0x18C8
BLOQUE_1X3 = 0x44C9        # ld hl,044c9h en 0x4230  -> nombres 0x1A07
PATRONES_TERRENO = 0x8B5E  # ld bc,08b5eh en 0x5E78, 570 patrones de 8x8
DATOS_POR_HOYO = 0x45A8    # 18 fichas de 5 bytes, indexadas desde 0x458D
TABLA_OBJETOS = 0x6299     # 18 punteros de 16 bits, indexados desde 0x6290
TABLA_VISTAS = 0xA9EC      # 18 punteros a vistas de terreno, desde L_A8CB
TABLA_CUADROS = 0x6A2B     # 98 punteros a cuadros del golfista, desde 0x5B0D
TABLA_SPR_EXTRA = 0xACB7   # 18 punteros a planos de hoyo, desde 0x5DFB
# LOS SPRITES DE VERDAD, los del VDP: 0x60A2 descomprime 0x60B6 y copia 320
# bytes a VRAM 0x3800, que con el registro 6 a 0x07 es la tabla de patrones de
# sprite. Son diez sprites de 16x16. Todo lo demas que el .notes llamaba
# "sprite" son mapas de indices de tile que se pintan en el bitmap.
SPRITES = 0x60B6
CADENA_TERRENO = 0x9D2E    # 36 sprites encadenados, sin tabla de punteros
PALETA_PLANO = 0xB349      # ld hl,0b349h en L_5DEC: la paleta del plano del hoyo
FILAS_PLANO = 0x13         # ld b,013h en 0x5E0C: diecinueve filas
COLS_PLANO = 0x0A          # ld b,00ah en 0x5E1F: diez columnas
CELDA_PLANO = 0x16         # ld de,00016h en L_5E0E: empieza en la celda 22

TEXTOS_TITULO = [(0x447A, 0x1969, 0x0D), (0x4487, 0x19C9, 0x0D),
                 (0x4494, 0x1A08, 0x12), (0x4494, 0x1A48, 0x12),
                 (0x44A6, 0x1A89, 0x0D), (0x44B3, 0x1AE5, 0x16)]


class Rom(object):
    def __init__(self, datos, org):
        self.d, self.org = datos, org

    def b(self, a):
        return self.d[a - self.org]

    def w(self, a):
        return self.d[a - self.org] | (self.d[a - self.org + 1] << 8)

    def trozo(self, a, n):
        return self.d[a - self.org:a - self.org + n]


# ==========================================================================
# EL DESCOMPRESOR DE SPRITES (L_A8FB)
# ==========================================================================
def descomprime(rom, hl):
    """L_A8FB. La cabecera de dos bytes dice cuantos bytes de FUENTE quedan por
    consumir, no cuantos salen. Un 0xFF abre una racha -los dos siguientes son
    cuenta y valor, y descuenta tres-; cualquier otro byte es literal."""
    quedan = rom.w(hl)
    hl += 2
    salida = bytearray()
    while quedan > 0:
        x = rom.b(hl)
        if x == 0xFF:
            n, val = rom.b(hl + 1), rom.b(hl + 2)
            salida.extend([val] * n)
            hl += 3
            quedan -= 3
        else:
            salida.append(x)
            hl += 1
            quedan -= 1
    return bytes(salida), hl


# ==========================================================================
# LA PANTALLA DE TITULO (0x41A9)
# ==========================================================================
def vram_titulo(rom):
    v = bytearray(0x4000)
    # INIT32 deja la tabla de nombres llena de espacios
    for i in range(0x1800, 0x1B00):
        v[i] = 0x20
    v[0x0200:0x0208] = rom.trozo(TITULO_PATRON_A, 8)
    v[0x0408:0x0408 + 0x130] = rom.trozo(LOGOTIPO, 0x130)
    # El color de SCREEN 1 son 32 bytes: un valor por cada ocho patrones
    for i in range(0x10):
        v[0x2000 + i] = 0xF1
    for i in range(0x10):
        v[0x2010 + i] = 0x21

    def bloque(hl, de, ancho, filas):
        """L_44E5: `filas` filas de `ancho` bytes, avanzando 32 por fila."""
        for _ in range(filas):
            for i in range(ancho):
                v[de + i] = rom.b(hl + i)
            hl += ancho
            de += 32

    bloque(BLOQUE_3X3, 0x186E, 3, 3)
    bloque(BLOQUE_16X4, 0x18C8, 16, 4)
    bloque(BLOQUE_1X3, 0x1A07, 1, 3)
    for hl, de, n in TEXTOS_TITULO:
        for i in range(n):
            v[de + i] = rom.b(hl + i)
    return v


def marco_del_rotulo(v):
    """El recorte no se pone a ojo: son las celdas de la mitad de arriba que no
    son el espacio con el que INIT32 rellena, mas una de margen."""
    filas = [f for f in range(0, 12)
             if any(v[0x1800 + f * 32 + c] != 0x20 for c in range(32))]
    cols = [c for c in range(32)
            if any(v[0x1800 + f * 32 + c] != 0x20 for f in filas)]
    f0, f1 = max(0, min(filas) - 1), min(23, max(filas) + 1)
    c0, c1 = max(0, min(cols) - 1), min(31, max(cols) + 1)
    return dict(fila0=f0, filas=f1 - f0 + 1, col0=c0, cols=c1 - c0 + 1)


# ==========================================================================
# LOS DIECIOCHO HOYOS
# ==========================================================================
def ficha_del_hoyo(rom, i):
    """Las cinco de 0x45A8. El nibble bajo del primer byte es el PAR, y su bit
    7 dice si el trazado se dibuja espejado -que es lo que mira 0x5E7C antes de
    darle la vuelta al patron bit a bit-."""
    d = [rom.b(DATOS_POR_HOYO + i * 5 + k) for k in range(5)]
    return dict(bytes=d, par=d[0] & 0x0F, espejo=bool(d[0] & 0x80))


def trazado_del_hoyo(rom, i):
    """L_610B. El primer byte de la lista dice cuantos sub-bloques hay; cada uno
    empieza por su cuenta de objetos, y cada objeto son cuatro bytes: la casilla
    -nibble bajo la columna, nibble alto la fila- y tres de atributo. El numero
    de sub-bloque se guarda con ellos, y es el que ordena el hoyo de salida a
    green."""
    p = rom.w(TABLA_OBJETOS + i * 2)
    hl = p
    sub = rom.b(hl)
    hl += 1
    celdas = {}
    for c in range(1, sub + 1):
        n = rom.b(hl)
        hl += 1
        for _ in range(n):
            code = rom.b(hl)
            celdas[(code >> 4, code & 0x0F)] = (c, rom.b(hl + 1),
                                                rom.b(hl + 2), rom.b(hl + 3))
            hl += 4
    return dict(ptr=p, sub=sub, celdas=celdas, bytes=hl - p)


def acumulada(rom, hl):
    """L_A8CB. Descomprime y convierte los bytes en valores de 16 bits
    ACUMULADOS. Cada uno es un codigo de tabla_patrones_terreno, y por eso
    hacen falta dieciseis bits: hay 570 patrones. Los `sprites` del cartucho
    no son dibujos, son INDICES dentro de esta lista -L_5B61 hace `add hl,bc`
    dos veces, que es indexado de 16 bits-."""
    datos, _ = descomprime(rom, hl)
    tiles, total = [], 0
    for x in datos:
        total = (total + x) & 0xFFFF
        tiles.append(total)
    return tiles


def plano_del_hoyo(rom, i):
    """L_5DEC. Descomprime la paleta de 0xB349 en 0xE800, el plano del hoyo de
    tabla_sprites_extra en 0xEA14, y L_5E0E lo pinta en diecinueve filas de
    diez celdas desde la 22 -o sea, las columnas 22 a 31 de la pantalla-.

    El espejado es del propio bucle: con el bit 7 de (0xE0A0) puesto, 0x5E1B
    adelanta el puntero nueve posiciones y 0x5E2A lo recorre hacia atras."""
    pal = acumulada(rom, PALETA_PLANO)
    idx, _ = descomprime(rom, rom.w(TABLA_SPR_EXTRA + i * 2))
    espejo = ficha_del_hoyo(rom, i)["espejo"]
    rej = []
    for fila in range(FILAS_PLANO):
        base = fila * COLS_PLANO + (COLS_PLANO - 1 if espejo else 0)
        linea = []
        for col in range(COLS_PLANO):
            j = base - col if espejo else base + col
            v = idx[j] if 0 <= j < len(idx) else 0
            linea.append(pal[v] if v < len(pal) else 0)
        rej.append(linea)
    return rej


# ==========================================================================
# LA VISTA DEL CAMPO EN PERSPECTIVA (0x5AFD con 0xA875)
# ==========================================================================
# Lo que el .notes llamaba "tabla_cuadros_del_golfista" no son cuadros de un
# golfista: son los MAPAS DE LA VISTA del campo, 21 columnas de ancho. La
# tabla de 0x6A2B tiene 98 entradas repartidas en dieciocho grupos -uno por
# hoyo-, y tabla_pasos_golfista (0x5E54) dice cuantas caen en cada grupo.
# El primero del grupo son 105 bytes (21x5, el horizonte) y los demas 294
# (21x14, el suelo), que 0x5B17 y 0x5B27 descomprimen SEGUIDOS en 0xEA00 y
# 0xEA69: 0xEA00+105 = 0xEA69 y 0xEA69+294 = 0xEB8F, o sea 399 bytes de
# indices que son diecinueve filas de veintiuna columnas.
TABLA_VISTAS_HOYO = 0x6A2B  # 98 entradas, agrupadas por hoyo
PASOS_POR_HOYO = 0x5E54     # cuantas entradas tiene el grupo de cada hoyo
FONDO_A = 0xA926            # la lista de codigos comun (0xA88 9)
FONDO_B = 0xA979            # y su alternativa
COLS_VISTA = 21
FILAS_VISTA = 19


def pasos_del_hoyo(rom):
    return [rom.b(PASOS_POR_HOYO + i) for i in range(18)]


def tramos_del_hoyo(rom, hoyo):
    """Cuantas vistas distintas tiene el hoyo. La 0 es la cabecera comun, asi
    que los tramos jugables van de 1 en adelante: es el byte alto de (0xE0B4),
    que 0x4242 arranca en 1."""
    return pasos_del_hoyo(rom)[hoyo - 1] - 1


def lista_de_codigos(rom, hoyo):
    """0xA875. Dos listas acumuladas SEGUIDAS en 0xE800: primero la comun
    -0xA926 o 0xA979 segun el hoyo- y detras la del hoyo, sacada de
    tabla_vistas_de_terreno. Van pegadas porque 0xE902 y 0xE934 son justo el
    final de la primera; el indice del mapa recorre las dos como una sola."""
    comun = FONDO_A if hoyo in (1, 3, 5, 7, 9, 12, 13) else FONDO_B
    return acumulada(rom, comun) + acumulada(rom, rom.w(TABLA_VISTAS + (hoyo - 1) * 2))


def mapa_de_la_vista(rom, hoyo, tramo):
    """Los 399 indices de 0xEA00: la cabecera del grupo y el tramo que toque."""
    base = sum(pasos_del_hoyo(rom)[:hoyo - 1])
    cab, _ = descomprime(rom, rom.w(TABLA_VISTAS_HOYO + base * 2))
    cue, _ = descomprime(rom, rom.w(TABLA_VISTAS_HOYO + (base + tramo) * 2))
    return bytes(cab) + bytes(cue)


def vista_del_hoyo(rom, hoyo, tramo):
    """La rejilla de codigos de tile de 19x21, ya resueltos contra la lista."""
    lista = lista_de_codigos(rom, hoyo)
    mapa = mapa_de_la_vista(rom, hoyo, tramo)
    espejo = ficha_del_hoyo(rom, hoyo - 1)["espejo"]
    rej = []
    for fila in range(FILAS_VISTA):
        linea = []
        for col in range(COLS_VISTA):
            # 0x5B49: con el espejo, la fila se recorre desde la columna 20
            j = fila * COLS_VISTA + (COLS_VISTA - 1 - col if espejo else col)
            v = mapa[j] if j < len(mapa) else 0
            linea.append(lista[v] if v < len(lista) else 0)
        rej.append(linea)
    return rej


def pinta_la_vista(rom, hoyo, tramo, px, W, x0, y0, esc=2):
    espejo = ficha_del_hoyo(rom, hoyo - 1)["espejo"]
    for fila, linea in enumerate(vista_del_hoyo(rom, hoyo, tramo)):
        for col, code in enumerate(linea):
            base = PATRONES_TERRENO + code * 8
            cb = color_del_tile(rom, code)
            for y in range(8):
                pat = rom.b(base + y) if base + 8 < 0xC000 else 0
                if espejo:
                    pat = voltea(pat)
                c = cb[y] if y < len(cb) else 0x23
                fg = PALETA[c >> 4] if (c >> 4) else PALETA[2]
                bg = PALETA[c & 15] if (c & 15) else PALETA[3]
                for x in range(8):
                    pon(px, W, x0 + (col * 8 + x) * esc, y0 + (fila * 8 + y) * esc,
                        fg if (pat >> (7 - x)) & 1 else bg, esc)


def mosaico_de_vistas(rom, fn, hoyo, esc=2, margen=8):
    """Los tramos del hoyo, en fila: es el recorrido de la salida al green."""
    n = tramos_del_hoyo(rom, hoyo)
    an, al = COLS_VISTA * 8 * esc, FILAS_VISTA * 8 * esc
    W = n * (an + margen) + margen
    H = al + 2 * margen
    px = lienzo(W, H, SEPARA)
    for k in range(n):
        pinta_la_vista(rom, hoyo, k + 1, px, W, k * (an + margen) + margen,
                       margen, esc)
    png(W, H, px, fn)
    return n


# ==========================================================================
# EL GOLFISTA (0x4F40 con 0x4BF8)
# ==========================================================================
# El golfista no es un sprite ni un dibujo: son hasta NUEVE sprites de 16x16
# superpuestos, cada uno de un color, que el juego compone en el buffer de
# atributos de 0xE0EA y vuelca a VRAM 0x1B00. 0x4F8A recorre una lista de
# piezas y, por cada una, saca de una tabla de tres bytes su desplazamiento y
# su color; el patron sale de la cuenta 0x4FBA-0x4FBD: indice*4 + 0x60.
#
# Hay TRES golfistas, y los elige el palo en (0xE114) desde 0x4BF8: uno para
# los palos por debajo del 8, otro para el 8 y otro para los de encima. Cada
# uno trae su bloque de piezas, su tabla de posiciones y sus listas, y los
# tres tienen SEIS fotogramas de swing. Que el indice mas alto de las listas
# case justo con el numero de piezas del bloque es lo que confirma el reparto.
GOLFISTAS = [
    # (nombre, listas, piezas por fotograma, tabla de piezas, sprites)
    ("palos 1 a 7", 0x502F, 6, 0x5113, 0xB9F0),
    ("palo 8",      0x4FFF, 8, 0x50BC, 0xB777),
    ("palos 9 y +", 0x4FC9, 9, 0x5053, 0xB4AE),
]
CUADROS_SWING = 6


def piezas_del_golfista(rom, cual):
    """Los 16x16 de cada pieza, ya descomprimidos. Cada uno son 32 bytes:
    cuatro cuadrantes de ocho, como manda el VDP."""
    datos, _ = descomprime(rom, GOLFISTAS[cual][4])
    return [datos[i * 32:(i + 1) * 32] for i in range(len(datos) // 32)]


def cuadro_del_swing(rom, cual, cuadro):
    """Las piezas de un fotograma: (dx, dy, color, numero de pieza).

    0x4F9C y 0x4FA3 restan la posicion del golfista, asi que los dos bytes de
    la tabla son desplazamientos HACIA ARRIBA y HACIA LA IZQUIERDA. Medido
    contra el emulador: (0xE099)-fila y (0xE098)-columna salen constantes en
    las ocho piezas, 144 y 80."""
    _, listas, ancho, tabla, _ = GOLFISTAS[cual]
    trozos = []
    for k in range(ancho):
        i = rom.b(listas + cuadro * ancho + k)
        if i == 0:                      # 0x4F8D: el cero cierra la lista
            break
        c = i - 1
        o = tabla + c * 3
        trozos.append((-rom.b(o + 1), -rom.b(o), rom.b(o + 2), c))
    return trozos


def pinta_el_golfista(rom, cual, cuadro, px, W, x0, y0, esc=2, ancla=None):
    piezas = piezas_del_golfista(rom, cual)
    trozos = cuadro_del_swing(rom, cual, cuadro)
    if ancla is None:
        ancla = marco_del_golfista(rom, cual)
    mx, my = ancla
    for dx, dy, color, n in trozos:
        if n >= len(piezas):
            continue
        d = piezas[n]
        fg = PALETA[color & 15]
        for cuad in range(4):
            ox, oy = (cuad // 2) * 8, (cuad % 2) * 8
            for y in range(8):
                pat = d[cuad * 8 + y]
                for x in range(8):
                    if (pat >> (7 - x)) & 1:
                        pon(px, W, x0 + (dx - mx + ox + x) * esc,
                            y0 + (dy - my + oy + y) * esc, fg, esc)


def marco_del_golfista(rom, cual):
    """La esquina de la que cuelgan los seis fotogramas, para que no bailen
    entre si: el minimo de todos los desplazamientos."""
    dxs, dys = [], []
    for c in range(CUADROS_SWING):
        for dx, dy, _, _ in cuadro_del_swing(rom, cual, c):
            dxs.append(dx)
            dys.append(dy)
    return (min(dxs), min(dys))


def medida_del_golfista(rom, cual):
    mx, my = marco_del_golfista(rom, cual)
    dxs, dys = [], []
    for c in range(CUADROS_SWING):
        for dx, dy, _, _ in cuadro_del_swing(rom, cual, c):
            dxs.append(dx - mx + 16)
            dys.append(dy - my + 16)
    return (max(dxs), max(dys))


def hoja_del_golfista(rom, fn, esc=3, margen=6):
    """Los tres golfistas y sus seis fotogramas de swing, montados pieza a
    pieza como los monta el cartucho."""
    anchos = [medida_del_golfista(rom, c) for c in range(3)]
    an = max(a for a, _ in anchos)
    al = max(b for _, b in anchos)
    W = CUADROS_SWING * (an * esc + margen) + margen
    H = 3 * (al * esc + margen) + margen
    px = lienzo(W, H, SEPARA)
    for cual in range(3):
        ancla = marco_del_golfista(rom, cual)
        for c in range(CUADROS_SWING):
            pinta_el_golfista(rom, cual, c, px, W,
                              c * (an * esc + margen) + margen,
                              cual * (al * esc + margen) + margen, esc, ancla)
    png(W, H, px, fn)
    return len(GOLFISTAS)


def mosaico_de_salidas(rom, fn, esc=2, cols=6, margen=8):
    """El primer tramo de los dieciocho hoyos: lo que se ve desde el tee."""
    an, al = COLS_VISTA * 8 * esc, FILAS_VISTA * 8 * esc
    filas = (18 + cols - 1) // cols
    W = cols * (an + margen) + margen
    H = filas * (al + margen) + margen
    px = lienzo(W, H, SEPARA)
    for i in range(18):
        pinta_la_vista(rom, i + 1, 1, px, W,
                       (i % cols) * (an + margen) + margen,
                       (i // cols) * (al + margen) + margen, esc)
    png(W, H, px, fn)


def trazados_distintos(rom):
    """Cuantos trazados distintos sirven a los dieciocho hoyos."""
    d = {}
    for i in range(18):
        d.setdefault(rom.w(TABLA_OBJETOS + i * 2), []).append(i + 1)
    return d


# ==========================================================================
# DIBUJO
# ==========================================================================
def png(w, h, px, fn):
    raw = b"".join(b"\0" + bytes(px[y * w * 3:(y + 1) * w * 3]) for y in range(h))

    def chunk(t, d):
        return (struct.pack(">I", len(d)) + t + d
                + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF))
    with open(fn, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n"
                + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
                + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def lienzo(w, h, color=FONDO):
    px = bytearray(w * h * 3)
    for i in range(w * h):
        px[i * 3:i * 3 + 3] = bytes(color)
    return px


def pon(px, W, x, y, color, esc=1):
    for dy in range(esc):
        o = ((y + dy) * W + x) * 3
        for dx in range(esc):
            px[o + dx * 3:o + dx * 3 + 3] = bytes(color)


def pantalla_screen1(v, fn, esc=2, fila0=0, filas=24, col0=0, cols=32):
    """SCREEN 1: un byte de color por cada ocho patrones."""
    W, H = cols * 8 * esc, filas * 8 * esc
    px = lienzo(W, H)
    for f in range(filas):
        for c in range(cols):
            t = v[0x1800 + (fila0 + f) * 32 + col0 + c]
            cb = v[0x2000 + t // 8]
            fg, bg = PALETA[cb >> 4], PALETA[cb & 15]
            for y in range(8):
                pat = v[t * 8 + y]
                for x in range(8):
                    pon(px, W, (c * 8 + x) * esc, (f * 8 + y) * esc,
                        fg if (pat >> (7 - x)) & 1 else bg, esc)
    png(W, H, px, fn)


# El color NO va junto al patron: lo trae la cadena de bloques de 0x9D2E.
# 0x5EA5 elige el bloque con los bits altos del codigo de tile (codigo>>4),
# lo descomprime en 0xEE00, y 0x5ECB toma sus ocho bytes en el desplazamiento
# (codigo*8) y 0x7F para escribirlos en la tabla de color, +0x2000. Por eso el
# plano lleva arena y agua y no es todo verde.
_CACHE_COLOR = {}


def bloque_de_color(rom, n):
    """Camina la cadena de 0x9D2E: cada cabecera de dos bytes dice cuanto
    ocupa el bloque, y el siguiente empieza justo detras."""
    if n in _CACHE_COLOR:
        return _CACHE_COLOR[n]
    hl = CADENA_TERRENO
    for _ in range(n):
        hl += 2 + rom.w(hl)
    datos, _ = descomprime(rom, hl)
    _CACHE_COLOR[n] = datos
    return datos


def color_del_tile(rom, code):
    b = bloque_de_color(rom, code >> 4)
    o = (code * 8) & 0x7F
    return b[o:o + 8] if o + 8 <= len(b) else b"#" * 8


def voltea(by):
    """0x5E8D: `rlc c` saca el bit 7 al acarreo y `rra` lo mete por arriba en A;
    ocho vueltas dejan el byte del reves. Es el espejo de un patron de 8x8."""
    r = 0
    for _ in range(8):
        r = (r >> 1) | ((by & 0x80) and 0x80)
        by = (by << 1) & 0xFF
    return r


def pinta_el_plano(rom, i, px, W, x0, y0, esc=2):
    """El espejo del hoyo son DOS cosas, no una: 0x5E1B recorre las diez celdas
    de la fila al reves, y 0x5E7C ademas le da la vuelta bit a bit al patron de
    cada celda antes de copiarlo a la VRAM. El color NO se voltea: 0x5ECB lo
    copia tal cual, indexado por el codigo de tile."""
    espejo = ficha_del_hoyo(rom, i)["espejo"]
    for fila, linea in enumerate(plano_del_hoyo(rom, i)):
        for col, code in enumerate(linea):
            base = PATRONES_TERRENO + code * 8
            cb = color_del_tile(rom, code)
            for y in range(8):
                pat = rom.b(base + y) if base + 8 < 0xC000 else 0
                if espejo:
                    pat = voltea(pat)
                c = cb[y] if y < len(cb) else 0x23
                fg = PALETA[c >> 4] if (c >> 4) else PALETA[2]
                bg = PALETA[c & 15] if (c & 15) else PALETA[3]
                for x in range(8):
                    pon(px, W, x0 + (col * 8 + x) * esc, y0 + (fila * 8 + y) * esc,
                        fg if (pat >> (7 - x)) & 1 else bg, esc)


def mosaico_de_hoyos(rom, fn, esc=3, cols=6, margen=10):
    anchoh = COLS_PLANO * 8 * esc
    altoh = FILAS_PLANO * 8 * esc
    filas = (18 + cols - 1) // cols
    W = cols * (anchoh + margen) + margen
    H = filas * (altoh + margen) + margen
    px = lienzo(W, H, SEPARA)
    for i in range(18):
        pinta_el_plano(rom, i, px, W,
                       (i % cols) * (anchoh + margen) + margen,
                       (i // cols) * (altoh + margen) + margen, esc)
    png(W, H, px, fn)


def hoja_de_patrones(rom, fn, n=570, cols=32, esc=2, margen=1):
    filas = (n + cols - 1) // cols
    paso = 8 * esc + margen
    W, H = cols * paso + margen, filas * paso + margen
    px = lienzo(W, H, SEPARA)
    for t in range(n):
        cx = (t % cols) * paso + margen
        cy = (t // cols) * paso + margen
        for y in range(8):
            pat = rom.b(PATRONES_TERRENO + t * 8 + y)
            for x in range(8):
                pon(px, W, cx + x * esc, cy + y * esc,
                    (255, 255, 255) if (pat >> (7 - x)) & 1 else (0, 0, 0), esc)
    png(W, H, px, fn)


def hoja_de_sprites(rom, fn, esc=4, cols=10, margen=4):
    """Los diez sprites de 16x16 que 0x60A2 deja en la tabla de patrones de
    sprite del VDP. Cada uno son 32 bytes: cuatro cuadrantes de ocho."""
    datos, _ = descomprime(rom, SPRITES)
    n = len(datos) // 32
    paso = 16 * esc + margen
    filas = (n + cols - 1) // cols
    W, H = cols * paso + margen, filas * paso + margen
    px = lienzo(W, H, SEPARA)
    for s_ in range(n):
        cx = (s_ % cols) * paso + margen
        cy = (s_ // cols) * paso + margen
        for cuad in range(4):
            ox, oy = (cuad // 2) * 8, (cuad % 2) * 8
            for y in range(8):
                pat = datos[s_ * 32 + cuad * 8 + y]
                for x in range(8):
                    if (pat >> (7 - x)) & 1:
                        pon(px, W, cx + (ox + x) * esc, cy + (oy + y) * esc,
                            (255, 255, 255), esc)
    png(W, H, px, fn)
    return n


def _hoja_vieja(rom, fn, punteros, cuantos, ancho=8, esc=2, cols=10,
                margen=3):
    """Cada sprite descomprimido es una tira de bytes de `ancho` bits de ancho."""
    trozos = []
    vistos = set()
    for i in range(cuantos):
        p = rom.w(punteros + i * 2)
        if p in vistos or not (rom.org <= p < rom.org + len(rom.d)):
            continue
        vistos.add(p)
        try:
            datos, _ = descomprime(rom, p)
        except IndexError:
            continue
        if datos:
            trozos.append(datos)
    if not trozos:
        return 0
    alto = max(len(d) for d in trozos)
    paso_x = ancho * 8 * esc + margen
    paso_y = (alto // ancho + 1) * esc + margen
    filas = (len(trozos) + cols - 1) // cols
    W, H = cols * paso_x + margen, filas * paso_y + margen
    px = lienzo(W, H, SEPARA)
    for k, d in enumerate(trozos):
        cx = (k % cols) * paso_x + margen
        cy = (k // cols) * paso_y + margen
        for j, by in enumerate(d):
            fy, fx = divmod(j, ancho)
            for x in range(8):
                if (by >> (7 - x)) & 1:
                    pon(px, W, cx + (fx * 8 + x) * esc, cy + fy * esc,
                        (255, 255, 255), esc)
    png(W, H, px, fn)
    return len(trozos)


# ==========================================================================
# COMPROBACION CONTRA LA VRAM DEL EMULADOR
# ==========================================================================
def comprueba(rom, carpeta):
    fn = os.path.join(carpeta, "vram_05.bin")
    if not os.path.exists(fn):
        print("  no hay %s: correr antes tools/omsx_vram.tcl" % fn)
        return 1
    with open(fn, "rb") as f:
        real = f.read()
    v = vram_titulo(rom)
    malos = 0
    for nombre, a, z, tope in (("logotipo", 0x0408, 0x0538, 0),
                               ("color de SCREEN 1", 0x2000, 0x2020, 0),
                               ("tabla de nombres", 0x1800, 0x1B00, 2)):
        d = sum(1 for i in range(a, z) if v[i] != real[i])
        print("  %-18s %5d bytes  %s"
              % (nombre, z - a, "identico" if d == 0 else "%d distintos" % d))
        if d > tope:
            malos += 1
    return 1 if malos else 0


def main(argv):
    if len(argv) < 4:
        print(__doc__)
        return 2
    with open(argv[1], "rb") as f:
        rom = Rom(f.read(), int(argv[2], 0))
    if argv[3] == "comprueba":
        return comprueba(rom, argv[4])

    salida = argv[3]
    if not os.path.isdir(salida):
        os.makedirs(salida)

    def ruta(n):
        return os.path.join(salida, n)

    v = vram_titulo(rom)
    pantalla_screen1(v, ruta("titulo.png"))
    m = marco_del_rotulo(v)
    print("    rotulo: filas %d-%d, columnas %d-%d"
          % (m["fila0"], m["fila0"] + m["filas"] - 1, m["col0"],
             m["col0"] + m["cols"] - 1))
    pantalla_screen1(v, ruta("rotulo.png"), esc=4, **m)

    mosaico_de_hoyos(rom, ruta("hoyos.png"))
    hoja_de_patrones(rom, ruta("tiles.png"))
    # Los sprites del golfista, del campo y los extra SI se descomprimen -las
    # cuentas cuadran y las cadenas encajan- pero no se sabe todavia como se
    # disponen en pantalla: dibujarlos como una tira de bytes de cualquier
    # anchura sale ruido. Mientras no se sepa, no se publican. Ver la pagina
    # de preguntas abiertas.
    n = hoja_de_sprites(rom, ruta("sprites.png"))
    hoja_del_golfista(rom, ruta("golfista.png"))
    mosaico_de_vistas(rom, ruta("vistas_hoyo01.png"), 1)
    mosaico_de_salidas(rom, ruta("salidas.png"))
    print("  imagenes en %s" % salida)
    print("    %d sprites de 16x16 en la tabla del VDP" % n)
    print("    los TRES golfistas, seis fotogramas de swing cada uno:")
    for c, (nombre, _, ancho, _, _) in enumerate(GOLFISTAS):
        print("      %-12s %2d piezas, %d por fotograma, %dx%d px"
              % (nombre, len(piezas_del_golfista(rom, c)), ancho,
                 medida_del_golfista(rom, c)[0], medida_del_golfista(rom, c)[1]))
    print("    vistas en perspectiva: %s tramos por hoyo (total %d mapas de 19x21)"
          % ("/".join(str(tramos_del_hoyo(rom, h + 1)) for h in range(18)),
             sum(tramos_del_hoyo(rom, h + 1) for h in range(18))))
    d = trazados_distintos(rom)
    print("    %d trazados distintos para los dieciocho hoyos:" % len(d))
    for p in sorted(d):
        hoyos = d[p]
        marcas = " ".join("%d%s" % (h, "*" if ficha_del_hoyo(rom, h - 1)["espejo"]
                                    else "") for h in hoyos)
        print("      0x%04X -> hoyos %s" % (p, marcas))
    print("    (el * marca el que se dibuja espejado)")
    pares = [ficha_del_hoyo(rom, i)["par"] for i in range(18)]
    print("    pares: %s  ---- par %d" % (" ".join(map(str, pares)), sum(pares)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
