
        segment Datos

        segment Pila stack
        resb 256
InicioPila:

        segment Codigo
..start:
        mov ax, Pila
        mov ss, ax
        mov sp, InicioPila

        mov cx, 10  ; número decimal
        mov cx, 10q ; número octal
        mov cx, 10b ; número binario
        mov cx, 10h ; número hexadecimal

        mov ah, 4ch
        int 21h

