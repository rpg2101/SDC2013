        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Para guardar el punto de entrada
GestorXMS dd 0  

; Mensajes informativos        
MsgNoHay db 'No hay instalado un controlador XMS.$'

MsgMemoria db 'La cantidad total de memoria XMS es de '
  MemTotal db '      kilobytes.',13,10,10          
           db 'El bloque libre m s grande tiene '
  MemLibre db '      kilobytes.$'
  
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
        ; la memoria total y libre
        mov ah, 8
        ; llamamos al gestor
        call far [GestorXMS]      
        
        push dx ; guardamos memoria total
        
        ; ES debe apuntar al segmento de datos
        push ds
        pop es
        
        ; Convertimos la memoria libre
        mov di, MemLibre+4
        call EnteroCadena

        ; recuperamos la memoria total
        pop ax         
        ; y convertimos también
        mov di, MemTotal+4
        call EnteroCadena
        
        ; apuntamos al mensaje
        mov dx, MsgMemoria
        ; y terminamos
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

%include "Convert.inc"
