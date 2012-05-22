;
; TOY BOOTLOADER
; (for pedagogical purposes only)
;
; To have a play, use nasm to assemble the code to a binary:
;
; $ nasm -f bin -o boot.bin boot.nasm
;
; ... then use dd to make an empty floppy disk image:
;
; $ dd if=/dev/zero of=boot.flp ibs=1k count=1440
;
; ... fill the header of the disk image with the boot binary:
;
; $ dd if=boot.bin of=boot.flp conv=notrunc
;
; ... and boot qemu off the floppy image:
;
; $ qemu-system-i386 boot.flp
;
; Both 'nasm' and 'qemu' can be installed with 'brew' under OS X, and
; 'dd' is included by default.
;
	BITS 16			; 16-bit real mode, not protected mode:
                                ; http://wiki.osdev.org/Real_Mode
                                ; http://wiki.osdev.org/Protected_Mode

; entry point for bootloader
start:
        mov ax, 0x07C0          ; this offset is where our code is loaded
        mov ds, ax              ; these segment registers need to know it
        mov es, ax              ; to handle address lookups correctly

	call clear		; our routine to clear the screen

	mov si, welcome		; si (array index) register => string's address
	call puts		; call our puts function

	jmp $			; Jump to current location, an infinite loop

	welcome db 'Welcome to Example OS...',13,10,0

; clear the screen via an interrupt
clear:
	mov     al, 02h		; al = 02h, code for video mode (80x25)
        mov     ah, 00h		; code for the change video mode function
        int     10h		; trigger interrupt to call function
	ret

; print a line of text to the screen via an interrupt
puts:
	mov ah, 0Eh		; set interrupt function => print to screen
.repeat:
	lodsb			; loads the next character into al
	cmp al, 0		; compare al to 0 (nul terminator check)
	je .done		; "jump equal" to .done label
	int 10h			; triggers an interrupt to push out the byte
	jmp .repeat		; jump back to the repeat, this is how we loop
.done:
	ret

	times 510-($-$$) db 0	; Zero fill the rest of the boot sector
	dw 0xAA55		; BIOS boot signature magic number
