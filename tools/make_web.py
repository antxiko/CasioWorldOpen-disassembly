#!/usr/bin/env python3
"""Genera la portada de la web de Casio World Open, en los dos idiomas.

El diseno es el compartido por la serie (tools/estilo_web.py) y la pagina sale
autocontenida, con las imagenes embebidas como data URI.

Las imagenes NO son ilustraciones ni capturas: las dibuja tools/graficos.py a
partir de los propios bytes de la ROM, ejecutando en Python la misma cadena que
corre el Z80. Ninguna se ha retocado.

Uso: make_web.py <docs/imagenes> <salida.html> <idioma>
"""
import base64
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from estilo_web import ESTILO                                   # noqa: E402

# Las cifras salen de contar sobre el listado generado, no de escribirlas a ojo:
# 32768 = 8185 + 24583, que es lo que imprime tools/presupuesto.py con
# `make sanity`. RUTINAS son los bloques que cuenta tools/densidad.py. PAR sale
# del nibble bajo del primer byte de cada ficha de datos_por_hoyo, sumado.
CODIGO = 8185
DATOS = 24583
RUTINAS = 435
HOYOS = 18
PAR = 72
TRAZADOS = 10


def mil(n, idioma):
    return f"{n:,}".replace(",", "." if idioma == "es" else ",")


TXT = {
    "es": dict(
        titulo="Casio World Open — desensamblado comentado",
        aviso="<b>Aquí no hay ninguna ilustración ni captura.</b> El rótulo y "
              "<b>los dieciocho planos de hoyo</b> están <b>dibujados desde "
              "los bytes de la ROM</b>, ejecutando en Python la misma cadena "
              "que corre el Z80. Y está contrastado contra la VRAM del "
              "emulador: los <b>304 bytes del logotipo y los 32 de color, "
              "idénticos</b>; un plano de hoyo con <b>186 de sus 190 celdas "
              "iguales</b>, patrón y color; y <b>718 de las 768 celdas</b> de "
              "un cuadro de partida dibujadas con la tabla de patrones del "
              "cartucho.",
        claim="Un campo de dieciocho hoyos en 32 KB, construido con sólo diez "
              "trazados: ocho se juegan dos veces, y en cada pareja uno va "
              "espejado, con el propio bucle de dibujo dándole la vuelta al "
              "patrón bit a bit. Y lo que el cartucho comprime no son dibujos, "
              "son diferencias entre códigos de tile.",
        ficha=["Casio · <b>© Casio 1985</b>",
               "Cartucho de <b>32 KB</b>",
               "MSX1 · <b>páginas 1 y 2</b>", "Volcado <b>7b03fd41…</b>"],
        nav=[("#numbers", "Las cifras"), ("#findings", "Hallazgos"),
             ("#screens", "Lo que dibuja")],
        docnav=[("EMPEZAR.html", "Empezar"), ("EL-JUEGO.html", "El juego"),
                ("EL-CARTUCHO.html", "El cartucho"),
                ("EL-CODIGO.html", "El código"),
                ("HALLAZGOS.html", "Hallazgos"),
                ("EN-EL-EMULADOR.html", "En el emulador"),
                ("PREGUNTAS-ABIERTAS.html", "Preguntas abiertas")],
        otro=("../", "In English"),
        h_num="El cartucho en cifras", h_find="Lo que apareció al desmontarlo",
        h_scr="Lo que el cartucho dibuja",
        cifras=[("100 %", "del binario explicado"),
                (str(RUTINAS), "rutinas identificadas"),
                ("%d" % HOYOS, "hoyos, par %d, %d trazados" % (PAR, TRAZADOS)),
                (mil(CODIGO, "es"), "bytes de código"),
                (mil(DATOS, "es"), "bytes de datos"),
                ("0", "bytes sin identificar")],
        nota_scr="Debajo de cada imagen está de dónde sale y qué se está "
                 "viendo.",
        pie_leg="Esto es trabajo de documentación y preservación: el código y "
                "los gráficos siguen siendo de sus autores y de Casio, y la "
                "imagen del cartucho no se distribuye.",
    ),
    "en": dict(
        titulo="Casio World Open — a commented disassembly",
        aviso="<b>There is not one illustration or capture here.</b> The "
              "wordmark and <b>all eighteen hole plans</b> "
              "are <b>drawn from the bytes of the ROM</b>, running in Python "
              "the same chain the Z80 runs. And it is checked against the "
              "emulator's VRAM: the wordmark's <b>304 bytes and its 32 of "
              "colour, identical</b>; a hole plan with <b>186 of its 190 cells "
              "the same</b>, pattern and colour; and <b>718 of the 768 "
              "cells</b> of an in-game frame drawn with the cartridge's own "
              "pattern table.",
        claim="An eighteen-hole course in 32 KB, built from only ten layouts: "
              "eight are played twice, and in every pair one runs mirrored, "
              "with the drawing loop itself flipping the pattern bit by bit. "
              "And what the cartridge compresses are not pictures — they are "
              "differences between tile codes.",
        ficha=["Casio · <b>© Casio 1985</b>",
               "A <b>32 KB</b> cartridge",
               "MSX1 · <b>pages 1 and 2</b>", "Dump <b>7b03fd41…</b>"],
        nav=[("#numbers", "The numbers"), ("#findings", "What turned up"),
             ("#screens", "What it draws")],
        docnav=[("GETTING-STARTED.html", "Getting started"),
                ("THE-GAME.html", "The game"),
                ("THE-CARTRIDGE.html", "The cartridge"),
                ("THE-CODE.html", "The code"),
                ("FINDINGS.html", "Findings"),
                ("IN-THE-EMULATOR.html", "In the emulator"),
                ("OPEN-QUESTIONS.html", "Open questions")],
        otro=("es/", "En castellano"),
        h_num="The cartridge in numbers",
        h_find="What turned up when we took it apart",
        h_scr="What the cartridge draws",
        cifras=[("100%", "of the binary explained"),
                (str(RUTINAS), "routines identified"),
                ("%d" % HOYOS, "holes, par %d, %d layouts" % (PAR, TRAZADOS)),
                (mil(CODIGO, "en"), "bytes of code"),
                (mil(DATOS, "en"), "bytes of data"),
                ("0", "bytes unidentified")],
        nota_scr="Under each picture is where it comes from and what is on it.",
        pie_leg="This is documentation and preservation work: the code and "
                "artwork still belong to their authors and to Casio, and the "
                "cartridge image is not distributed.",
    ),
}

