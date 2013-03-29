        segment Pila stack
          resw 512

        segment Datos
CodASCII db '    ', 13, 10, '$'

        ; Segmento de código
        segment Codigo
..start:
       
       ; DS y ES apuntan
       ; al segmento de datos
       mov ax, Datos
       mov es, ax
       mov ds, ax
       
Bucle:
        ; esperamos la pulsación
        ; de una tecla
        xor ah, ah
        int 16h
        
        ; si es ESC
        cmp al, 27 
        ; terminar
        jz Fin
        
        ; en caso contrario
        mov di, CodASCII+2
        ; convertir a cadena
        call EnteroCadena
        
        ; y mostrarlo en pantalla
        mov dx, CodASCII
        mov ah, 9
        int 21h   
        
        ; eliminar el código
        ; para así poder 
        ; introducir otro
        mov di, CodASCII
        mov al, ' '
        mov cx, 3
        cld
        rep stosb     
        
        jmp Bucle ; repetir
        
Fin:        
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
        
        ; comprobamos si AL es cero
        or al, al
        ; de ser así, no hay más
        ; que hacer
        jz FinConversion

        push bx ; guardamos bx
        ; y establecemos el divisor
        mov bl, 10        

        ; AH debe estar a 0
        xor ah, ah        
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