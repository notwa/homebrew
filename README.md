currently, this just displays a test image and dumps
some text to a computer connected via the 64drive's USB port.
the image is [a test card by Väinö Helminen.](http://vah.dy.fi/testcard/)

i'm borrowing some code from [krom's repo.](https://github.com/PeterLemon/N64/)
this has been very useful in getting things up-and-running on the N64
and i suggest you check out their work.

the [Dwarf Fortress][dwarf] 8x12 font is included as a 1-bit-per-pixel image.

a [F3DZEX][zexdocs] disassembly is included. i did this myself.
disassemblies of its data section and the 6102 bootcode
will be done in the future.

[dwarf]: http://www.bay12games.com/dwarves/
[zexdocs]: https://wiki.cloudmodding.com/oot/F3DZEX

### building

you will need to compile
[bass (the assembler)](https://github.com/ARM9/bass) (ARM9's fork)
and [z64crc](https://github.com/notwa/mm/blob/master/z64crc.c)
(to be included in this repo later). then, run:
```
bass main.asm
z64crc test.z64
```
