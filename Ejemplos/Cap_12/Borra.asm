        segment Pila stack
          resw 512

        ; Segmento de c�digo
        segment Codigo
..start:
        ; p�gina 0
        xor bh, bh
        ; posici�n 0,0
        xor dx, dx
        
        ; posicionamos el cursor
        mov ah, 2
        int 10h
        
        ; establecemos atributo
        mov bl, 7
        ; car�cter
        mov al, ' '
        ; y n�mero de caracteres
        mov cx, 2000
        
        ; llenamos la pantalla
        mov ah, 9
        int 10h
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        