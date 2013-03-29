        segment Pila stack
          resw 512
FinPila:
        
        segment Datos

; Mensaje para indicar el número
; de unidades
Unidades db 13,10,10,'Hay'
Numero   db '     '
         db ' unidades disponibles.'
         db 13,10,10,'$'        

        segment Codigo
..start:
        ; DS y ES apuntan al 
        ; segmento de datos
        mov ax, Datos
        mov ds, ax
        mov es, ax
        
        ; obtenemos la unidad por
        ; defecto actual
        mov ah, 19h
        int 21h
        
        ; y la usamos para 
        ; establecerla 
        mov dl, al
        mov ah, 0Eh
        int 21h
        
        ; obteniendo el número de
        ; unidades disponibles
        xor ah, ah
        mov di, Numero+4
        ; lo convertimos
        call EnteroCadena
        
        ; y mostramos
        mov dx, Unidades
        mov ah, 9
        int 21h
        
        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h
        
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
        mov byte [di], '0'
        
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
        mov [di], dl
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
        mov [di], al
        
        pop bx ; recuperamos BX
        
FinConversion:
        pop dx ; recuperamos DX
        ret
        