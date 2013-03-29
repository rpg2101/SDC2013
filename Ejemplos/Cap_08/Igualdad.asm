        segment Pila stack
          resb 64
InicioPila:

        ; Segmento de código
        segment Codigo
..start:
        ; preparamos DS y BX
        ; para acceder al atributo
        ; de la fila 12 columna 40
        ; de la pantalla de texto
        mov ax, 0b800h
        mov ds, ax
        mov bx, 160*12+40*2+1
        
        ; comprobamos si el atributo
        ; es blanco sobre blanco
        cmp byte [bx], 07h
        ; de ser así saltamos
        jz FondoNegro
             
        ; en caso contrario establecemos
        ; el atributo por defecto
        mov byte [bx], 07h
        
        ; y saltamos al punto de salida
        jmp Salir
        
FondoNegro:
        ; invertimos los colores
        mov byte [bx], 70h
        
Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h

