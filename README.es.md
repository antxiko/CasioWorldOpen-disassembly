# Casio World Open (Casio, 1985) — desensamblado comentado

Un desensamblado comentado del cartucho de 32 KB para MSX, reproducible byte a
byte.

**[Leer el trabajo →](https://antxiko.github.io/CasioWorldOpen-disassembly/es/)**
· [In English](README.md)

    make            # traza, arma el listado, lo reensambla y pasa los tests
    make verify     # la prueba que decide: reensamblar tiene que devolver la ROM
    make sanity     # que ni un byte quede sin explicar
    make densidad   # cuanto esta comentado, rutina a rutina
    make web        # rehace la web

La ROM **no se distribuye aqui**. Pon tu propio volcado en la raiz como
`casioworldopen.rom`, 32768 bytes, sha256

    7b03fd41c11975131db7c2303aa0757b369c4f6e1e54586da8f2b70d68b8d19d

`make comprueba` lo verifica.

## Como esta

| | |
|---|---|
| reensambla byte a byte | si |
| bytes explicados | 32.768 de 32.768 (100%) |
| codigo trazado | 8.185 bytes |
| datos identificados | 24.583 bytes en 153 rangos con nombre |
| comentado | 1.532 comentarios de linea, 37,0% |
| rutinas por debajo del 10% | 0 de 435 |

Las anotaciones viven aparte del listado, ancladas a la direccion que explican,
asi que sobreviven a un retrazado. Lo que hay en el `.notes`:

| | |
|---|---|
| etiquetas con nombre | 435 |
| comentarios anclados | 1487 |
| rangos de datos con explicación | 153 |

Y las imagenes de la web no son capturas: las pinta Python ejecutando la misma
cadena que corre el Z80, y estan comprobadas contra la VRAM de openMSX — los
**304 bytes del logotipo identicos**, 766 de las 768 celdas del titulo, y un
plano de hoyo que sale **186 de sus 190 celdas identicas**, patron y color, a un
cuadro de partida real.

## Dieciocho hoyos con diez trazados

La tabla de punteros tiene dieciocho entradas pero solo diez trazados distintos.
Ocho se juegan dos veces, y en cada pareja uno va **espejado** — un solo bit en
la ficha del hoyo, y el bucle de dibujo dandole la vuelta al patron bit a bit.

## Que hay aqui

- `src/casioworldopen.asm` — el listado; generado, no escrito a mano
- `src/casioworldopen.notes` — las anotaciones, ancladas a direcciones
- `src/casioworldopen.nombres` — los nombres de las rutinas, aparte para leerlos de un tiron
- `docs/` — la web, en castellano y en ingles
- `tools/` — el trazador, el montador del listado, y el descompresor y la cadena
  de indirecciones que dibujan las imagenes de la web desde la ROM

## El trabajo

| | |
|---|---|
| [Empezar](docs/es/EMPEZAR.md) | que hace falta y que hace cada orden |
| [El juego](docs/es/EL-JUEGO.md) | dieciocho hoyos, par 72, y un viento sacado del registro de refresco |
| [El cartucho](docs/es/EL-CARTUCHO.md) | dos modos de pantalla, y una fuente que acaba de decorado |
| [El codigo](docs/es/EL-CODIGO.md) | diferencias acumuladas en codigos de tile, e indices por encima |
| [Hallazgos](docs/es/HALLAZGOS.md) | diez trazados para dieciocho hoyos, y solo diez sprites de verdad |
| [En el emulador](docs/es/EN-EL-EMULADOR.md) | que se puede medir, y como |
| [Preguntas abiertas](docs/es/PREGUNTAS-ABIERTAS.md) | lo que aun no esta cerrado |

Ver `AVISO-LEGAL.md`.
