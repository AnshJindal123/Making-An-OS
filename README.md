# Making-An-OS
Here, i will attempt to make an OS from scratch


exec- 
make
qemu-system-i386 -fda build/main_floppy.img -display curses


requiremnts-
1. any test editor
2. make
3. Nasm assembler
4. vm
5. WSL


using x86

What happens when you start your computer-
1. BIOS kicks in (copied from rom to ram)
2. BIOS starts executing code- 
	A. initialises hardware
	B. runs some tests
3. BIOS searches for an OS
4. BIOS loads and starts the OS
5. OS runs

HOW THE BIOS FINDS THE OS?-

1) Legacy booting-
BIOS loads first sector of each Bootable device at location 0x7C00
then it checks for 0xAA55 signature
if found, start executing code

2) EFI
BIOS looks into EFI partitions
OS must be compiled as EFI program

only using legacy mode in this project

Bios always keeps address at 7c00
Done using org directive- tells assembler where we expect our code to be loaded. It then uses this to calc label addresses

Directive- gives a clue to the assembler of how to compile the program. NOT translated to machine code
Instrn- Translated to machine code, cpu will execute

DB directive- writes given bytes to assembled binary file
Times instrn- repeat 

now main.asm done
for building project make a makefile

to run- (wsl text only)
qemu-system-i386 -fda build/main_floppy.img -display curses


SEGMENTS, OFFSETS-
early x86 could not address all memory in a single register, so it split address to segment and offset
segments were aligned in 16bit blocks (shift left by 4 bits)
segemnt- starting pt
offset- how far in the region


real address= segment*16 + offset
registers to specify segments-

1) CS- currently running code segments
2) DS- data segments
3) SS- stack segments
4) ES,FS,GS- data segments


REFERENCING A MEM LOCATION-
segment:[base + index * scale + displacement]
base=16 (bp/bx) /32/64
index= 16 bits (SI/DI) /32/64
scale= (32/64 only) 1,2,4 or 8
displacement= a signed constant value

example- reading the third elem of a array
array: dw 1,2,3
	mov bx, array	;copy offset to ax
	mov si,2*2	;array[2] words are 2 bytes wide
	mov ax, [bx+si]



WHY???- why do we need old 16bit for booting- this is so that new x86 can still support old software boot
after startup, system switches back to 32/64 bit mode


lodsb- Loads byte from DS:SI into al/ax/eax and then increment si by number of bytes loaded

The print os-
DS:SI → data location
SS:SP → stack location

1. push ax- Take AX and push it onto the stack using SS:SP
CPU looks at:
SS (stack segment)
SP (stack pointer)
It decreases SP by 2 (because AX is 16-bit = 2 bytes)
It stores AX at: memory[SS × 16 + SP]

2. pop ax- Take top value from stack (SS:SP) and put it back into AX
CPU reads value from: memory[SS × 16 + SP]
Stores it into AX
Increases SP by 2

3. loadsb- Go to memory at DS:SI, copy 1 byte into AL, then move SI forward
AL = [DS:SI]
SI = SI + 1


4. mov si, msg_hello- SI now points to the start of the string
msg_hello has an address (offset)
That address is copied into SI

5. mov ds, ax- Set DS (data segment base) to 0
DS:SI → 0 × 16 + SI → just SI

6. mov ss, ax and mov sp, 0x7C00- Stack starts at memory address 0x7C00 and grows downward
SS = 0
SP = 0x7C00

stack uses- SS:SP → 0 × 16 + 0x7C00 = 0x7C00


call puts- Save where to return (on stack), then jump to function
Decrease SP by 2
Store return address at: SS:SP
Jump to puts

8. ret- Go back to where the function was called from
Read return address from: SS:SP
Increase SP by 2
Jump back


9. mov ah, 0x0E- Set BIOS function code for printing
AH = 0x0E
AH is upper 8 bits of AX
