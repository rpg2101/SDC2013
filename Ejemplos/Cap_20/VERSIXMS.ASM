        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Para guardar el punto de entrada
GestorXMS dd 0  

; Mensajes informativos        
MsgNoHay db 'No hay instalado un controlador XMS.$'

MsgVersion db 'La versi¢n XMS es la '
    Byte1 db 0, '.'
    Byte2 db 0
          db '.', 13, 10, 10, '$'

MsgHayHMA db 'Hay memoria HMA.$'

MsgNoHayHMA db 'No hay memoria HMA.$'
          
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

        ; comprobamos si existe
        mov ax, 4300h
        int 2Fh
        
        cmp al, 80h
        
        ; Si no hay controlador no
        ; podemos continuar
        jne NoHayXMS

        ; pedimos el punto de entrada
        ; al gestor XMS
        mov ax, 4310h  
        int 2fh
        
        ; y lo guardamos
        mov [GestorXMS], bx
        mov [GestorXMS+2], es
        
        ; Solicitamos información de
        ; versión XMS
        xor ah, ah
        ; llamamos al gestor
        call far [GestorXMS]      
        
        push dx ; guardamos indicador
        
        ; Convertimos a ASCII desde BCD
        add ah, '0'
        add al, '0'
        
        ; componemos el mensaje
        mov [Byte1], ah
        mov [Byte2], al
        
        ; y lo mostramos
        mov dx, MsgVersion
        mov ah, 9
        int 21h
        
        pop dx ; recuperamos indicador
        or dx, dx ; ¿es 0?
        jz NoHayHMA

        ; Hay memoria HMA        
        mov dx, MsgHayHMA
        jmp Salir

NoHayHMA:
        ; No hay memoria HMA
        mov dx, MsgNoHayHMA
        jmp Salir
                
NoHayXMS:        
        ; indicamos que no hay controlador
        mov dx, MsgNoHay
        
Salir:  
        ; mostramos el mensaje
        mov ah, 9
        int 21h
              
        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h

