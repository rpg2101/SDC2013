    ;             
    ; DivCero1.Asm
    ;
    ; Realiza una divisi¢n por cero control ndola
    ;

    .Model Small

    .Stack 512

    .Data

Mensaje Db 'Se ha terminado el proceso$'

    ; Para guardar el contenido del vector 0
AnteriorVector0 Dd  ?

    .Code

    ; Este ser  el nuevo gestor para 
    ; la interrupci¢n 0
NuevoGestor0    Proc
    Push BP ; Preservar BP
    Mov BP, SP ; Obtener la direcci¢n final
    Inc BP ; Apuntar al desplazamiento
    Inc BP ; de retorno para IRET
    Inc Word Ptr SS:[BP] ; Incrementarlo para
    Inc Word Ptr SS:[BP] ; saltar la operaci¢n Div
    Pop BP ; recuperar BP
    Iret ; Volver
NuevoGestor0    Endp

    .Startup
    
Entrada Proc

    Mov AX, 3500h  ; Obtenemos la actual 
    Int 21h ; direcci¢n en el vector 0

        ; Preservamos la direcci¢n
    Mov Word Ptr [AnteriorVector0], BX
    Mov Word Ptr [AnteriorVector0+2], ES

    Mov AX, DS
    Push AX ; Preservar DS

    Mov DX, Seg NuevoGestor0
    Mov DS, DX
    Mov DX, Offset NuevoGestor0
    
    Mov AX, 2500h ; Establecemos nuestro 
    Int 21h ; propio controlador

    Pop AX
    Mov DS, AX ; Recuperamos DS

    Xor DX, DX  ; DX = 0
    Div DL      ; Dividimos AX entre DL, que es 0

        ; Imprimir el mensaje
    Mov DX, Offset Mensaje
    Mov AH, 9
    Int 21h

        ; Restituimos el controlador original
    Mov DX, Word Ptr [AnteriorVector0]
    Mov DS, Word Ptr [AnteriorVector0+2]
    Mov AX, 2500h
    Int 21h

        ; y terminar
    Mov AH, 4Ch
    Int 21h

Entrada Endp

    End


