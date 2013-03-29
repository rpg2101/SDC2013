; Esta macro imprime el carácter
; entregado como parámetro sin
; modificar registros
%macro ImprimeCaracter 1
     push ax ; guardamos AX
     push dx ; y DX
     
     ; puerto 0
     xor dx, dx
     ; tomamos el carácter
     mov al, %1
     ; servicio 0
     xor ah, ah
     int 17h ; imprimimos
     
     pop dx ; recuperar
     pop ax ; registros
%endmacro

        segment Pila stack
          resw 512
FinPila:

        segment Datos
; Título a imprimir al principio
Mensaje db 'CÓDIGOS ASCII', 0
; Esta variable contará las columnas
Columna db 0                        
         
        ; Segmento de código
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; DS apunta al segmento
        ; que contiene los datos
        mov ax, Datos
        mov ds, ax

        ; imprime el título
        call ImprimeTitulo
        
        ; imprimimos un margen
        call Espacios
        
        ; comenzamos en la
        ; columna 10
        mov byte [Columna], 10        
        
        ; comenzar con el 
        ; código 32 (espacio)
        mov al, 32

        ; número de caracteres
        ; a imprimir
        mov cx, 256-32
        
Bucle2:
        ; imprimirmos el carácter
        ; que corresponda
        ImprimeCaracter al
        
        ; imprimimos el espacio
        ImprimeCaracter ' '
        
        ; incrementar AL
        inc al
        
        ; incrementamos la columna
        inc byte [Columna]
        ; ¿la columna es la 35?
        cmp byte [Columna], 35
        
        ; de no ser así seguimos
        jne NoAvance
        
        ; avanzamos de línea
        ImprimeCaracter 10
        ImprimeCaracter 13
        
        ; imprimimos un margen
        call Espacios
        
        ; comenzamos de nuevo
        ; en la columna 10
        mov byte [Columna], 10        
        
NoAvance:        
        ; y volvemos al primer bucle
        loop Bucle2
        
Fin:
        ; terminamos la última línea
        ImprimeCaracter 10
        ImprimeCaracter 13
        
        ; y provocamos el avance de página
        ImprimeCaracter 12
        
        ; y salimos
        mov ah, 4ch
        int 21h
        
;-------------------------------------
; Esta rutina imprime un título
; al principio
;-------------------------------------
ImprimeTitulo:
        ; Imprimimos un margen
        call Espacios         
        
        ; SI apunta al mensaje
        mov si, Mensaje
        cld
        
        ; DX tiene el puerto
        xor dx, dx
BucleT0:
        lodsb ; leemos un carácter
        or al, al ; si llegamos al fin
        jz FinTitulo ; saltamos
        
        ; en cason contrario
        ; imprimimos el carácter
        xor ah, ah
        int 17h
        
        ; seguimos
        jmp BucleT0
                
FinTitulo:                       
        ; Saltamos a la línea siguiente
        ImprimeCaracter 10
        ImprimeCaracter 13

        ret ; volver
        
;--------------------------------------
; Esta rutina imprime un bloque de
; espacios que sirve como margen
;--------------------------------------
Espacios:
        push ax ; guardamos
        push cx ; registros
        
        ; imprimir 10 espacios
        mov al, ' '
        xor dx, dx
        mov cx, 10
        
BucleE0:
        xor ah, ah ; vamos imprimiendo
        int 17h   ; hasta CX=0
        loop BucleE0
        
        pop cx ; recuperar
        pop ax ; registros
        
        ret ; y volver