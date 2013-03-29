        segment Pila stack
          resb 64

        ; Segmento de c�digo
        segment Codigo
..start:
        ; DS apuntar� al segmento
        ; de pantalla
        mov ax, 0b800h
        mov ds, ax
        
        ; ponemos a 0 BX para
        ; acceder a la primera posici�n
        xor bx, bx
        
        ; ponemos a 0 AL, para
        ; mostrar el primer car�cter
        xor al, al
        
Bucle:
        ; mostramos el car�cter en pantalla
        mov [bx], al
        
        ; avanzamos al atributo
        inc bx
        ; y lo establecemos
        mov byte [bx], 70h
        
        ; avanzamos a la posici�n siguiente
        inc bx
        ; avanzamos al siguiente car�cter
        inc al
        
        ; si AL no es 0 saltamos
        jnz Bucle

Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h

