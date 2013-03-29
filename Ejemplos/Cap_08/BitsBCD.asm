        segment Pila stack
          resb 64

        ; Segmento de código
        segment Codigo
..start:
        ; introducimos el número
        ; desempaquetado en AH y AL
        mov ah, 1
        mov al, 5
        
        ; desplazamos el contenido 
        ; de AH cuatro bits a la izqueirda
        shl ah, 4
        ; y lo unimos con AL
        or al, ah
        
        ; Hacemos una suma
        add al, 21h
        
        ; llevamos AL a AH
        mov ah, al
        ; para quedarnos con los
        ; cuatro bits superiores
        shr ah, 4
        ; que eliminamos de AL
        and al, 00001111b

Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h

