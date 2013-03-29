        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Nombre del archivo donde
; se encuentran las pantallas
Nombre db 'Pantalla.dat',0        

; Mensaje de error
Error db 'El archivo PANTALLA.DAT no existe.$'

        segment Codigo
..start:
        mov ax, Datos
        mov ds, ax
        
        ; DS:DX apuntan al nombre
        ; del archivo
        mov dx, Nombre
        
        ; Lo abrimos para lectura
        mov ah, 3Dh
        xor al, al
        int 21h
        
        ; si hubo error saltar
        jc NoExiste
        
        ; si no hubo error guardamos
        ; el manejador en BX
        mov bx, ax
        
        ; DS apuntará al segmento
        ; de pantalla
        mov ax, 0B800h
        mov ds, ax
        
Bucle:
        ; a partir del byte 0
        xor dx, dx
        ; 4000 bytes
        mov cx, 4000
        ; los leemos
        mov ah, 3Fh
        int 21h
        
        ; ¿Es AX = 0?
        or ax, ax
        ; de ser así terminar
        jz FinBucle
        
        ; en caso contrario
        ; esperar una tecla
        xor ah, ah
        int 16h
        
        ; y continuar con la
        ; pantalla siguiente
        jmp Bucle
        
FinBucle:
        ; cerramos el archivo
        mov ah, 3Eh
        int 21h
        
        jmp Fin
        
NoExiste:
        ; si el archivo no existe
        ; imprimir el error
        mov dx, Error
        mov ah, 9
        int 21h
        
Fin:
        ; salir al DOS
        mov ah, 4Ch
        int 21h
        