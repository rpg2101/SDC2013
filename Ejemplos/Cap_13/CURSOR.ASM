        segment Pila stack
          resw 512
FinPila:

        segment Datos
Mensaje    db 'El cursor est  en la posici¢n'
 Columna   db '   ,'
 Linea     db '   ', 13, 10
           db 'Comienza en la l¡nea'
 CurInicio db '   '
           db ' y finaliza en la l¡nea'
 CurFin    db '   $'

        ; Segmento de código
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; DS y ES apuntan al
        ; segmento de datos
        mov ax, Datos
        mov ds, ax
        mov es, ax

        ; obtenemos información
        ; del cursor en la página 0
        mov ah, 3
        xor bh, bh
        int 10h
        
        ; convertimos la columna
        ; en cadena
        mov al, dl
        inc al
        mov di, Columna+2
        call EnteroCadena

        ; convertimos la línea
        ; en cadena
        mov al, dh
        inc al
        mov di, Linea+2
        call EnteroCadena
        
        ; convertimos la línea
        ; de inicio en cadena
        mov al, ch
        mov di, CurInicio+2
        call EnteroCadena

        ; convertimos la línea
        ; de fin en cadena
        mov al, cl
        mov di, CurFin+2
        call EnteroCadena

        ; y mostramos el mensaje
        mov dx, Mensaje
        mov ah, 9
        int 21h
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        
;-----------------------------
; Este procedimiento convierte
; el valor de AL en una cadena
; de tres caracteres
; 
; Entrada: AL = número a convertir
;          ES:DI = destino cadena
;-----------------------------
EnteroCadena:
        ; establecemos valor inicial
        mov byte [di], '0'
        
        xor ah, ah ; AH debe ser cero
        
        ; comprobamos si AL es cero
        or al, al
        ; de ser así, no hay más
        ; que hacer
        jz FinConversion

        push bx ; guardamos bx
        ; y establecemos el divisor
        mov bl, 10        
        
 Bucle0:
        ; vamos dividiendo por 10
        div bl 
        
        ; quedándonos con el resto
        ; que convertimos a ASCII
        add ah, '0'
        ; y guardamos
        mov [di], ah
        ; retrocediendo al dígito anterior
        dec di
        
        ; eliminamos el contenido
        ; de AH para quedarnos con
        ; el cociente de AL
        xor ah, ah
        
        ; si el cociente es mayor que 9
        cmp al, 9
        ; seguimos dividiendo
        ja Bucle0
        
        ; en caso contrario guardamos
        add al, '0'
        mov [di], al
        
        pop bx ; recuperamos BX
        
FinConversion:
        ret