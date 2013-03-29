        segment Pila stack
          resb 256

        ; Segmento de código
        segment Codigo
..start:

        mov ax, 3
        mov dx, 43392
        add dx, 37856
        adc ax, 4
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

