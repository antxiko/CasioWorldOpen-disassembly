# Hallazgos

## Diez trazados para dieciocho hoyos

La tabla de 0x6299 tiene dieciocho punteros, pero apuntan a **diez listas**.
Ocho sirven a dos hoyos cada una; sólo el 1 y el 18 tienen trazado propio.

Lo que separa a los dos hoyos de una pareja es un bit: el 7 del primer byte de
su ficha en 0x45A8. Con él puesto, el bucle de dibujo adelanta el puntero nueve
posiciones y recorre los datos hacia atrás, y 0x5E7C le da la vuelta al patrón
bit a bit. En las ocho parejas, sin excepción, uno lo lleva y el otro no.

## Lo comprimido son diferencias, no dibujos

0xA8CB descomprime, separa cada byte con un cero y hace la suma acumulada. El
resultado es una lista de códigos de tile. Hacen falta dieciséis bits porque la
tabla de patrones tiene 570 entradas, y por eso 0x5B61 indexa con dos
`add hl,bc`.

## Todo lo demás son índices

Planos de hoyo, vistas de terreno y cuadros del golfista guardan posiciones
dentro de esa lista acumulada. El mismo mapa dibuja cosas distintas según qué
lista se haya acumulado antes.

## El par en medio byte

El nibble bajo del primer byte de la ficha es el par; el bit 7 del mismo byte es
el espejo. Sumados los dieciocho, par 72.

## Diez sprites, y cinco son la misma bola

Lo único que llega a la tabla de patrones de sprite del VDP son los 320 bytes
que 0x60A2 deja en VRAM 0x3800: diez sprites de 16×16. Cinco son la bola a cinco
tamaños, que es como se la ve alejarse. El golfista, los árboles y el terreno no
son sprites: están pintados en el bitmap.

## La fuente de la máquina acaba siendo decorado

0x44F3 entra en SCREEN 1 sólo para quedarse con el juego de caracteres que carga
la BIOS, lo copia a RAM y en SCREEN 2 lo vuelca como patrones del campo.

## Cinco bytes que no ejecuta nadie

En 0x4B04 hay `ld a,080h / ld (0e077h),a`, dos instrucciones válidas encajadas
entre un `jp` y la rutina siguiente, a las que no llega ni un salto de todo el
cartucho. Lo que hacen está vivo en 0x5520, con una llamada delante.
