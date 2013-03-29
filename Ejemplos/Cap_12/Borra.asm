        segment Pila stack
          resw 512

        ; Segmento de código
        segment Codigo
..start:
        ; página 0
        xor bh, bh
        ; posición 0,0
        xor dx, dx
        
        ; posicionamos el cursor
        mov ah, 2
        int 10h
        
        ; establecemos atributo
        mov bl, 7
        ; carácter
        mov al, ' '
        ; y número de caracteres
        mov cx, 2000
        
        ; llenamos la pantalla
        mov ah, 9
        int 10h
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        