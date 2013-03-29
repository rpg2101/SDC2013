        segment Pila stack
          resb 256

        ; Segmento de código
        segment Codigo
..start:

        mov ax, 4
        mov dx, 37856
        sub dx, 43392
        sbb ax, 3
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

