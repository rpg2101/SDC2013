        segment Datos
; Direcciones de varias etiquetas
; con distintas rutinas
Rutinas dw Proceso1, Proceso2, Proceso3

; Datos de una de las rutinas
Mensaje db 'Primer proceso$'

; Mensaje de error si se pulsa un
; número distinto a 0, 1 o 2
PulsacionIncorrecta db 'Pulsa 0, 1 o 2$'

        segment Pila stack
          resb 64
FinPila:          

        ; Segmento de código
        segment Codigo
..start:

        ; Preparamos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; DS apunta al segmento de datos
        mov ax, Datos
        mov ds, ax
        
        xor ah, ah ; esperamos una tecla
        int 16h
        
        ; comprobamos que la tecla
        ; sea 0, 1 o 2
        cmp al, '0'
        jb Incorrecto
        cmp al, '2'
        ja Incorrecto
        
        ; Convertir el carácter en
        ; un número
        xor ah, ah
        sub al, '0'
        
        ; lleva el valor a BX
        ; multiplicándolo por 2
        shl ax, 1
        mov bx, ax
        
        ; invocamos a la rutina
        call  [Rutinas+bx]
        ; y finalizamos
        jmp Salir
        
Incorrecto: ; mostrar mensaje de error
        mov dx, PulsacionIncorrecta
        mov ah, 9
        int 21h
        
Salir: 
        ; salimos al sistema
        mov ah, 4ch
        int 21h

Proceso1: ; Primera rutina
        ; mostramos el mensaje
        mov dx, Mensaje
        mov ah, 9
        int 21h
        
        ret ; y devolvemos el control

Proceso2: ; Segunda rutina
        ; Mostramos un carácter en pantalla
        mov ax, 0b800h
        mov es, ax
        mov bx, 12*160+80
        mov word [es:bx], 0370fh
        
        ret ; y devolvemos el control

Proceso3: ; Tercera rutina
        
        ret ; simplemente devuelve el control
