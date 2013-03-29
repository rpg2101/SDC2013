;*********************
; Segmento de pila
;*********************
Pila segment stack 'stack'
        db 256 dup (?)  
FinPila:        
Pila ends
                                  
;*********************
; Segmento de datos
;*********************
Datos segment 'data'

    ; Mensajes
MsgExiste Db 'El controlador est  instalado.$'
MsgNoExiste Db 'El controlador no est  instalado.$'
       
Datos ends

;*********************
; Segmento de código
;*********************
Codigo segment 'code'
       assume CS:Codigo, DS:Datos, SS:Pila
Main:
    ; Configuramos los registros de pila
    mov ax, seg Pila
    mov ss, ax
    mov sp, FinPila

    ; y los del segmento de datos
    mov ax, seg Datos
    mov ds, ax                   

    ; Comprobamos si existe el
    ; servicio 123
    Mov AH, 123
    Xor AL, AL
    int 2Fh
    
    ; si no existe
    Or AL, AL
    ; saltar
    Jz NoExiste

    ; mensaje de que sí existe    
    Mov DX, Offset MsgExiste
    jmp Salir
    
NoExiste:
    Mov DX, Offset MsgNoExiste
        
Salir:    
    ; Mostrar el mensaje
    Mov AH, 9
    Int 21h
    
    ; y salir al sistema
    Mov AH, 4Ch
    Int 21h
    
Codigo  ends

        end Main
