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
