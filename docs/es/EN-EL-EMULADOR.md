# En el emulador

Las imágenes no son capturas, pero el emulador sí se usa: para comprobarlas, y
para preguntarle al juego lo que el listado tarda en decir.

## Los volcados

`tools/omsx_vram.tcl` y `tools/omsx_juega.tcl` guardan la VRAM, los registros
del VDP y una captura, por reloj emulado y sin puntos de ruptura.

    python3 tools/graficos.py casioworldopen.rom 0x4000 comprueba work/omsx

De la pantalla de título salen los **304 bytes del logotipo idénticos**, los
**32 de color idénticos** y 766 de las 768 celdas de nombre.

## Preguntarle al juego quién dibuja

Cuando el plano del hoyo no aparecía por ninguna parte leyendo el listado,
`tools/omsx_quien_dibuja.tcl` lo resolvió: un punto de ruptura en el dibujante de
patrones, anotando la dirección de retorno y los parámetros de cada llamada.

Las 3.522 llamadas venían de un solo sitio, y subiendo un nivel salieron dos
llamantes con sus destinos: uno pintando de la celda 22 a la 607, que es
exactamente **filas 0 a 18, columnas 22 a 31**. El plano. De ahí al listado, y
del listado a 0x5DEC.

## Congelar la máquina donde toca

Los buffers de RAM se reutilizan tres veces por cuadro: 0xE800 es la lista
acumulada de códigos, pero durante el scroll esa misma zona hace de caché de
patrones traídos de la VRAM, y 0xEA00 es a la vez el mapa de la vista y otro
buffer de patrones. Volcar la RAM «en un momento cualquiera» no dice nada.

`tools/omsx_vista.tcl` para la máquina en el instante exacto en que se pinta
una fila de la vista y vuelca los dos buffers. Ahí sí:

| lo montado en Python | contra la RAM real |
|---|---|
| mapa de la vista, 399 bytes (105+294) | **0 distintos** |
| lista común del fondo, 129 códigos | **0 distintos** |
| lista propia del hoyo, 59 códigos | **0 distintos** |

Y el mismo script anota lo que resuelve `tile_por_indice` celda por celda: de
las **399 celdas** de la vista del hoyo 1, el índice leído y el código de tile
que sale coinciden con los calculados **en las 399**.

## Los planos de hoyo, uno por uno

`tools/omsx_vram_hoyo.tcl` fuerza el hoyo que se le pida escribiéndolo en
(0xE0B4) con un solo punto de ruptura, y así se comprueban los espejados sin
jugarse doce hoyos. En seis hoyos —tres espejados y tres no— las **190 celdas**
del plano salen idénticas, patrón y color:

    hoyo 1  espejo=False   190 celdas, 0 distintas
    hoyo 2  espejo=True    190 celdas, 0 distintas
    hoyo 3  espejo=False   190 celdas, 0 distintas
    hoyo 5  espejo=True    190 celdas, 0 distintas
    hoyo 12 espejo=True    190 celdas, 0 distintas
    hoyo 17 espejo=True    190 celdas, 0 distintas

## El golfista, leído de la tabla de atributos

`tools/omsx_quien_sprites.tcl` anota los LDIRVM que caen en la tabla de
patrones de sprite. Salen dos: 320 bytes a 0x3800 y **1120 a 0x3B00**, que es
el patrón 96 —justo donde empieza el golfista—. Ese segundo bloque coincide
byte a byte con 0xB4AE descomprimido.

Y la tabla de atributos confirma la lectura de las posiciones: con las ocho
piezas del cuadro de reposo, (0xE099) menos el primer byte de la tabla da
**144** en las ocho, y (0xE098) menos el segundo da **80** en las ocho.

## El contraste que decide

De las 768 celdas de un cuadro de partida real, **718 son patrones de
`tabla_patrones_terreno`**. No es que las imágenes se parezcan: es que salen de
la misma tabla, byte a byte.

## Por que el titulo sale sin su texto

En la pantalla de titulo, el logotipo lo pone el cartucho —304 bytes en
0x4301— pero **el texto lo escribe la maquina con la fuente de su propia
BIOS**, que INIT32 carga en la tabla de patrones. Esa fuente no esta en la ROM
del juego, asi que dibujando solo desde el cartucho salen el logotipo y el
fondo, y los renglones en blanco. Por eso la web ensena el rotulo y no la
pantalla entera.
