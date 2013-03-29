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

        ; desde la posición 10,2
        mov cx, 0109h
        ; hasta 33,10
        mov dx, 0920h
        xor al, al
        ; con fondo blanco
        mov bh, 70h
        mov ah, 6
        int 10h ; borramos
        
        ; nuevo recuadro desde
        ; 49,2 hasta 73,10
        mov cl, 30h
        mov dl, 48h
        mov bh, 60h
        int 10h
        
        ; nuevo recuadro desde
        ; 10,13 hasta 33,21
        mov cx, 0C09h
        mov dx, 1420h
        xor al, al
        mov bh, 50h
        mov ah, 6
        int 10h
        
        ; nuevo recuadro desde 
        ; 49,13 hasta 73,21
        mov cl, 30h
        mov dl, 48h
        mov bh, 40h
        int 10h
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
