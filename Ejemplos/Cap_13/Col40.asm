        segment Pila stack
          resw 512
FinPila:

        ; Segmento de código
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        mov bx, 109h
        mov ax, 4F02h
        int 10h
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
