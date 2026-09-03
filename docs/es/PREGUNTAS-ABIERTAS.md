# Preguntas abiertas

Todo el binario está explicado y lo que dibuja está contrastado. Lo que queda
son cabos.

## El formato interno de las listas de objetos

Las dieciocho listas de 0x6299 decodifican limpias —cuántos sub-bloques, cuántos
objetos por bloque, y cuatro bytes por objeto: la casilla y tres de atributo— y
de ahí salen los diez trazados y las ocho parejas espejadas.

Lo que no está cerrado es **qué dice cada uno de esos tres bytes de atributo**.
Por su rango parecen coordenadas dentro del hoyo, pero no está comprobado.

## ~~Las vistas de terreno y los cuadros del golfista~~ — cerrado

Estaba abierto y ya no lo está. Los «cuadros del golfista» no eran del
golfista: son los **ochenta mapas de la vista en perspectiva**, de 21×19, y el
golfista son tres juegos de piezas de sprite aparte. La lista acumulada sobre
la que se leen se monta en dos tandas seguidas en 0xE800, y contra la RAM del
emulador sale sin un byte de diferencia. Está contado en
[la vista 3D](LA-VISTA-3D.html).

## La cadena de bloques de 0x9D2E

Treinta y seis bloques encadenados sin tabla de punteros: cada cabecera dice
cuánto saltar hasta el siguiente. Verificados uno a uno, pero sin identificar qué
dibuja cada cual.

## Los cuatro bytes que sobran de la ficha del hoyo

De los cinco de cada entrada de 0x45A8, el primero está cerrado —par y espejo—.
Los otros cuatro se leen a (0xE0A1)-(0xE0A4) y no están identificados.
