    ;             
    ; DivCero.Asm
    ;
    ; Realiza una divisi¢n por cero causando
    ; la interrupci¢n del programa.
    ;

    .Model Small

    .Stack 512

    .Data

Mensaje Db 'Se ha terminado el proceso$'

    .Code
    .Startup

    Xor DX, DX  ; DX = 0
    Div DL      ; Dividimos AX entre DL, que es 0

    ; Imprimir el mensaje
    Mov DX, Offset Mensaje
    Mov AH, 9
    Int 21h

    ; y terminar
    Mov AH, 4Ch
    Int 21h

    End
