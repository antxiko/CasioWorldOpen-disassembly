# The perspective view

It is the best thing in the cartridge, and the first thing to say is what it is
**not**: the view of the course is never computed. There is no projection, no
trigonometry, not one `call` into the tables the game uses for ball physics.
The perspective **comes pre-drawn** in the ROM, hole by hole and stretch by
stretch, and all the Z80 does is resolve two indirections and copy 8×8
patterns.

What follows is checked against the emulator's RAM and VRAM, not inferred:
`tools/omsx_vista.tcl` freezes the machine at the exact instant a row is being
painted and dumps both buffers.

## The eighty maps

The table at 0x6A2B holds ninety-eight pointers in eighteen groups, one per
hole; `tabla_tramos_por_hoyo` (0x5E54) says how many fall in each group,
between four and six. The first of each group is **105 bytes** and the rest are
**294**.

Those numbers tell the whole story: 105 is 21×5 and 294 is 21×14. The view is
**twenty-one columns** wide, and it is assembled from two pieces:

| piece | size | what it is |
|---|---|---|
| first of the group | 21×5 | sky and horizon, the same for the whole hole |
| one per stretch | 21×14 | the ground, different in each stretch |

`0x5B17` decompresses the first into 0xEA00 and `0x5B27` the second into
**0xEA69**, which is exactly 0xEA00+105. And 0xEA69+294 lands on 0xEB8F, which
is precisely where `0x56B7` leaves the scroll pointer. The two pieces end up
**butted together**: 399 consecutive bytes, nineteen rows of twenty-one
columns.

Once repeats are removed, the eighteen holes spend **eighty ground maps**. That
is the entire course.

## Three hops to paint one cell

None of those 399 bytes is a picture. Each one is an **index**, and it takes
three hops to reach a pixel:

1. **The index** goes into a list of sixteen-bit tile codes living at 0xE800.
   `0x5B61` walks it with `add hl,bc` twice, which is two-byte indexing.
2. **That list** is not stored as such: `0xA8CB` builds it when the hole
   starts, by decompressing two blocks and taking the **running sum** of their
   bytes. What the cartridge stores are differences.
3. **The code** that comes out indexes `tabla_patrones_terreno` (0x8B5E), 570
   uncompressed 8×8 patterns — and the colour arrives by a different road
   entirely: the chain of blocks at 0x9D2E, which `0x5EA5` walks header by
   header.

The 0xE800 list is built in **two consecutive passes**: first the codes shared
by every hole — 129 or 154, depending which — and the hole's own behind them.
That they sit flush is not a guess: the destination addresses the code writes
by hand, 0xE902 and 0xE934, are exactly 0xE800 plus the size of the first one.
Against the emulator's RAM both come out **without a single differing byte**.

## Getting closer is a name-table scroll

There is no zoom. What sells the forward motion is that `0x5D3C` paints **one
fresh row of twenty-one cells** at a time, while the pointer at 0xE0AE steps
through the map twenty-one at a time: backwards as you approach (`0x5C3A` adds
−21 to it) and forwards as you retreat. The rest of the screen shifts by
copying name-table strips from one part of VRAM to another.

And the ball picks the stretch: (0xE0B5) — the high byte of (0xE0B4) — is which
zone of the hole you are in, and it is what chooses which of the four to six
ground maps applies. That is why a hole is seen in chunks rather than all at
once.

## The golfer does not exist

There is no drawing of a golfer anywhere in the cartridge. What there is are
**pieces**, and every pose is composed on the spot from up to **nine
overlapping 16×16 sprites**, each in its own colour — the only way to get a
multi-coloured figure out of an MSX1.

`0x4F8A` is the loop that places them. It reads a list of piece numbers and,
for each one, goes to a **three-byte** table: how far up, how far left, and
what colour. The pattern number is stored nowhere — it falls out of a
calculation, `index×4 + 0x60`, at `0x4FBA` — and a zero closes the list early.

That this reading is the right one shows up in the subtraction: across the
eight pieces of the rest pose, (0xE099) minus the first byte gives **144** in
all eight, and (0xE098) minus the second gives **80** in all eight. And the
third byte matches the attribute's colour piece for piece.

## And there are three golfers, not one

`0x4BF8` looks at the club in (0xE114) and picks one of three complete sets:

| clubs | pieces | per frame | size |
|---|---|---|---|
| 1 to 7 | 22 | 6 | 32×48 |
| the 8 | 29 | 8 | 45×56 |
| 9 and up | 35 | 9 | 52×64 |

All three have **six swing frames**. And the split needs no guessing: the three
position tables measure 105, 87 and 66 bytes, which at three bytes per piece is
35, 29 and 22 — exactly what each sprite block carries — and the three lists
measure 54, 48 and 36, which is six frames of nine, eight and six.

The golfer grows with the club because **the camera grows**: with a short iron
you stand over the ball, with a wood you stand back. It is the same idea as the
view, solved the same way: instead of scaling anything, there are three
drawings.

## What it took to see it

The published listing called the eighty maps "golfer frames" and the three
piece blocks "hole plans 15, 16 and 17". They were the wrong way round: what
looked like the golfer was the course, and the three blocks nobody could place
turned out to be the golfer.

Two numbers gave it away. That 0xEA69 minus 0xEA00 came to 105, and that 105
and 294 are both multiples of 21, suggested the width was 21 and not a sprite;
and that the pattern came out of `index×4 + 0x60` explained in one go the
patterns 96, 100, 104… that the emulator's attribute table had loaded.
