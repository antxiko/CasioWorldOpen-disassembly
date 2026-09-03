# Findings

## Ten layouts for eighteen holes

The table at 0x6299 holds eighteen pointers, but they point at **ten lists**.
Eight serve two holes each; only 1 and 18 have a layout of their own.

What separates the two holes of a pair is one bit: bit 7 of the first byte of
its record at 0x45A8. With it set, the drawing loop advances the pointer nine
places and walks the data backwards, and 0x5E7C flips the pattern bit by bit.
Across all eight pairs, without exception, one carries it and the other does
not.

## What is compressed are differences, not pictures

0xA8CB decompresses, puts a zero after every byte and takes the running total.
The result is a list of tile codes. Sixteen bits are needed because the pattern
table has 570 entries, which is why 0x5B61 indexes with two `add hl,bc`.

## Everything else is indices

Hole plans, terrain views and golfer frames store positions inside that
accumulated list. The same map draws different things depending on which list
was accumulated first.

## Par in half a byte

The low nibble of the record's first byte is the par; bit 7 of that same byte is
the mirror. Added up, the eighteen give par 72.

## Ten sprites, and five are the same ball

The only thing that reaches the VDP's sprite pattern table is the 320 bytes
0x60A2 leaves at VRAM 0x3800: ten 16×16 sprites. Five are the ball at five
sizes, which is how you watch it fly away. The golfer, the trees and the terrain
are not sprites: they are painted into the bitmap.

## The machine's font ends up as scenery

0x44F3 enters SCREEN 1 only to keep the character set the BIOS loads, copies it
to RAM and in SCREEN 2 dumps it back as the course's patterns.

## Five bytes nobody runs

At 0x4B04 sit `ld a,080h / ld (0e077h),a`, two valid instructions wedged between
a `jp` and the next routine, which not one jump in the whole cartridge reaches.
What they do is alive at 0x5520, with a call in front.
