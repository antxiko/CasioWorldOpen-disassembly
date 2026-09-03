# Empezar

Un desensamblado comentado de **Casio World Open**, el golf que Casio publicó
para MSX en 1985: un cartucho de 32 KB que ocupa las páginas 1 y 2
(0x4000-0xBFFF). Reensambla dando la ROM exacta, byte a byte, y cada uno de sus
32.768 bytes está explicado.

## El cartucho no está aquí

Ningún repositorio distribuye el juego. Pon tu propio volcado en la raíz como
`casioworldopen.rom`, 32768 bytes, sha256

    7b03fd41c11975131db7c2303aa0757b369c4f6e1e54586da8f2b70d68b8d19d

`make comprueba` lo verifica.

## Qué hace cada orden

    make            traza el flujo, arma el listado, lo reensambla y pasa los tests
    make verify     la prueba que decide: reensamblar tiene que devolver la ROM
    make sanity     que ni un byte quede sin explicar
    make densidad   cuánto está comentado, rutina a rutina
    make web        rehace esta web dibujando las imágenes desde la ROM

## Cómo está montado

El listado no se edita a mano: `tools/mkasm.py` lo arma desde un trazado de flujo
y un fichero de notas ancladas a direcciones, así que los comentarios sobreviven
a un retrazado. Los puntos de entrada que el trazador no puede deducir solo van
declarados en `src/casioworldopen.entries`, cada uno con su motivo.

Las imágenes tampoco son capturas: `tools/graficos.py` las dibuja ejecutando en
Python la misma cadena de descompresión e indirección que corre el Z80.
