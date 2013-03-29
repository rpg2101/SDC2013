        segment Pila stack
          resb 256

        ; Segmento de código
        segment Codigo
..start:

        mov ax, 0105h
        mov bl, 7
        
        aad   ; Ajuste BCD
        div bl
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

