
        segment Pila stack
          resw 512
FinPila:

        segment Codigo
..start:

        mov ah, 4ch
        int 21h
        