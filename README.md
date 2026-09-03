# Casio World Open (Casio, 1985) — a commented disassembly

A commented disassembly of the 32 KB MSX cartridge, reproducible byte for byte.

**[Read the work →](https://antxiko.github.io/CasioWorldOpen-disassembly/)**
· [En castellano](README.es.md)

    make            # traces, builds the listing, reassembles it and runs the tests
    make verify     # the test that decides: reassembling must give back the ROM
    make sanity     # that not one byte is left unexplained
    make densidad   # how much is commented, routine by routine
    make web        # rebuilds the site

The ROM is **not distributed here**. Put your own dump in the root as
`casioworldopen.rom`, 32768 bytes, sha256

    7b03fd41c11975131db7c2303aa0757b369c4f6e1e54586da8f2b70d68b8d19d

`make comprueba` checks it.

## Where it stands

| | |
|---|---|
| reassembles byte for byte | yes |
| bytes explained | 32,768 of 32,768 (100%) |
| traced code | 8,185 bytes |
| identified data | 24,583 bytes across 153 named ranges |
| commented | 1,532 line comments, 37.0% |
| routines below 10% | 0 of 435 |

The annotations live apart from the listing, anchored to the address they
describe, so they survive a re-trace. What the `.notes` holds:

| | |
|---|---|
| named labels | 435 |
| anchored comments | 1487 |
| explained data ranges | 153 |

And the site's pictures are not captures: Python paints them by running the same
chain the Z80 runs, and they are checked against openMSX's VRAM — the wordmark's
**304 bytes identical**, 766 of the title's 768 cells, and a hole plan that comes
out **186 of its 190 cells identical**, pattern and colour, to a live frame.

## Eighteen holes from ten layouts

The pointer table holds eighteen entries but only ten distinct layouts. Eight
are played twice, and in every pair one runs **mirrored** — a single bit in the
hole's record, with the drawing loop flipping the pattern bit by bit.

## What is here

- `src/casioworldopen.asm` — the listing; generated, not hand-written
- `src/casioworldopen.notes` — the annotations, anchored to addresses
- `src/casioworldopen.nombres` — the routine names, kept apart to be read in one go
- `docs/` — the site, in English and Spanish
- `tools/` — the tracer, the listing builder, and the decompressor and
  indirection chain that draw the site's images from the ROM

## The work

| | |
|---|---|
| [Getting started](docs/GETTING-STARTED.md) | what you need and what each command does |
| [The game](docs/THE-GAME.md) | eighteen holes, par 72, and a wind drawn from the refresh register |
| [The cartridge](docs/THE-CARTRIDGE.md) | two screen modes, and a font that ends up as scenery |
| [The code](docs/THE-CODE.md) | differences accumulated into tile codes, and indices on top |
| [Findings](docs/FINDINGS.md) | ten layouts for eighteen holes, and only ten real sprites |
| [In the emulator](docs/IN-THE-EMULATOR.md) | what can be measured, and how |
| [Open questions](docs/OPEN-QUESTIONS.md) | what is not settled yet |

See `LEGAL-NOTICE.md`.
