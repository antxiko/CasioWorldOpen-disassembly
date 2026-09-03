# Getting started

A commented disassembly of **Casio World Open**, the golf game Casio released
for the MSX in 1985: a 32 KB cartridge filling pages 1 and 2 (0x4000-0xBFFF). It
reassembles into the exact ROM, byte for byte, and every one of its 32,768 bytes
is accounted for.

## The cartridge is not here

No repository distributes the game. Put your own dump in the root as
`casioworldopen.rom`, 32768 bytes, sha256

    7b03fd41c11975131db7c2303aa0757b369c4f6e1e54586da8f2b70d68b8d19d

`make comprueba` checks it.

## What each command does

    make            traces the flow, builds the listing, reassembles it and runs the tests
    make verify     the test that decides: reassembling must give the ROM back
    make sanity     that not one byte is left unexplained
    make densidad   how much is commented, routine by routine
    make web        rebuilds this site, drawing the images from the ROM

## How it is put together

The listing is not edited by hand: `tools/mkasm.py` builds it from a flow trace
and a file of notes anchored to addresses, so the comments survive a re-trace.
The entry points the tracer cannot work out on its own are declared in
`src/casioworldopen.entries`, each with its reason.

The images are not captures either: `tools/graficos.py` draws them by running in
Python the same decompression-and-indirection chain the Z80 runs.
