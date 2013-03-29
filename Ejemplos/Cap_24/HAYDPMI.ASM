        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Mensajes informativos        
MsgNoDPMI db 'No hay servicios DPMI.$'
MsgProcesador db 'El tipo de procesador es '
  Procesador db '   ',13,10,10,'$'
MsgSi32Bits db 'Puede ejecutar programas de 32 bits.',13,10,10,'$'
MsgNo32Bits db 'No puede ejecutar programas de 32 bits.',13,10,10,'$'
MsgVersion db 'La versi¢n de DPMI es la '
   Vers1 db '0.'
   Vers2 db '00',13,10,10,'$'
MsgParrafos db 'Se necesitan '
   Parrafos db '     '
            db ' p rrafos de memoria para el acceso.',13,10,10,'$'

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
        mov es, ax

        ; Comprobamos si hay un anfitrión
        ; DPMI instalado en el sistema
        mov ax,1687h
        int 2fh
        
        ; en caso de no ser así
        or ax, ax
        ; salir directamente
        jnz Error
        
        ; Tomar el número de versión
        add dh, '0'
        mov [Vers1], dh
        ; y convertir en ASCII
        mov al, dl
        mov dl, 10
        div dl
        add ah, '0'
        add al, '0'
        ; para componer el mensaje
        mov [Vers2], al
        mov [Vers2+1], ah 
        ; y mostrarlo en pantalla
        mov dx, MsgVersion
        mov ah, 9
        int 21h
        
        ; Convertimos el código de procesador
        ; para mostrarlo
        mov al, cl
        xor ah, ah
        mov di, Procesador+2
        call EnteroCadena
        
        mov dx,MsgProcesador
        mov ah, 9
        int 21h
        
        ; Convertimos también el número de
        ; párrafos de memoria que necesita
        mov ax, si
        mov di, Parrafos+4
        call EnteroCadena
        mov dx, MsgParrafos
        mov ah, 9
        int 21h
        
        ; Y por último comprobamos si contempla o
        ; no la ejecución de aplicaciones de
        ; 32 bits
        mov dx, MsgSi32Bits
        
        test bx, 1
        jnz Salir
        
        mov dx, MsgNo32Bits
        jmp Salir
        
Error:
        ; No hay un anfitrión DPMI instalado
        mov dx, MsgNoDPMI

Salir:        
        ; MOstrar el último mensaje
        mov ah, 9
        int 21h

        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h
        
        ; Necesitamos la rutina de conversión
%include "Convert.inc"        