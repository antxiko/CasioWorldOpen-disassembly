# Open questions

The whole binary is explained and what it draws is checked. What is left are
loose ends.

## The internal format of the object lists

The eighteen lists at 0x6299 decode cleanly — how many sub-blocks, how many
objects per block, and four bytes per object: the cell and three of attribute —
and out of them come the ten layouts and the eight mirrored pairs.

What is not settled is **what each of those three attribute bytes says**. Their
range looks like coordinates within the hole, but that is not confirmed.

## ~~Terrain views and golfer frames~~ — closed

This was open and no longer is. The "golfer frames" were not the golfer's: they
are the **eighty perspective-view maps**, 21×19 each, and the golfer is three
separate sets of sprite pieces. The accumulated list they are read against is
built in two consecutive passes at 0xE800, and against the emulator's RAM it
comes out without a single differing byte. It is all written up in
[the 3D view](THE-3D-VIEW.html).

## The chained blocks at 0x9D2E

Thirty-six blocks chained without a pointer table: each header says how far to
jump to the next. Verified one by one, but with no identification of what each
one draws.

## The four spare bytes of the hole record

Of the five in each entry at 0x45A8, the first is settled — par and mirror. The
other four are read into (0xE0A1)-(0xE0A4) and are not identified.
