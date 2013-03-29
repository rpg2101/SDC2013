        segment Pila stack
          resb 256

        ; Segmento de código
        segment Codigo
..start:

        mov al, -30
        mov bl, 15
        imul bl
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

