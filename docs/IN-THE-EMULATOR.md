# In the emulator

The images are not captures, but the emulator does get used: to check them, and
to ask the game what the listing takes longer to say.

## The dumps

`tools/omsx_vram.tcl` and `tools/omsx_juega.tcl` save the VRAM, the VDP
registers and a screenshot, by emulated clock and without breakpoints.

    python3 tools/graficos.py casioworldopen.rom 0x4000 comprueba work/omsx

From the title screen come the wordmark's **304 bytes identical**, its **32 of
colour identical**, and 766 of the 768 name-table cells.

## Asking the game who draws

When the hole plan would not turn up anywhere in the listing,
`tools/omsx_quien_dibuja.tcl` settled it: a breakpoint on the pattern drawer,
logging the return address and the parameters of every call.

All 3,522 calls came from one place, and going up a level gave two callers with
their destinations: one painting from cell 22 to cell 607, which is exactly
**rows 0 to 18, columns 22 to 31**. The plan. From there back to the listing,
and from the listing to 0x5DEC.

## The comparison that decides

Of the 768 cells of a real in-game frame, **718 are patterns from
`tabla_patrones_terreno`**. It is not that the pictures look alike: they come
out of the same table, byte for byte.

## Why the title comes out without its text

On the title screen the wordmark comes from the cartridge — 304 bytes at
0x4301 — but **the text is written by the machine with its own BIOS font**,
which INIT32 loads into the pattern table. That font is not in the game's ROM,
so drawing from the cartridge alone gives the wordmark and the background with
the lines blank. That is why the site shows the wordmark and not the whole
screen.
