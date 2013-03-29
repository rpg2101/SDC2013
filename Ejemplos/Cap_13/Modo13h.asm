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

        ; Modo 320x200 con
        ; 256 colores
        xor ah, ah
        mov al, 13h
        int 10h
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
