# El código

## Un descompresor y una suma

`0xA8FB` es sencillo: una cabecera de dos bytes dice cuántos bytes de **fuente**
quedan por consumir, un 0xFF abre una racha con su cuenta y su valor, y
cualquier otro byte se copia tal cual.

Lo interesante es lo que hace `0xA8CB` **después** de descomprimir: separa cada
byte con un cero —convirtiendo la tira en valores de dieciséis bits— y hace la
suma acumulada de todos ellos. Lo que sale no es un dibujo: es una lista de
códigos de tile.

## Y encima, indirección

Los planos de hoyo, las vistas de terreno y los cuadros del golfista guardan
**índices** dentro de esa lista, un byte por celda. `0x5B61` los resuelve: entra
en la lista con `add hl,bc` dos veces —indexado de dieciséis bits, porque la
tabla de patrones tiene 570 entradas— y pasa el código a `0x5E66`, que copia el
patrón de 8×8 a la VRAM.

## El espejo, dentro del bucle

`0x5E66` mira el bit 7 de (0xE0A0) y, si está puesto, le da la vuelta al patrón
bit a bit con `rlc` y `rra` antes de copiarlo. Y los bucles que recorren los
mapas hacen lo propio: adelantan el puntero y lo recorren hacia atrás. Con eso,
la mitad del campo se dibuja sin guardar un byte más.

## El despacho por bits

Tres variables —(0xE001), (0xE06C) y (0xE077)— funcionan como listas de tareas:
el manejador de interrupción las va rotando y, por cada bit puesto, llama a la
fase que le toca. Es la manera de repartir el trabajo de un cuadro sin una
máquina de estados explícita.

## Cómo se traza

De los 32.768 bytes, 8.185 son código alcanzado de verdad y 24.583 son datos
declarados uno a uno. Los cinco bytes de 0x4B04 son un caso curioso: código
válido —`ld a,080h / ld (0e077h),a`— al que no llega ningún salto de todo el
cartucho.
