
        segment Datos

        segment Pila stack
        resb 256
InicioPila:

        segment Codigo
..start:
        mov ax, Pila
        mov ss, ax
        mov sp, InicioPila

        mov cx, 10  ; n�mero decimal
        mov cx, 10q ; n�mero octal
        mov cx, 10b ; n�mero binario
        mov cx, 10h ; n�mero hexadecimal

        mov ah, 4ch
        int 21h

