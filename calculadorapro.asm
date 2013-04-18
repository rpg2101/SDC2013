segment Datos
; Direcciones de varias etiquetas
; con distintas rutinas
Rutinas dw Proceso1, Proceso2, Proceso3, Proceso4

menu1l1 db '1-SUMA',0AH
menu1l2	db '2-RESTA' , 0AH
menu1l3	db '3-MULT', 0AH
menu1l4	db '4-DIV', 0AH
menu1l5	db '9-SALIR',0AH
PulsacionIncorrecta db 'Pulse la opcion elegida',0AH,'$'

; Datos de una de las rutinas
Mensaje1 db 'Primer proceso',0AH,'$'
Mensaje2 db 'Segundo proceso',0AH,'$'
Mensaje3 db 'Tercer proceso',0AH,'$'
Mensaje4 db 'Cuarto proceso',0AH,'$'
Mensaje9 db 'Arrivedercci e buona fortuna',0AH,'$'
nuevalinea db 0AH , '$'

; Mensaje de error si se pulsa un
; número distinto a 0, 1 o 2
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
        
MenuPpal:        
		mov dx , menu1l1
		call Imprimir	; imprimir
     
        xor ah, ah ; esperamos una tecla
        int 16h
        
        ; comprobamos que la tecla
        ; sea 0, 1 o 2
        cmp al, '9'
        jz Salir
        cmp al, '1'
        jb Incorrecto
        cmp al, '4'
        ja Incorrecto
        
        
        ; Convertir el carácter en
        ; un número
        xor ah, ah
        sub al, '1'
        
        ; lleva el valor a BX
        ; multiplicándolo por 2
        shl ax, 1
        mov bx, ax
        
        ; invocamos a la rutina
        call  [Rutinas+bx]
        
        ; y finalizamos
        mov dx , nuevalinea 
		call Imprimir
        
        jmp MenuPpal
        
Incorrecto: ; mostrar mensaje de error
        mov dx, PulsacionIncorrecta
        mov ah, 9
        int 21h
        
Salir: 
        ; salimos al sistema
        mov dx , Mensaje9
		call Imprimir
        mov ah, 4ch
        int 21h

Proceso1: ; Primera rutina
        ; mostramos el mensaje
        mov dx , Mensaje1
		call Imprimir
        
        ret ; y devolvemos el control

Proceso2: ; Segunda rutina
        ; Mostramos un carácter en pantalla
        mov ax, 0b800h
        mov es, ax
        mov bx, 12*160+80
        mov word [es:bx], 0370fh
        
        ret ; y devolvemos el control

Proceso3: ; Tercera rutina
		mov dx , Mensaje3
		call Imprimir
        ret ; simplemente devuelve el control

Proceso4: ; Cuarta rutina
        mov dx , Mensaje4
		call Imprimir
        ret ; simplemente devuelve el control
           
Imprimir:
		mov ah, 9 
        int 21h
		ret 
