tcc -c -mt -IE:\OPOS\include system.c
nasm -f obj system.asm 
nasm -f obj start.asm
nasm -f obj hello.asm