        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Mensajes informativos        
MsgActiva db 'La l¡nea A20 est  activa.$'
MsgNoActiva db 'La l¡nea A20 no est  activa.$'

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
        
        ; Obtenemos el segmento donde
        ; está el PSP
        mov ah, 62h
        int 21h
        ; lo ponemos en ES
        mov es, bx
        ; DI apunta a la longitud
        ; de la línea de parámetros
        mov di, 80h
        
        ; Si el contador está a 0
        cmp byte [es:di], 0
        ; no hay parámetros
        jz NoHayParametros
        
        ; En caso contrario leer el
        ; valor del puerto 92h
        in al, 92h
        
        ; Si el parámetro facilitado es 1
        cmp byte [es:di+2], '1'
        ; activamos la línea A20
        je Activar
        
        ; en caso contrario la desactivamos
        and al, 0FDh
        jmp CambiarEstado
        
Activar:
        ; activamos
        or al, 2
        
CambiarEstado:
        ; cambiamos el estado de la línea
        out 92h, al
        
NoHayParametros:        
        ; En cualquier caso 
        mov dx, MsgActiva

        ; obtenemos el estado de la línea
        in al, 92h
        ; comprobamos su estado
        test al, 2
        ; y mostramos el mensaje que corresponda
        jnz Activa
        
        mov dx, MsgNoActiva
Activa:
        mov ah, 9
        int 21h        
        
Salir:        
        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h
        
        