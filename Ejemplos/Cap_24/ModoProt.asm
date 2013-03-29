        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Mensajes informativos        
MsgProtegido db 'Estoy en modo protegido.$'

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

        ; Asumir que estamos en modo real
        mov dx, MsgProtegido
        
        ; Mostramos el mensaje
        mov ah, 9
        int 21h        

        ; Tomar el contenido de CR0
        mov eax, cr0
        ; cambiar el estado del bit 0
        or eax, 1
        ; y ponerlo de nuevo en CR0
        mov cr0, eax
        
        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h
        
        