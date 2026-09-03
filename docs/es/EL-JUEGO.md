# El juego

Golf visto desde detrás del golfista, con el campo en perspectiva ocupando la
mayor parte de la pantalla y **el plano del hoyo en una franja a la derecha**.
Juegan uno o dos, y se elige con el disparo en la pantalla de título.

## El campo

Dieciocho hoyos, **par 72**, repartidos en nueve de ida (OUT) y nueve de vuelta
(IN) —así los rotula el marcador—. El par de cada uno cabe en medio byte: es el
nibble bajo del primer byte de su ficha.

| hoyo | par | | hoyo | par |
|---|---|---|---|---|
| OUT 1 | 4 | | IN 1 | 5 |
| OUT 2 | 3 | | IN 2 | 4 |
| OUT 3 | 4 | | IN 3 | 4 |
| OUT 4 | 4 | | IN 4 | 4 |
| OUT 5 | 4 | | IN 5 | 3 |
| OUT 6 | 4 | | IN 6 | 4 |
| OUT 7 | 5 | | IN 7 | 4 |
| OUT 8 | 4 | | IN 8 | 4 |
| OUT 9 | 4 | | IN 9 | 4 |

## El marcador

Abajo van **POWER** con su barra, **CLUB** con el palo elegido, **WIND** con su
fuerza y su flecha, y el hoyo con su par. A la derecha, el plano, con la
distancia que queda al green.

## El viento

Se sortea al empezar cada hoyo con `ld a,r`, el registro de refresco de la
memoria: lo lleva el propio Z80 y avanza con cada instrucción, así que su valor
en un instante cualquiera no se puede prever. Sin generador de aleatorios y sin
gastar una tabla.

## El sonido

Un reproductor de **dieciséis canales**, cada uno con su estructura de 0x20
bytes a partir de 0xF401 y su propio bytecode: órdenes de nota, volumen,
envolvente, salto y rebobinado. Los bloques se dan de alta con 0xBD03 y se
apagan con 0xBD2A.
