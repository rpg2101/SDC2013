        segment Pila stack
          resb 256

        ; Segmento de código
        segment Codigo
..start:

        mov al, 8
        mov bl, 3
        mul bl
        
        aam        
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