HALLAZGOS = {
    "es": [
        ("Dieciocho hoyos con diez trazados, y la mitad jugados del revés",
         "<p>La tabla de 0x6299 tiene dieciocho punteros, pero apuntan a "
         "<b>diez listas distintas</b>. Ocho de ellas sirven a dos hoyos cada "
         "una, y sólo el 1 y el 18 tienen trazado propio.</p>"
         "<p>Lo que distingue a los dos hoyos de cada pareja es <b>un bit</b>: "
         "el 7 del primer byte de su ficha en 0x45A8. Con él puesto, el bucle "
         "de dibujo adelanta el puntero nueve posiciones y luego <b>recorre "
         "los datos hacia atrás</b>, y 0x5E7C le da la vuelta al patrón bit a "
         "bit con <code>rlc</code> y <code>rra</code>. En las ocho parejas, sin "
         "una excepción, uno lleva el bit y el otro no.</p>"),
        ("Lo que se comprime no son dibujos, son diferencias entre tiles",
         "<p>0xA8CB no descomprime una imagen. Descomprime, <b>separa cada "
         "byte con un cero</b> —convirtiendo la tira en valores de dieciséis "
         "bits— y hace la <b>suma acumulada</b> de todos ellos. Lo que queda "
         "en RAM es una lista de códigos de tile.</p>"
         "<p>Y hacen falta dieciséis bits por una razón concreta: la tabla de "
         "patrones tiene <b>570 entradas</b>, así que un byte no llega. Por "
         "eso 0x5B61 hace <code>add hl,bc</code> <b>dos veces</b>, que es "
         "indexado de dieciséis bits.</p>"),
        ("Y encima de eso, todo lo demás son índices",
         "<p>Los planos de hoyo, las vistas de terreno y los cuadros del "
         "golfista no guardan tiles: guardan <b>posiciones dentro de esa lista "
         "acumulada</b>. Un byte por celda, y el tile sale de la indirección.</p>"
         "<p>Así que el mismo mapa de índices dibuja cosas distintas según qué "
         "lista se haya acumulado antes, que es lo que permite que el terreno "
         "cambie sin tocar los mapas.</p>"),
        ("El par de cada hoyo cabe en medio byte",
         "<p>El nibble bajo del primer byte de la ficha de 0x45A8 <b>es el "
         "par</b>: 3, 4 o 5. El bit 7 del mismo byte es el espejo. Un byte "
         "lleva las dos cosas.</p>"
         "<p>Sumados los dieciocho, el campo da <b>par 72</b>, con dos pares 3 "
         "y dos pares 5.</p>"),
        ("Sólo hay diez sprites, y son la misma bola cinco veces",
         "<p>De todo lo que el cartucho comprime, lo único que acaba en la "
         "tabla de patrones de sprite del VDP son los <b>320 bytes</b> que "
         "0x60A2 deja en VRAM 0x3800: <b>diez sprites de 16×16</b>.</p>"
         "<p>Y la mitad son la misma cosa a distinto tamaño: la bola, de un "
         "punto a una bola gorda, para que se vea alejarse. Todo lo demás que "
         "se mueve en pantalla —el golfista, los árboles, el terreno— está "
         "pintado en el bitmap, no es un sprite.</p>"),
        ("La pantalla de título es SCREEN 1 y la de juego SCREEN 2",
         "<p>El título usa el modo de texto de 32 columnas, con la fuente de "
         "la propia máquina y sólo <b>32 bytes de color</b> para toda la "
         "pantalla: uno por cada ocho patrones. El logotipo son 304 bytes "
         "copiados tal cual desde 0x4301.</p>"
         "<p>Y al pasar al juego, 0x44F3 hace algo bonito: entra en SCREEN 1 "
         "sólo para <b>quedarse con el juego de caracteres</b> que carga la "
         "BIOS, lo copia a RAM, y ya en SCREEN 2 lo vuelca como patrones del "
         "campo. La fuente de la máquina acaba siendo parte del decorado.</p>"),
    ],
    "en": [
        ("Eighteen holes from ten layouts, and half of them played backwards",
         "<p>The table at 0x6299 holds eighteen pointers, but they point at "
         "<b>ten distinct lists</b>. Eight of those serve two holes each, and "
         "only holes 1 and 18 have a layout of their own.</p>"
         "<p>What tells the two holes of a pair apart is <b>one bit</b>: bit 7 "
         "of the first byte of its record at 0x45A8. With it set, the drawing "
         "loop advances the pointer nine places and then <b>walks the data "
         "backwards</b>, and 0x5E7C flips the pattern bit by bit with "
         "<code>rlc</code> and <code>rra</code>. Across all eight pairs, "
         "without one exception, one carries the bit and the other does "
         "not.</p>"),
        ("What gets compressed are not pictures, they are differences between tiles",
         "<p>0xA8CB does not decompress an image. It decompresses, <b>puts a "
         "zero after every byte</b> — turning the run into sixteen-bit values "
         "— and takes the <b>running total</b> of them all. What ends up in "
         "RAM is a list of tile codes.</p>"
         "<p>And sixteen bits are needed for a concrete reason: the pattern "
         "table has <b>570 entries</b>, so one byte will not reach. That is "
         "why 0x5B61 does <code>add hl,bc</code> <b>twice</b>, which is "
         "sixteen-bit indexing.</p>"),
        ("And on top of that, everything else is indices",
         "<p>The hole plans, the terrain views and the golfer's frames do not "
         "store tiles: they store <b>positions inside that accumulated "
         "list</b>. One byte per cell, and the tile comes out of the "
         "indirection.</p>"
         "<p>So the same index map draws different things depending on which "
         "list was accumulated first, which is what lets the terrain change "
         "without touching the maps.</p>"),
        ("Each hole's par fits in half a byte",
         "<p>The low nibble of the first byte of the record at 0x45A8 <b>is "
         "the par</b>: 3, 4 or 5. Bit 7 of that same byte is the mirror. One "
         "byte carries both.</p>"
         "<p>Added up, the eighteen give <b>par 72</b>, with two par 3s and "
         "two par 5s.</p>"),
        ("There are only ten sprites, and half are the same ball",
         "<p>Of everything the cartridge compresses, the only thing that ends "
         "up in the VDP's sprite pattern table is the <b>320 bytes</b> 0x60A2 "
         "leaves at VRAM 0x3800: <b>ten 16×16 sprites</b>.</p>"
         "<p>And half of them are the same thing at different sizes: the ball, "
         "from a dot to a fat blob, so you can watch it go away. Everything "
         "else that moves on screen — the golfer, the trees, the terrain — is "
         "painted into the bitmap, not a sprite at all.</p>"),
        ("The title screen is SCREEN 1 and the game screen SCREEN 2",
         "<p>The title uses the 32-column text mode, with the machine's own "
         "font and just <b>32 bytes of colour</b> for the whole screen: one "
         "per eight patterns. The wordmark is 304 bytes copied straight from "
         "0x4301.</p>"
         "<p>And on the way into the game, 0x44F3 does something neat: it "
         "enters SCREEN 1 only to <b>keep the character set</b> the BIOS "
         "loads, copies it to RAM, and then in SCREEN 2 dumps it back as the "
         "course's patterns. The machine's own font ends up being part of the "
         "scenery.</p>"),
    ],
}

