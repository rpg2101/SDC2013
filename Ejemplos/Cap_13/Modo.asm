        segment Pila stack
          resw 512
FinPila:

        segment Datos
MsgModo db 'El modo actual es'
 Modo   db '   ', 13, 10
        db 'La página actual es la'
 Pagina db '    $'       
        
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
        ; del modo actual
        mov ah, 0fh
        int 10h
        
        ; convertimos el modo
        ; en cadena
        mov di, Modo+2
        call EnteroCadena

        ; convertimos la página
        ; en cadena
        mov al, bh
        mov di, Pagina+2
        call EnteroCadena
        
        ; y mostramos el mensaje
        mov dx, MsgModo
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