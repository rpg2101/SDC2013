        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Mensajes informativos        
MsgHay db 'Hay instalado un controlador XMS.$'
MsgNoHay db 'No hay instalado un controlador XMS.$'

;*********************************
; Segmento de código
;*********************************
        segment Codigo
..start:
Inicio:
        ; Preparar los registros de pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; y del segmento de datos
        mov ax, Datos
        mov ds, ax

        ; asumimos que hay XMS
        mov dx, MsgHay
        
        ; comprobamos si existe
        mov ax, 4300h
        int 2Fh
        
        cmp al, 80h
        
        ; en caso afirmativo saltar        
        je Salir
        
        ; en caso contrario tomar
        ; la dirección del otro mensaje
        mov dx, MsgNoHay
        
Salir:  
        ; mostramos el mensaje
        mov ah, 9
        int 21h
              
        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h

