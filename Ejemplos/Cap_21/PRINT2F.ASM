        .MODEL Small
        .386

        .STACK 512

        .DATA

Msg1    Db "No est  instalado$"
Msg2    Db "Si est  instalado$"

        .CODE
        .STARTUP

        Mov AH, 123  ; C¢digo de nuestro gestor
        Int 2fh ; comprobar si est  instalado

        Cmp AX, 54321 ; ¨Ha devuelto el c¢digo?
        Jne NoInstalado ; si no, es que no est  instalado

  Instalado:

        Mov DX, Offset Msg2 ; Mostrar el mensaje que corresponda
        Jmp Salir 

  NoInstalado:

        Mov DX, Offset Msg1

  Salir:

        Mov AH, 9 ; Sacar el mensaje por pantalla
        Int 21h

        Mov AH, 4Ch ; y salir
        Int 21h

        End
