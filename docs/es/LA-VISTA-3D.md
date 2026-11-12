# La vista en perspectiva

Es lo mejor del cartucho, y conviene decir primero lo que **no** es: la vista
del campo no se calcula. No hay proyección, ni trigonometría, ni un solo
`call` a las tablas que el juego usa para la física de la bola. La perspectiva
**viene dibujada** en la ROM, hoyo por hoyo y tramo por tramo, y lo único que
hace el Z80 es resolver dos indirecciones y copiar patrones de 8×8.

Lo que sigue está comprobado contra la RAM y la VRAM del emulador, no deducido:
`tools/omsx_vista.tcl` congela la máquina en el instante exacto en que se pinta
una fila y vuelca los dos buffers.

## Los ochenta mapas

La tabla de 0x6A2B tiene noventa y ocho punteros repartidos en dieciocho
grupos, uno por hoyo; `tabla_tramos_por_hoyo` (0x5E54) dice cuántos caen en
cada grupo, entre cuatro y seis. El primero del grupo son **105 bytes** y los
demás **294**.

Esos números lo cuentan todo: 105 son 21×5 y 294 son 21×14. La vista es de
**veintiuna columnas**, y se monta en dos trozos:

| trozo | tamaño | qué es |
|---|---|---|
| el primero del grupo | 21×5 | el cielo y el horizonte, iguales para todo el hoyo |
| uno por tramo | 21×14 | el suelo, distinto en cada tramo |

`0x5B17` descomprime el primero en 0xEA00 y `0x5B27` el segundo en **0xEA69**,
que es exactamente 0xEA00+105. Y 0xEA69+294 da 0xEB8F, que es justo donde
`0x56B7` deja el puntero de scroll. Los dos trozos quedan **pegados**: 399
bytes seguidos, que son diecinueve filas de veintiuna columnas.

Quitando repetidos, los dieciocho hoyos gastan **ochenta mapas de suelo**. Eso
es todo el campo del juego.

## Tres saltos para pintar una celda

Ninguno de esos 399 bytes es un dibujo. Cada uno es un **índice**, y hacen
falta tres saltos para llegar al pixel:

1. **El índice** entra en una lista de códigos de tile de dieciséis bits que
   vive en 0xE800. `0x5B61` la recorre con `add hl,bc` dos veces, que es
   indexado de dos bytes.
2. **Esa lista** no está guardada tal cual: `0xA8CB` la fabrica al empezar el
   hoyo descomprimiendo dos bloques y haciendo la **suma acumulada** de sus
   bytes. Lo que el cartucho guarda son diferencias.
3. **El código** que sale de ahí entra en `tabla_patrones_terreno` (0x8B5E),
   570 patrones de 8×8 sin comprimir, y el color por otro camino distinto: la
   cadena de bloques de 0x9D2E, que `0x5EA5` recorre saltando de cabecera en
   cabecera.

La lista de 0xE800 se monta **en dos tandas seguidas**: primero los códigos
comunes a todos los hoyos —129 ó 154, según cuál— y detrás los del hoyo. Que
van pegadas no es una suposición: las direcciones de destino que el código
escribe a mano, 0xE902 y 0xE934, son exactamente 0xE800 más el tamaño de la
primera. Contra la RAM del emulador salen las dos **sin un byte de
diferencia**.

## El acercarse es un scroll de tabla de nombres

No hay zoom. Lo que da la sensación de avanzar es que `0x5D3C` pinta **una fila
nueva de veintiuna celdas** cada vez, y el puntero de 0xE0AE se mueve de
veintiuno en veintiuno por el mapa: hacia atrás al acercarse (`0x5C3A` le suma
−21) y hacia delante al alejarse. El resto de la pantalla se desplaza copiando
franjas de la tabla de nombres de un sitio a otro de la VRAM.

Y el tramo lo elige la bola: (0xE0B5) —el byte alto de (0xE0B4)— es en qué
zona del hoyo se está, y es el que escoge cuál de los cuatro o seis mapas de
suelo toca. Por eso el hoyo se ve por trozos y no de un tirón.

## El golfista no existe

En el cartucho no hay ningún dibujo de un golfista. Lo que hay son **piezas**,
y cada postura se compone en el momento con hasta **nueve sprites de 16×16
superpuestos**, cada uno con su propio color, que es la única manera de sacar
una figura de varios colores en un MSX1.

`0x4F8A` es el bucle que los coloca. Lee una lista de números de pieza y, por
cada uno, va a una tabla de **tres bytes**: cuánto sube, cuánto se corre a la
izquierda y de qué color va. El número de patrón no está guardado en ninguna
parte —sale de una cuenta, `índice×4 + 0x60`, en `0x4FBA`—, y el cero cierra la
lista antes de tiempo.

Que la lectura es la correcta se ve al restar: con las ocho piezas del cuadro
de reposo, (0xE099) menos el primer byte da **144** en las ocho, y (0xE098)
menos el segundo da **80** en las ocho. Y el tercer byte coincide con el color
del atributo pieza por pieza.

## Y son tres golfistas, no uno

`0x4BF8` mira el palo en (0xE114) y elige uno de tres juegos completos:

| palos | piezas | por fotograma | tamaño |
|---|---|---|---|
| 1 a 7 | 22 | 6 | 32×48 |
| el 8 | 29 | 8 | 45×56 |
| 9 y siguientes | 35 | 9 | 52×64 |

Los tres tienen **seis fotogramas** de swing, y jugando no salen en orden: grabado en openMSX
(`tools/guiones/swing.tcl`, solo la barra), el fotograma (0xE06E) cambia cada **8 cuadros**: el 1 mientras se
apunta; con la primera pulsación, el 2 y, si la fuerza ha pasado de 0x40 (`mira_el_angulo_alto`, 0x4DBB), el **3**,
arriba del todo, que se queda mientras sube la otra barra; con la segunda, otra vez el 2 y luego el 4, el 5 y el 6.
Con poca fuerza el 3 no sale nunca. Cada cuadro grabado casa con las piezas que da la ROM para su fotograma
(`tools/swing_cotejo.py`); los GIF están en la portada. Y el reparto no hay que
adivinarlo: las tres tablas de posición miden 105, 87 y 66 bytes, que a tres
bytes por pieza son 35, 29 y 22 —exactamente las que trae cada bloque de
sprites—, y las tres listas miden 54, 48 y 36, que son seis fotogramas de
nueve, ocho y seis.

El golfista crece con el palo porque **crece la cámara**: con un hierro corto
se está encima de la bola y con una madera se está lejos. Es la misma idea que
la vista, resuelta de la misma manera: en vez de escalar nada, hay tres
dibujos.

## Lo que costó verlo

El listado publicado llamaba a los ochenta mapas «cuadros del golfista» y a los
tres bloques de piezas «planos de hoyo 15, 16 y 17». Estaban al revés: lo que
parecía el golfista era el campo, y los tres bloques que nadie sabía qué eran
resultaron ser el golfista.

Lo que lo destapó fue mirar dos números. Que 0xEA69 menos 0xEA00 diera 105 y
que 105 y 294 fueran los dos múltiplos de 21 hizo sospechar que la anchura era
21 y no un sprite; y que el patrón saliera de `índice×4 + 0x60` explicó de
golpe los patrones 96, 100, 104… que la tabla de atributos del emulador tenía
puestos.
