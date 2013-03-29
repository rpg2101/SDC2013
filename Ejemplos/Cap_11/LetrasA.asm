        segment Datos
; Mensaje informativo
Mensaje db '     letras "A"$'

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

        ; ES:DI apuntan al inicio
        ; de la memoria de pantalla
        mov ax, 0b800h
        mov es, ax
        xor di, di
        
        ; DX nos servirá para ir
        ; contando 
        xor dx, dx
        
        ; tendremos que recorrer
        ; 2000 posiciones de 2 bytes
        mov cx, 2000
        
        ; incrementando el
        ; valor de DI
        cld
            
        ; Buscamos letras 'A'
        ; en blanco sobre negro
        mov ax, 0741h
 Bucle:
        repne scasw ; buscamos
        
        ; si no hemos encontrado
        or cx, cx
        jz Fin ; terminamos
        
        ; incrementamos DX
        inc dx
        jmp Bucle ; y seguimos
        
 Fin:
        ; Preparamos DS y ES
        ; apuntando al segmento
        ; de datos
        mov ax, Datos
        mov es, ax
        mov ds, ax
        
        ; DI indica el punto
        ; donde se insertará
        ; el último dígito
        mov di, Mensaje+3

        ; debemos facilitar el número
        ; a convertir en AL, y lo tenemos
        ; en DX
        mov ax, dx
        
        ; convertimos
        call EnteroCadena
        
        ; mostramos el mensaje por pantalla
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