        segment Pila stack
          resw 512

        segment Datos
Disquetes db '    unidades de disquetes', 13, 10, '$'
PuertosSerie db '    puertos serie', 13, 10, '$'
PuertosImpresora db '    puertos de impresora', 13, 10, '$'

        ; Segmento de código
        segment Codigo
..start:
       
       ; DS y ES apuntan
       ; al segmento de datos
       mov ax, Datos
       mov es, ax
       mov ds, ax
       
       ; obtenemos configuración
       int 11h
       ; y la guardamos
       push ax
       
       ; nos quedamos con los
       ; bits 6 y 7
       and ax, 0C0h
       ; los desplazamos a AL
       shr ax, 6
       ; incrementamos
       inc al
       
       ; y convertimos en cadena
       mov di, Disquetes+2
       call EnteroCadena
       
       ; mostramos en la consola
       mov dx, Disquetes
       mov ah, 9 
       int 21h
       
       ; recuperamos la configuración
       pop ax
       ; y volvemos a guardarla
       push ax
       
       ; nos quedamos con
       ; los bits 9, 10 y 11
       and ax, 0E00h
       ; los desplazamos a AL
       shr ax, 9
       
       ; convertimos a cadena
       mov di, PuertosSerie+2
       call EnteroCadena
       
       ; mostramos en la consola
       mov dx, PuertosSerie
       mov ah, 9
       int 21h
       
       ; volvemos a recuperar 
       ; la configuración
       pop ax
       
       ; nos quedamos con 
       ; los bits 14 y 15
       and ax, 0C000h
       ; y los desplazamos a AL
       shr ax, 14
       
       ; convertimos a cadena
       mov di, PuertosImpresora+2
       call EnteroCadena
       
       ; mostramos en la consola
       mov dx, PuertosImpresora
       mov ah, 9
       int 21h
        
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