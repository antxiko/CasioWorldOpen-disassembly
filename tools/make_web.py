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
                ("LA-VISTA-3D.html", "La vista 3D"),
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
                ("THE-3D-VIEW.html", "The 3D view"),
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
        ("La perspectiva no se calcula: viene dibujada, tramo a tramo",
         "<p>La vista del campo parece 3D y no hay una sola cuenta de "
         "proyección detrás. La tabla de 0x6A2B guarda <b>ochenta mapas</b> de "
         "21×19 celdas, entre cuatro y seis por hoyo, y avanzar por el hoyo es "
         "cambiar de mapa: (0xE0B5) dice en qué tramo está la bola.</p>"
         "<p>Cada mapa se monta en dos trozos que quedan pegados en RAM: "
         "<b>105 bytes</b> de cielo, iguales para todo el hoyo, y <b>294</b> "
         "de suelo del tramo. Son 21×5 y 21×14, y 0xEA00+105 da exactamente "
         "0xEA69, que es donde el código descomprime el segundo. Y acercarse "
         "no es un zoom: es pintar <b>una fila nueva de veintiuna celdas</b> "
         "e ir moviendo el puntero de veintiuno en veintiuno.</p>"),
        ("El golfista son nueve sprites encajados, y hay tres",
         "<p>En el cartucho no hay ningún dibujo de un golfista: hay "
         "<b>piezas</b>. Cada postura la compone 0x4F8A con hasta <b>nueve "
         "sprites de 16×16 superpuestos</b>, cada uno de un color —la única "
         "manera de sacar una figura multicolor en un MSX1—, leyendo una "
         "lista de piezas y una tabla de tres bytes: cuánto sube, cuánto se "
         "corre y de qué color. El número de patrón ni siquiera está "
         "guardado: sale de <code>índice×4 + 0x60</code>.</p>"
         "<p>Y hay <b>tres golfistas</b>, que elige el palo: de 22, 29 y 35 "
         "piezas, con seis fotogramas de swing cada uno. Crece con el palo "
         "porque crece la cámara. El listado los tenía llamados «planos de "
         "hoyo 15, 16 y 17».</p>"),
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
        ("The perspective is never computed: it comes pre-drawn, stretch by stretch",
         "<p>The view of the course looks 3D and there is not one projection "
         "calculation behind it. The table at 0x6A2B holds <b>eighty maps</b> "
         "of 21×19 cells, four to six per hole, and moving up the hole means "
         "switching map: (0xE0B5) says which stretch the ball is in.</p>"
         "<p>Each map is assembled from two pieces that end up flush in RAM: "
         "<b>105 bytes</b> of sky, shared by the whole hole, and <b>294</b> of "
         "the stretch's ground. That is 21×5 and 21×14, and 0xEA00+105 lands "
         "exactly on 0xEA69, where the code decompresses the second. And "
         "getting closer is no zoom: it is painting <b>one fresh row of "
         "twenty-one cells</b> and stepping the pointer twenty-one at a "
         "time.</p>"),
        ("The golfer is nine interlocking sprites, and there are three of him",
         "<p>There is no drawing of a golfer in the cartridge: there are "
         "<b>pieces</b>. 0x4F8A composes every pose from up to <b>nine "
         "overlapping 16×16 sprites</b>, each in its own colour — the only "
         "way to get a multi-coloured figure on an MSX1 — reading a list of "
         "pieces and a three-byte table: how far up, how far across, what "
         "colour. The pattern number is not even stored: it falls out of "
         "<code>index×4 + 0x60</code>.</p>"
         "<p>And there are <b>three golfers</b>, chosen by the club: 22, 29 "
         "and 35 pieces, six swing frames each. He grows with the club because "
         "the camera does. The listing had them filed as “hole plans 15, 16 "
         "and 17”.</p>"),
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
     "Los diez sprites de 16×16 que 0x60A2 descomprime y copia a VRAM 0x3800. "
     "Cinco de ellos son la bola a cinco tamaños, que es como se ve alejarse. "
     "No son los únicos del cartucho: detrás, en 0x3B00, van las piezas del "
     "golfista",
     "The ten 16×16 sprites 0x60A2 decompresses and copies to VRAM 0x3800. "
     "Five of them are the ball at five sizes, which is how you watch it fly "
     "away. They are not the cartridge's only ones: the golfer's pieces go "
     "right behind them, at 0x3B00"),
    ("golfista.png",
     "<b>Los tres golfistas</b>, con sus seis fotogramas de swing. No hay "
     "ningún dibujo del golfista en el cartucho: cada postura son hasta "
     "<b>nueve sprites de 16×16 superpuestos</b>, cada uno de su color, que "
     "0x4F8A coloca leyendo una lista de piezas y una tabla de tres bytes. El "
     "palo elige cuál de los tres, y por eso cambia de tamaño: es la distancia "
     "a la que está la cámara",
     "<b>The three golfers</b>, with their six swing frames each. There is no "
     "picture of a golfer anywhere in the cartridge: every pose is up to "
     "<b>nine overlapping 16×16 sprites</b>, each in its own colour, placed by "
     "0x4F8A from a list of pieces and a three-byte table. The club picks "
     "which of the three, which is why the size changes: that is how far away "
     "the camera is"),
    ("swing_golfista.gif",
     "<b>El swing, jugado en openMSX</b> (un MSX1 japonés, a 60 cuadros por segundo; solo la barra, sin forzar "
     "nada). El fotograma lo lleva 0xE06E y la interrupción cambia uno cada <b>8 cuadros</b>: 1 mientras se "
     "apunta; con la primera pulsación, 2 y, si la fuerza ha pasado de 0x40 (0x4DBB), <b>3</b>, arriba del todo; "
     "con la segunda, otra vez 2 y luego 4, 5 y 6, que se queda. Cada cuadro grabado casa con las piezas que da la "
     "ROM para su fotograma (<code>tools/swing_cotejo.py</code>)",
     "<b>The swing, played in openMSX</b> (a Japanese MSX1, at 60 frames a second; just the space bar, nothing "
     "forced). 0xE06E holds the frame and the interrupt moves it on every <b>8 frames</b>: 1 while aiming; on the "
     "first press, 2 and, if the power has gone past 0x40 (0x4DBB), <b>3</b>, right at the top; on the second, 2 "
     "again and then 4, 5 and 6, which stays. Every recorded frame matches the pieces the ROM gives for its swing "
     "frame (<code>tools/swing_cotejo.py</code>)"),
    ("swing.gif",
     "El mismo golpe con la pantalla entera: la barra de POWER, el swing y la bola que sale. Después del golpe la "
     "vista sigue a la bola y el golfista baja hasta salir por abajo",
     "The same shot on the whole screen: the POWER bar, the swing and the ball flying off. After the shot the view "
     "follows the ball and the golfer slides down out of the bottom"),
    ("salidas.png",
     "<b>Los dieciocho hoyos vistos desde el tee</b>, con sus dos marcas "
     "blancas en primer plano. Cada uno es el primer tramo de su hoyo, "
     "resuelto celda a celda como lo hace el cartucho: el mapa de índices "
     "contra la lista de códigos acumulada, y de ahí a los patrones de 8×8",
     "<b>The eighteen holes seen from the tee</b>, their two white markers in "
     "the foreground. Each is its hole's first stretch, resolved cell by cell "
     "the way the cartridge does it: the index map against the accumulated "
     "code list, and from there to the 8×8 patterns"),
    ("vistas_hoyo01.png",
     "<b>Los cinco tramos del hoyo 1</b>, del tee al green, dibujados desde la "
     "ROM. Cada uno es un mapa de 19×21 índices que se monta en dos trozos: "
     "las cinco filas de cielo, comunes al hoyo, y las catorce de suelo del "
     "tramo. La perspectiva no se calcula en ninguna parte: <b>viene "
     "dibujada</b>",
     "<b>The five stretches of hole 1</b>, tee to green, drawn from the ROM. "
     "Each is a 19×21 map of indices assembled from two pieces: the five sky "
     "rows, shared by the whole hole, and the stretch's fourteen ground rows. "
     "The perspective is never computed anywhere: <b>it comes pre-drawn</b>"),
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
        tipo = "gif" if ruta.endswith(".gif") else "png"
        return "data:image/%s;base64," % tipo + base64.b64encode(f.read()).decode()


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
