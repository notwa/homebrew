currently, this only displays a test image and dumps debugging text
to a computer connected via the 64drive's USB port.

some code is borrowed from [krom's repo.][krom]
their work has been invaluable in getting things started on the N64,
and i recommend checking it out.

some resources are scattered about for testing purposes.
the [Dwarf Fortress][dwarf] 8x12 font is included as a 1-bit-per-pixel image.
[a test card by Väinö Helminen][card] is included as well.

an [F3DZEX][zexdocs] disassembly is included. i did this myself.
disassemblies of its data section as well as the 6102 bootcode
will be done in the future.

[krom]: https://github.com/PeterLemon/N64/
[dwarf]: http://www.bay12games.com/dwarves/
[card]: http://vah.dy.fi/testcard/
[zexdocs]: https://wiki.cloudmodding.com/oot/F3DZEX

### building

you will need to compile
[bass (the assembler)](https://github.com/ARM9/bass) (ARM9's fork)
and [z64crc](https://github.com/notwa/mm/blob/master/z64crc.c)
(to be included in this repo later). then, run:
```
bass F3DZEX.asm  # only needs to be done once
bass main.asm
z64crc test.z64
```