GALERIA = [
    ("hoyos.png",
     "<b>Los dieciocho planos de hoyo</b>, el panel que el juego lleva a la "
     "derecha de la pantalla. Los pinta 0x5DEC: diecinueve filas de diez "
     "celdas desde la columna 22, con los índices de <code>plano_hoyo_NN</code> "
     "sobre la lista de códigos que se acumula desde 0xB349. Los espejados "
     "salen del propio bucle, no de darles la vuelta después",
     "<b>The eighteen hole plans</b>, the panel the game keeps down the right "
     "of the screen. 0x5DEC paints them: nineteen rows of ten cells from "
     "column 22, with the indices of <code>plano_hoyo_NN</code> over the code "
     "list accumulated from 0xB349. The mirrored ones come out of the loop "
     "itself, not from flipping them afterwards"),
    ("rotulo.png",
     "El rótulo de cerca, con su palmera. Son los 304 bytes de 0x4301 puestos "
     "en dos bloques de la tabla de nombres; contra la VRAM del emulador salen "
     "<b>idénticos, byte a byte</b>",
     "The wordmark up close, palm tree and all. It is the 304 bytes at 0x4301 "
     "laid out in two blocks of the name table; against the emulator's VRAM "
     "they come out <b>identical, byte for byte</b>"),
    ("sprites.png",
     "Los diez sprites de 16×16, los únicos del cartucho: 0x60A2 los "
     "descomprime y los copia a VRAM 0x3800. Cinco de ellos son la bola a "
     "cinco tamaños, que es como se ve alejarse",
     "The ten 16×16 sprites, the only ones in the cartridge: 0x60A2 "
     "decompresses them and copies them to VRAM 0x3800. Five of them are the "
     "ball at five sizes, which is how you watch it fly away"),
    ("tiles.png",
     "Los 570 patrones de 8×8 de 0x8B5E, sin comprimir, con los que se dibuja "
     "todo lo que no es un sprite. Que son de verdad los del juego no es una "
     "impresión: <b>718 de las 768 celdas</b> de un cuadro de partida real "
     "salen de aquí",
     "The 570 uncompressed 8×8 patterns at 0x8B5E, which draw everything that "
     "is not a sprite. That these really are the game's is not an impression: "
     "<b>718 of the 768 cells</b> of a real in-game frame come from here"),
]


