        segment Pila stack
          resb 256

        ; Segmento de código
        segment Codigo
..start:

        mov ah,1
        dec ah 
        dec ah
        mov ax, 0fffeh
        inc ax
        inc ax
        
        mov al, 9
        inc al
        aaa
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

