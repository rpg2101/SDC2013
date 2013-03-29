        segment Datos
       
; Dato cuyo tercer bit vamos a comprobar 
Dato db 10100010b
; Mensajes para notificar el estado
MsgActivo db 'El bit se encuentra a 1', 13, 10, '$'
MsgNoActivo db 'El bit se encuentra a 0', 13, 10, '$'

        segment Pila stack
          resb 64
InicioPila:

        ; Segmento de código
        segment Codigo
..start:

       ; Preparamos DS para acceder
       ; al segmento de datos
       mov ax, Datos
       mov ds, ax
       
       ; recuperamos el dato en AL
       mov al, [Dato]
       
Comprueba:
       ; y ponemos todos sus bits a 0
       ; menos el tercero
       and al, 00000100b
       
       ; Si el resultado es 0 significa
       ; que el tercer bit estaba a 0
       jz EstaACero
       
       ; en caso contrario mostrar
       ; que estaba a 1
       mov dx, MsgActivo
       mov ah, 9 ; imprimir el mensaje
       int 21h

       jmp Salir ; terminar
       
 EstaACero: ; el bit está a 0
       mov dx, MsgNoActivo
       mov ah, 9 ; lo indicamos
       int 21h
       
       ; lo ponemos a 1
       or al, 00000100b
       ; y volvemos a comprobar
       jmp Comprueba        
Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h

