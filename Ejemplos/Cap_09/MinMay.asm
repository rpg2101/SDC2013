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
        
        ; ponemos en el registro CX
        ; el n�mero de caracteres
        ; que debemos inspeccionar
        mov cx, 80*25
        
Bucle:
        ; recuperamos un car�cter
        mov al, [bx]
        
        ; comprobamos que sea una
        ; letra min�scula
        cmp al, 'a'
        jb NoCambiar
        cmp al, 'z'
        ja NoCambiar
        
        ; es una letra min�scula
        ; y la convertimos a may�scula
        sub al, 32
        ; devolvi�ndola a la pantalla
        mov [bx], al
        
NoCambiar:
        ; incrementamos BX para avanzar
        ; al siguiente car�cter
        inc bx
        inc bx
        
        ; tenemos un car�cter menos a 
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

