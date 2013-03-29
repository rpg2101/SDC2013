        segment Pila stack
          resw 512
FinPila:

        segment Datos
Mensaje    db 'Hay disponibles '
 Numero    db '   '
           db ' p ginas$'

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

        ; comenzamos con 
        ; la primera página
        xor al, al
        
        ; comprobar como máximo
        ; 100 páginas
        mov cx, 100
       
Bucle:
        ; establecemos la
        ; página indicada en AL
        mov ah, 5
        int 10h
        
        push ax ; guardamos AL
        
        ; recuperamos información
        ; del modo actual
        mov ah, 0fh
        int 10h
        
        pop ax ; recuperamos AL
        ; y vemos si coincide
        cmp al, bh
        
        ; de no ser así
        ; no hay más páginas
        jne NoHayMas
        
        ; en caso contrario
        ; incrementamos AL
        inc al
        ; y repetimos el proceso
        loop Bucle
        
NoHayMas:
        ; en este momento AL
        ; contiene el número
        ; de páginas
        
        ; lo convertimos a cadena
        mov di, Numero+2
        call EnteroCadena
        
        ; restablecemos la
        ; página 0
        xor al, al
        mov ah, 5
        int 10h

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