# The code

## One decompressor and a running total

`0xA8FB` is simple: a two-byte header says how many **source** bytes are left to
consume, an 0xFF opens a run with its count and value, and any other byte is
copied as it is.

What is interesting is what `0xA8CB` does **after** decompressing: it puts a
zero after every byte — turning the run into sixteen-bit values — and takes the
running total of them all. What comes out is not a picture: it is a list of tile
codes.

## And on top, indirection

The hole plans and the eighty perspective-view maps store **indices** into
that list, one byte per cell. `0x5B61` resolves them: it enters the list with
`add hl,bc` twice — sixteen-bit indexing, because the pattern table has 570
entries — and hands the code to `0x5E66`, which copies the 8×8 pattern to VRAM.

## The mirror, inside the loop

`0x5E66` checks bit 7 of (0xE0A0) and, if it is set, flips the pattern bit by
bit with `rlc` and `rra` before copying it. And the loops that walk the maps do
the same: they advance the pointer and then run backwards. With that, half the
course is drawn without storing one more byte.

## Dispatch by bits

Three variables — (0xE001), (0xE06C) and (0xE077) — work as to-do lists: the
interrupt handler rotates them and, for every bit set, calls the phase it
belongs to. That is how a frame's work gets shared out without an explicit state
machine.

## How it is traced

Of the 32,768 bytes, 8,185 are code actually reached and 24,583 are data
declared one by one. The five bytes at 0x4B04 are a curious case: valid code —
`ld a,080h / ld (0e077h),a` — that no jump in the whole cartridge reaches.
