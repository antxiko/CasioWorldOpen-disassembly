# El cartucho

Casio World Open es un cartucho de **32 KB** de Casio, de 1985, que ocupa las
páginas 1 y 2 (0x4000-0xBFFF).

## La cabecera

La cabecera `AB` de 0x4000 declara **sólo INIT, en 0x4010**. Ni STATEMENT, ni
DEVICE, ni TEXT.

## Dos modos de pantalla

El título va en **SCREEN 1**, el modo de texto de 32 columnas: la fuente la pone
la BIOS y el color de toda la pantalla cabe en 32 bytes, uno por cada ocho
patrones. El juego va en **SCREEN 2**, y usado como bitmap: la tabla de nombres
es la identidad y el dibujo vive entero en la tabla de patrones.

El paso de uno a otro tiene truco. 0x44F3 entra en SCREEN 1 sólo para quedarse
con el juego de caracteres que acaba de cargar la BIOS, lo copia a RAM y, ya en
SCREEN 2, lo vuelca como patrones del campo.

## La interrupción

Hay dos manejadores. El de arranque (0x415B) es temporal: llama al definitivo y,
la primera vez, remata la inicialización. El definitivo (0x44D3) es el que corre
toda la partida, enganchado en H.TIMI.

## El reparto de los 32 KB

| | bytes | |
|---|---|---|
| código trazado | 8.185 | 24,98 % |
| datos identificados | 24.583 | 75,02 % |
| **sin explicar** | **0** | **0,00 %** |
