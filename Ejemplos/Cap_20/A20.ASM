        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Mensajes informativos        
MsgActiva db 'La l�nea A20 est� activa.$'
MsgNoActiva db 'La l�nea A20 no est� activa.$'

;*********************************
; Segmento de c�digo
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
        ; est� el PSP
        mov ah, 62h
        int 21h
        ; lo ponemos en ES
        mov es, bx
        ; DI apunta a la longitud
        ; de la l�nea de par�metros
        mov di, 80h
        
        ; Si el contador est� a 0
        cmp byte [es:di], 0
        ; no hay par�metros
        jz NoHayParametros
        
        ; En caso contrario leer el
        ; valor del puerto 92h
        in al, 92h
        
        ; Si el par�metro facilitado es 1
        cmp byte [es:di+2], '1'
        ; activamos la l�nea A20
        je Activar
        
        ; en caso contrario la desactivamos
        and al, 0FDh
        jmp CambiarEstado
        
Activar:
        ; activamos
        or al, 2
        
CambiarEstado:
        ; cambiamos el estado de la l�nea
        out 92h, al
        
NoHayParametros:        
        ; En cualquier caso 
        mov dx, MsgActiva

        ; obtenemos el estado de la l�nea
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
        
        