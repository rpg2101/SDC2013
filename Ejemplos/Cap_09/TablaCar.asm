        segment Pila stack
          resb 64

        ; Segmento de código
        segment Codigo
..start:
        ; DS apuntará al segmento
        ; de pantalla
        mov ax, 0b800h
        mov ds, ax
        
        ; ponemos a 0 BX para
        ; acceder a la primera posición
        xor bx, bx
        
        ; ponemos a 0 AL, para
        ; mostrar el primer carácter
        xor al, al
        
Bucle:
        ; mostramos el carácter en pantalla
        mov [bx], al
        
        ; avanzamos al atributo
        inc bx
        ; y lo establecemos
        mov byte [bx], 70h
        
        ; avanzamos a la posición siguiente
        inc bx
        ; avanzamos al siguiente carácter
        inc al
        
        ; si AL no es 0 saltamos
        jnz Bucle

Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h

