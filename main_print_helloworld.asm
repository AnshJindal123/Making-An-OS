org 0x7C00      ;directive for where we expect code to be loaded
bits 16         ;tell the system how many bits to emit

%define ENDL 0x0D, 0x0A 
;0x0D - carriage return (\r), 0x0A - line feed (\n)

start:
    jmp main

; Prints to screen
;Params:
; -ds:si points to string
;DS- data segment- used for data access
; SI- source data used in loadsb
puts:
    ;save regs we will modify
    push si
    push ax     ;accumulator- split into ah,al

.loop:
    lodsb   ;load next char in al
    or al, al   ;verify if next char is null?
    jz .done
    
    
    ;TO PRINT, interrupt sequence:
    mov ah, 0x0e
    mov bh,0
    int 0x10

    jmp .loop

.done:
    pop ax
    pop si
    ret


main:           ;code begins here

    ;setup data segments
    mov ax,0    ;can't write to ds directly
    mov ds,ax
    mov es,ax   ;ex- extra segment

    ;setup stack
    mov ss,ax   ;stack segment
    mov sp,0x7C00      ;sp- stack pointer- tos
    ;stack grows downwards from where we r loaded to memory
    ;We use stack so that it grows downwards from out os so it does'nt overwrite anything

    ;print mssg:
    mov si, msg_hello
    call puts

    hlt         ;stops cpu execution

.halt:          ;in case cpu starts again, maybe due to interrupt
    jmp .halt

;The bios expects the last 2 bytes of the 1st sector are aa55
;We will put prog in a 1.44mb disk, 1 sector has 512 bytes


msg_hello: db 'Hello World!!! This is my first os ever', ENDL, 0



times 510-($-$$) db 0 ;$ used to obtain memory offset of line, $$ for beginning of current section
;$-$$ gives length of prog
dw 0AA55h
