        segment Pila stack
          resw 512
FinPila:

        segment Datos
Sectores db '    sectores', 13, 10, '$'
Caras db '    caras', 13, 10, '$'
Cilindros db '    cilindros', 13, 10, '$'
MsgError db 'Se produce un error$'

        ; Segmento de código
        segment Codigo
..start:
       ; Configuramos los registros
       ; de pila
       mov ax, Pila
       mov ss, ax
       mov sp, FinPila
       
       ; DS y ES apuntan
       ; al segmento de datos
       mov ax, Datos
       mov es, ax
       mov ds, ax
       
       ; obtener parámetros
       mov ah, 8h
       ; del disquete
       xor dl, dl
       int 13h
       
       ; si hay un error
       jc Error ; lo notificamos
       
       ; comenzamos con las caras
       ; que vienen en DH
       mov al, dh
       inc al ; incrementamos
       
       ; convertimos a cadena
       mov di, Caras+2
       call EnteroCadena
       
       ; y las mostramos
       mov dx, Caras
       mov ah, 9
       int 21h
       
       ; el número de sectores está
       ; en los bits 0 a 5 de CL
       mov al, cl
       and al, 3Fh
       
       ; convertimos a cadena
       mov di, Sectores+2
       call EnteroCadena
       
       ; y mostramos los sectores
       mov dx, Sectores
       mov ah, 9
       int 21h
       
       ; el número de mayor cilindro
       ; está en el registro CH
       mov al, ch
       inc al ; incrementamos
       
       ; lo convertimos
       mov di, Cilindros+2
       call EnteroCadena
       
       ; y mostramos
       mov dx, Cilindros
       mov ah, 9
       int 21h
        
Fin:        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        
Error: ; si se produce un error

        ; mostramos el mensaje
        mov dx, MsgError
        mov ah, 9
        int 21h
        
        jmp Fin ; y salimos
        
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