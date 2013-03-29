        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Nombre del archivo donde
; va a guardarse la pantalla        
Nombre db 'Pantalla.dat',0        

; Para guardar el manejador
Manejador dw 0

        segment Codigo
..start:
        mov ax, Datos
        mov ds, ax
        
        ; DS:DX apuntan al nombre
        ; del archivo
        mov dx, Nombre
        
        ; Lo abrimos para lectura
        ; y escritura
        mov ah, 3Dh
        mov al, 2
        int 21h
        
        ; si no hubo error saltar
        jnc Abierto
        
        ; si hubo error creamos
        ; el archivo
        mov dx, Nombre
        mov ah, 3Ch
        xor cx, cx ; atributos normales
        
        int 21h
        
Abierto:
        ; Guardamos el manejador
        ; de acceso al archivo        
        mov bx, ax
        
        ; movemos el puntero
        ; de lectura al final
        ; del archivo
        mov al, 2
        xor cx, cx
        xor dx, dx
        mov ah, 42h
        int 21h
        
        ; DS:DX apuntan a la pantalla
        mov ax, 0B800h
        mov ds, ax
        xor dx, dx
        
        ; guardar 4000 bytes
        mov cx, 4000
        
        ; los escribimos
        mov ah, 40h
        int 21h
        
        ; cerramos el archivo
        mov ah, 3Eh
        int 21h
        
        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h
        