        segment Pila stack
        resb 256

        ; Segmento de código
        segment Codigo
start:

        mov al, 10h
        add al, 20h
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h
