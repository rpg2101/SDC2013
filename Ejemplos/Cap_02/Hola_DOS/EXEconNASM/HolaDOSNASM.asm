
        segment Datos
Saludo  db '�Hola DOS!$'

        segment Pila stack
        resb 256
InicioPila:

        segment Codigo
..start:
        mov ax, Pila
        mov ss, ax
        mov sp, InicioPila

        mov ax, Datos
        mov ds, ax
        mov dx, Saludo
        
        ;Interrupci�n Imprime Saludo en Pantalla
        ;INT 21H Funci�n 09H
		;Visualizaci�n de una cadena de caracteres
		;LLAMADA:
		;AH = 09H
		;DS:DX = Segmento: Desplazamiento de la cadena a visualizar (in DX - offset address of string in data segment)
		;DS debe apuntar al segmento donde se encuentra la cadena.
		;DX debe contener el desplazamiento de la cadena dentro de ese segmento.
        mov ah, 9 
        int 21h
		
		;Interrupci�n  Finaliza la ejecucion 
		;INT 21H Funci�n 09H	
		;Visualizaci�n de una cadena de caracteres
		;LLAMADA:
		;AH = 09H
		;DS:DX = Segmento: Desplazamiento de la cadena a visualizar (in DX - offset address of string in data segment)
		;DS debe apuntar al segmento donde se encuentra la cadena.
		;DX debe contener el desplazamiento de la cadena dentro de ese segmento.
		mov ah, 4ch
        int 21h 
