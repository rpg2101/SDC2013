; Consigna : Escribir un programa que cuente cuantos caracteres "x" hay en la region de memoria en modo texto
; ASCII A = 65 ..... Z = 90
; a = 97 ........... z = 122

        ; Definimos el segmento de datos
        segment Datos
Saludo  db '­Se encontraron :$'

; definiendo varios campos

         segment Pila stack
          resb 64
InicioPila:

        ; Segmento de código
        segment Codigo
..start:
        ; preparamos DS y BX
        ; para acceder al carácter
        ; de la fila 12 columna 2
        ; de la pantalla de texto
        mov ax, 0b800h
        mov ds, ax
        mov bx, 160*25
		mov cx , 0
        ; Recuperamos el carácter en AL
        mov al, [bx]
Compara:
        cmp al, 'A' ; Comparamos con la A
        je Cuenta    ; si es inferior saltamos
        dec bx
        cmp bl , 00h
        je Salir
        jmp Compara     
        ;cmp al, 'Z' ; Comparamos con la Z
        ;ja Salir    ; si es superior saltamos
        
        ; Convertimos a minúscula
        ;add al, 32 ' sumando 32
        ;mov [bx], al ' y escribiendo en pantalla
 
Cuenta:
		inc cx
		jmp Compara
        
Salir:
        mov dx, Saludo
        mov ah, 9 
        int 21h
        
        ;mov dx, cx
        ;mov ah, 9 
        ;int 21h
        
        
        ; en cualquier caso modificamos el atributo
        ; inc bx
        ; para resaltar el carácter tanto si se ha
        ; cambiado como si no
        ;mov byte [bx], 0fh
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h
