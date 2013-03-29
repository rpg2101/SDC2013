.386 
.model flat,stdcall 

include \masm32\include\windows.inc 
include \masm32\include\kernel32.inc 
include \masm32\include\user32.inc 

includelib \masm32\lib\kernel32.lib 
includelib \masm32\lib\user32.lib 

	.data 

Titulo  db "Programación en ensamblador",0 
Texto   db "¡Hola Windows!",0 

	.code 
Main: 

invoke 	MessageBox, 0, offset Texto, offset Titulo, MB_OK 
invoke 	ExitProcess, 0

	end Main 

