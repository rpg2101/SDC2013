        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Mensajes informativos        
MsgReal db 'Est  en modo real.$'
MsgProtegido db 'Est  en modo protegido.$'

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
        mov dx, MsgReal
        
        ; Tomar el contenido de CR0
        mov eax, cr0
        ; y comprobar el estado del bit 0
        test al, 1
        ; Si está a 0 estamos en modo real
        jz Salir
        
        ; En caso contrario en modo protegido
        mov dx, MsgProtegido

Salir:        
        ; Mostramos el mensaje
        mov ah, 9
        int 21h        
        
        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h
        
        