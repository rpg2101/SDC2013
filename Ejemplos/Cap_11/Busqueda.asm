        segment Datos
; Cadenas a comparar
Cadena1 db 'Comparación de cadenas',0

; dependiendo de que esté o no
; definido el símbolo IGUALES
%ifdef IGUALES
  Cadena2 db 'Comparación de cadenas',0
%else
  Cadena2 db 'Comparación de dos cadenas', 0
%endif

; Mensajes a mostrar
General db '    caracteres comparados.$'
SonIguales db 'Las cadenas son iguales. $'
NoSonIguales db 'Las cadenas no son iguales. $'

        segment Pila stack
          resw 512
FinPila:          

        ; Segmento de código
        segment Codigo
..start:

        ; Preparamos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; DS y Es apunta al segmento de datos
        mov ax, Datos
        mov ds, ax
        mov es, ax
        
        ; primera cadena
        mov di, Cadena1
        ; calculamos la longitud
        call Longitud
        
        ; la guardamos en DX
        mov dx, cx
        
        ; segunda cadena
        mov di, Cadena2
        ; calculamos la longitud
        call Longitud
        
        ; vemos si la longitud de
        ; la primera cadena es
        ; menor que la de la segunda
        cmp dx, cx
        
        ; de no ser así saltamos
        ; al proceso de comparación
        ja Compara
        
        ; en caso contrario 
        ; intercambiamos DX y CX
        ; para quedarnos en CX con
        ; la longitud más corta
        xchg cx, dx
        
Compara:
        push cx ; guardamos la longitud
        
        ; apuntamos las cadenas a comparar
        mov si, Cadena1
        mov di, Cadena2
        
        cld ; incrementar
        
        repe cmpsb ; comparamos
        
        ; ¿se ha comparado entera?
        or cx, cx 
        jz Iguales ; saltar
        
        ; en caso contrario apuntar
        ; DX al mensaje de desigualdad
        mov dx, NoSonIguales
        
        ; y saltar al final del proceso
        jmp MuestraMensaje

Iguales:
        ; las cadenas son iguales
        mov dx, SonIguales
        
MuestraMensaje:
        ; convertimos AL a cadena
        mov di,General+2
        pop ax ; recuperamos longitud
        call EnteroCadena
        
        mov ah, 9 ; mostramos el 
        int 21h ; mensaje
        
        ; y la indicación general
        mov dx, General
        mov ah, 9
        int 21h

Fin:
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        
;---------------------------
; Este procedimiento toma en
; ES:DI una cadena terminada
; con nulo, al estilo de C,
; y facilita la longitud en CX
;---------------------------
Longitud:
       push ax ; guardamos AX
       
       ; asumimos longitud
       ; máxima
       mov cx,0ffffh
       
       ; buscamos el fin de la
       ; cadena
       xor al, al
       
       cld
       
       ; buscar
       repne scasb
       
       ; calcular la longitud
       mov ax, 0ffffh
       sub ax, cx
       
       ; ponerla en CX
       mov cx, ax
       
       pop ax ; restauramos ax
       
       ret ; y volvemos
       
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