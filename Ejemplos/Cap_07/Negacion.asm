        segment Pila stack
          resb 256

        ; Segmento de c�digo
        segment Codigo
..start:

        mov ax, 5
        neg ax
        
        neg ax
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

