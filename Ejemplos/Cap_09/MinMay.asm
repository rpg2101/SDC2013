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
        
        ; ponemos en el registro CX
        ; el número de caracteres
        ; que debemos inspeccionar
        mov cx, 80*25
        
Bucle:
        ; recuperamos un carácter
        mov al, [bx]
        
        ; comprobamos que sea una
        ; letra minúscula
        cmp al, 'a'
        jb NoCambiar
        cmp al, 'z'
        ja NoCambiar
        
        ; es una letra minúscula
        ; y la convertimos a mayúscula
        sub al, 32
        ; devolviéndola a la pantalla
        mov [bx], al
        
NoCambiar:
        ; incrementamos BX para avanzar
        ; al siguiente carácter
        inc bx
        inc bx
        
        ; tenemos un carácter menos a 
        ; inspeccionar, por lo que 
        ; reducimos el valor de CX
        ;dec cx
                
        ; si CX no es 0 saltamos
        ;jnz Bucle
        
        loop Bucle

Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h

