# The game

Golf seen from behind the golfer, with the course in perspective filling most of
the screen and **the hole's plan down a strip on the right**. One or two play,
chosen with the trigger on the title screen.

## The course

Eighteen holes, **par 72**, split into nine out and nine in — that is how the
scoreboard labels them. Each hole's par fits in half a byte: it is the low
nibble of the first byte of its record.

| hole | par | | hole | par |
|---|---|---|---|---|
| OUT 1 | 4 | | IN 1 | 5 |
| OUT 2 | 3 | | IN 2 | 4 |
| OUT 3 | 4 | | IN 3 | 4 |
| OUT 4 | 4 | | IN 4 | 4 |
| OUT 5 | 4 | | IN 5 | 3 |
| OUT 6 | 4 | | IN 6 | 4 |
| OUT 7 | 5 | | IN 7 | 4 |
| OUT 8 | 4 | | IN 8 | 4 |
| OUT 9 | 4 | | IN 9 | 4 |

## The scoreboard

Along the bottom sit **POWER** with its bar, **CLUB** with the chosen iron,
**WIND** with its strength and arrow, and the hole with its par. On the right,
the plan, with the distance still to go.

## The wind

It is drawn at the start of every hole with `ld a,r`, the memory refresh
register: the Z80 keeps it itself and it advances with every instruction, so its
value at any given moment cannot be predicted. No random generator, and no table
taking up room.

## The sound

A **sixteen-channel** player, each channel with its own 0x20-byte structure from
0xF401 and its own bytecode: note, volume, envelope, jump and rewind commands.
Blocks are registered with 0xBD03 and stopped with 0xBD2A.
