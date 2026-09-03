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

## Freezing the machine at the right instant

The RAM buffers are reused three times a frame: 0xE800 is the accumulated code
list, but during the scroll that same area doubles as a cache of patterns
fetched from VRAM, and 0xEA00 is both the view map and yet another pattern
buffer. Dumping RAM "at some point" tells you nothing.

`tools/omsx_vista.tcl` stops the machine at the exact instant a row of the view
is being painted and dumps both buffers. There it holds:

| assembled in Python | against real RAM |
|---|---|
| view map, 399 bytes (105+294) | **0 differing** |
| shared background list, 129 codes | **0 differing** |
| the hole's own list, 59 codes | **0 differing** |

The same script logs what `tile_por_indice` resolves, cell by cell: across the
**399 cells** of hole 1's view, the index read and the tile code it yields match
the computed ones **in all 399**.

## The hole plans, one by one

`tools/omsx_vram_hoyo.tcl` forces whichever hole you ask for by writing it into
(0xE0B4) from a single breakpoint, so the mirrored ones can be checked without
playing twelve holes. Across six holes — three mirrored, three not — the plan's
**190 cells** come out identical, pattern and colour:

    hole 1  mirrored=False   190 cells, 0 differing
    hole 2  mirrored=True    190 cells, 0 differing
    hole 3  mirrored=False   190 cells, 0 differing
    hole 5  mirrored=True    190 cells, 0 differing
    hole 12 mirrored=True    190 cells, 0 differing
    hole 17 mirrored=True    190 cells, 0 differing

## The golfer, read off the attribute table

`tools/omsx_quien_sprites.tcl` logs the LDIRVMs landing in the sprite pattern
table. Two show up: 320 bytes to 0x3800 and **1120 to 0x3B00**, which is pattern
96 — exactly where the golfer starts. That second block matches 0xB4AE
decompressed byte for byte.

And the attribute table confirms how the positions are read: across the eight
pieces of the rest pose, (0xE099) minus the table's first byte gives **144** in
all eight, and (0xE098) minus the second gives **80** in all eight.

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
