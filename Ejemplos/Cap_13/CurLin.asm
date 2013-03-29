        segment Pila stack
          resw 512
FinPila:

        ; Segmento de código
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; Establecemos el
        ; tamaño del cursor
        mov ah, 1
        mov ch, 7
        mov cl, 7
        int 10h
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
