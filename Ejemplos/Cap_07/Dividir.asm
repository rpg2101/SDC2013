        segment Pila stack
          resb 256

        ; Segmento de c�digo
        segment Codigo
..start:

        mov ax, 31
        mov bl, 5
        div bl
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

