    ;
    ; InvBreak.Asm
    ;
    ; Invierte el estado del indicador BREAK
    ; del DOS
    ;

    .MODEL SMALL

    .STACK 512

    .DATA

Mensaje     Db  'Indicador BREAK est  $'
Activado    Db  'activo.$'
Desactivado Db  'inactivo.$'

    .CODE
    .Startup

    Mov AX, @Data   ; Cargamos la dirección del
    Mov DS, AX ; segmento de datos

    Mov DX, Offset Mensaje
    Mov AH, 9  ; Imprimimos la primera parte
    Int 21h ; del mensaje

    Mov AX, 3300h  ; Obtener el estado actual
    Int 21h ; del indicador DOS

    Or DL, DL  ; Comprobar el estado
    Jz EstaDesactivado

EstaActivado:

    Xor DL, DL ; Desactivar
    Push DX
    Mov DX, Offset Desactivado
    Jmp Salir

EstaDesactivado:

    Mov DL, 1 ; Activar
    Push DX
    Mov DX, Offset Activado
                   
Salir:

    Mov AH, 9 ; Imprimimos la segunda parte
    Int 21h ; de la cadena

    Pop DX ; Recuperamos DL
    Mov AX, 3301h ; y establecemos el nuevo estado
    Int 21h

    Mov AH, 4Ch ; Salimos al DOS
    Int 21h

    End

