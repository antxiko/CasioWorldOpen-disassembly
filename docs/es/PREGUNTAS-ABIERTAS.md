# Preguntas abiertas

Todo el binario está explicado y lo que dibuja está contrastado. Lo que queda
son cabos.

## El formato interno de las listas de objetos

Las dieciocho listas de 0x6299 decodifican limpias —cuántos sub-bloques, cuántos
objetos por bloque, y cuatro bytes por objeto: la casilla y tres de atributo— y
de ahí salen los diez trazados y las ocho parejas espejadas.

Lo que no está cerrado es **qué dice cada uno de esos tres bytes de atributo**.
Por su rango parecen coordenadas dentro del hoyo, pero no está comprobado.

## Las vistas de terreno y los cuadros del golfista, fuera de contexto

Están decodificados y sus cuentas cuadran, pero son mapas de índices sobre una
lista acumulada que depende del terreno del momento. Dibujarlos sueltos no tiene
sentido, y dibujarlos en su sitio pide montar el estado completo de la partida.

## La cadena de bloques de 0x9D2E

Treinta y seis bloques encadenados sin tabla de punteros: cada cabecera dice
cuánto saltar hasta el siguiente. Verificados uno a uno, pero sin identificar qué
dibuja cada cual.

## Los cuatro bytes que sobran de la ficha del hoyo

De los cinco de cada entrada de 0x45A8, el primero está cerrado —par y espejo—.
Los otros cuatro se leen a (0xE0A1)-(0xE0A4) y no están identificados.
