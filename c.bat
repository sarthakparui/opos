cls
nasm -f obj system.asm
nasm -f obj hello.asm
nasm -f obj syscall.asm
tcc -mt -lt main.c hello.obj syscall.obj system.obj
copy main.com b:\LOADER.BIN /Y
del *.obj