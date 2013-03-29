;*********************
; Segmento de pila
;*********************
Pila    segment stack 'stack'
        db 256 dup (?)  
  FinPila:              
Pila    ends
                                  
;*********************
; Segmento de datos
;*********************
Datos   segment 'data'
  ; Mensajes informativos
  MsgVector   db 'El vector '
    NumVector db '     $'
    
  MsgLibre db 'est  libre.', 13, 10, '$'
  MsgNoLibre db 'no est  libre.', 13, 10, '$'
       
Datos   ends

;*********************
; Segmento de código
;*********************
Codigo  segment 'code'
        assume CS:Codigo, DS:Datos, SS:Pila

Main:
        ; Configuramos los registros de pila
        mov ax, seg Pila
        mov ss, ax
        mov sp, FinPila

        ; y los del segmento de datos
        mov ax, seg Datos
        mov ds, ax                   
        mov es, ax
        
        ; vamos a explorar 128 vectores
        mov cx, 128
Bucle:
        ; calculamos en AX el número
        ; de vector para contar de
        ; 128 a 255, no al revés
        mov ax, 256
        sub ax, cx
        
        ; guardamos el número de vector
        push ax

        ; lo convertimos a cadena
        mov di, offset NumVector+3
        call EnteroCadena
        
        ; y mostramos la primera
        ; parte del mensaje
        mov dx, offset MsgVector
        mov ah, 9
        int 21h
        
        ; recuperamos el número de vector
        pop ax
        
        ; guardamos ES porque la próxima
        ; llamada al DOS lo modificará
        push es
        
        ; obtenemos la dirección del vector
        mov ah, 35h
        int 21h
        
        ; si BX no es cero
        or bx, bx
        ; es que está ocupado
        jnz Ocupado
        
        ; si ES no es cero
        mov bx, es
        or bx, bx
        ; es que está ocupado
        jnz Ocupado
         
        ; si llegamos aquí es que el
        ; vector está libre
        mov dx, offset MsgLibre
        jmp Notifica
        
Ocupado:
        mov dx, offset MsgNoLibre                
        
Notifica:
        ; notificamos el estado del vector
        mov ah, 9
        int 21h
        
        ; recuperamos el anterior
        ; valor de ES
        pop es
        
        ; y continuamos el bucle
        loop Bucle
        
        ; devolvemos el control al sistema
        mov     ah, 4Ch                
        int     21h

;-----------------------------
; Este procedimiento convierte
; el valor de AX en una cadena
; de hasta cinco caracteres
; 
; Entrada: AX = número a convertir
;          ES:DI = destino cadena
;-----------------------------
EnteroCadena:
        ; DX debe estar a cero
        push dx ; lo guardamos
        xor dx, dx
        
        ; establecemos valor inicial
        mov byte ptr [di], '0'
        
        ; comprobamos si AL es cero
        or ax, ax
        ; de ser así, no hay más
        ; que hacer
        jz FinConversion

        push bx ; guardamos bx
        ; y establecemos el divisor
        mov bx, 10        
        
 Bucle0:
        ; vamos dividiendo por 10
        div bx 
        
        ; quedándonos con el resto
        ; que convertimos a ASCII
        add dl, '0'
        ; y guardamos
        mov byte ptr [di], dl
        ; retrocediendo al dígito anterior
        dec di
        
        ; eliminamos el contenido
        ; de DX para quedarnos con
        ; el cociente de AX
        xor dx, dx
        
        ; si el cociente es mayor que 9
        cmp ax, 9
        ; seguimos dividiendo
        ja Bucle0
        
        ; en caso contrario guardamos
        add al, '0'
        mov byte ptr [di], al
        
        pop bx ; recuperamos BX
        
FinConversion:
        pop dx ; recuperamos DX
        ret


Codigo  ends

        end Main