def img64(ruta):
    with open(ruta, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()


def main(argv):
    if len(argv) < 4:
        print(__doc__)
        return 2
    imgdir, salida, idioma = argv[1:4]
    t = TXT[idioma]

    # El "logotipo" de la cabecera no es un montaje ni una captura: es el rotulo
    # que el propio cartucho pinta en su pantalla de titulo, dibujado desde la
    # ROM por graficos.py. Si el PNG no esta, el trabajo NO esta hecho.
    ruta_logo = os.path.join(imgdir, "rotulo.png")
    cabecera = (f'<img src="{img64(ruta_logo)}" alt="Casio World Open">'
                if os.path.exists(ruta_logo) else "<h1>Casio World Open</h1>")

    nav = "".join(f'<a href="{h}">{x}</a>' for h, x in t["nav"])
    nav += "".join(f'<a href="{h}">{x}</a>' for h, x in t["docnav"])
    nav += (f'<a href="{t["otro"][0]}" style="margin-left:auto;color:var(--oro)">'
            f'{t["otro"][1]}</a>')

    cifras = "".join(f'<div class="cifra"><b>{v}</b><span>{e}</span></div>'
                     for v, e in t["cifras"])
    halls = "".join(f'<div class="hall"><h3>{tit}</h3>{cuerpo}</div>'
                    for tit, cuerpo in HALLAZGOS[idioma])
    imgs = ""
    faltan = []
    for fich, es, en in GALERIA:
        ruta = os.path.join(imgdir, fich)
        if not os.path.exists(ruta):
            faltan.append(fich)
            continue
        pie = es if idioma == "es" else en
        imgs += (f'<figure><img src="{img64(ruta)}" alt="{pie}">'
                 f'<figcaption>{pie}</figcaption></figure>')
    if faltan:
        print("  (faltan %d imagenes: %s)" % (len(faltan), " ".join(faltan)))

    html = f"""<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{t['titulo']}</title>
<style>{ESTILO}</style>
<header class="top">
  {cabecera}
  <p class="claim">{t['claim']}</p>
  <p class="ficha">{' · '.join(t['ficha'])}</p>
</header>
<p class="ficha" style="border:1px solid var(--oro);padding:.8em 1em;margin:1.5em 0">
{t['aviso']}</p>
<nav>{nav}</nav>
<section id="numbers">
  <h2>{t['h_num']}</h2>
  <div class="cifras">{cifras}</div>
</section>
<section id="findings"><h2>{t['h_find']}</h2>{halls}</section>
<section id="screens">
  <h2>{t['h_scr']}</h2>
  <p class="n">{t['nota_scr']}</p>
  <div class="galeria">{imgs}</div>
</section>
<footer><p>{t['pie_leg']}</p></footer>
"""
    with open(salida, "w", encoding="utf-8") as f:
        f.write(html)
    print("  %s: %d KB (%s)" % (salida, len(html) // 1024, idioma))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
