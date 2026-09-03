# The cartridge

Casio World Open is a **32 KB** Casio cartridge from 1985, filling pages 1 and 2
(0x4000-0xBFFF).

## The header

The `AB` header at 0x4000 declares **only INIT, at 0x4010**. No STATEMENT, no
DEVICE, no TEXT.

## Two screen modes

The title runs in **SCREEN 1**, the 32-column text mode: the BIOS supplies the
font and the colour for the whole screen fits in 32 bytes, one per eight
patterns. The game runs in **SCREEN 2**, used as a bitmap: the name table is the
identity map and the picture lives entirely in the pattern table.

Getting from one to the other has a trick. 0x44F3 enters SCREEN 1 only to keep
the character set the BIOS has just loaded, copies it to RAM and, once in
SCREEN 2, dumps it back as the course's patterns.

## The interrupt

There are two handlers. The start-up one (0x415B) is temporary: it calls the
real one and, the first time round, finishes the initialisation. The real one
(0x44D3) runs the whole game, hooked into H.TIMI.

## How the 32 KB break down

| | bytes | |
|---|---|---|
| traced code | 8,185 | 24.98 % |
| identified data | 24,583 | 75.02 % |
| **unexplained** | **0** | **0.00 %** |
