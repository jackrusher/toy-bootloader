NASM=nasm
FLPNAME=toybootloader
DD=dd

toybootloader: boot.bin
	$(DD) if=/dev/zero of=$(FLPNAME).flp ibs=1k count=1440
	$(DD) if=boot.bin of=$(FLPNAME).flp conv=notrunc
boot.bin:
	$(NASM) -f bin -o boot.bin boot.asm	
clean:
	rm *.o
	rm *.flp
	

