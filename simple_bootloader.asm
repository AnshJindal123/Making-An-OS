org 0x7C00      ;directive for where we expect code to be loaded
bits 16         ;tell the system how many bits to emit

main:           ;code begins here
    hlt         ;stops cpu execution

.halt:          ;in case cpu starts again, maybe due to interrupt
    jmp .halt

;The bios expects the last 2 bytes of the 1st sector are aa55
;We will put prog in a 1.44mb disk, 1 sector has 512 bytes

times 510-($-$$) ;$ used to obtain memory offset of line, $$ for beginning of current section
;$-$$ gives length of prog
dw 0AA55h
