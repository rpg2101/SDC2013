    ;
    ; Codigos.ASM
    ;
    ; Intercepta la interrupci¢n de teclado con el
    ; fin de ir mostrando por pantalla los c¢digos
    ; generados por las pulsaciones.
    ;

    .Model Small
    .Stack 512
    .Data

    ; Para componer la cadena decimal correspondiente
    ; a cada c¢digo
CifraDecimal    Db      3 Dup(?) 
                Db      ", $"

    ; Secuencia para avanzar una l¡nea
NuevaLinea      Db  13, 10, "$"

    ; Para conservar la direcci¢n del anterior
    ; gestor de la interrupci¢n
AnteriorGestor Dd ?

    ; Indicador de salida del programa
Indicador  Db 0

    .Code
    .Startup

    Mov AX, 3509h  ; Obtener la direcci¢n actual
    Int 21h ; del vector de interrupci¢n 9

        ; y guardarla en AnteriorGestor
    Mov Word Ptr [AnteriorGestor], BX
    Mov Word Ptr [AnteriorGestor+2], ES

       ; Fijar el nuevo gestor para la interrupci¢n
    Mov DX, Seg NuevoGestor
    Mov DS, DX
    Mov DX, Offset NuevoGestor

    Mov AX, 2509h
    Int 21h

    Mov AX, @Data ; Volver a cargar la 
    Mov DS, AX ; direcci¢n del segmento de datos

 Bucle:

        ; El programa se quedar  en este
        ; bucle sin hacer nada hasta que Indicador
        ; deje de ser 0
    Mov Al, [Indicador]
    Or AL, AL
    Jz Bucle

        ; Devolver al vector su antigua direcci¢n
    Mov DX, Word Ptr [AnteriorGestor]
    Mov DS, Word Ptr [AnteriorGestor+2]
    Mov AX, 2509h
    Int 21h

    Mov AH, 4Ch ; Y salir al DOS
    Int 21h

    ; Este procedimiento se encarga  de
    ; convertir el dato facilitado en AL
    ; en una cadena, imprimi‚ndola en la
    ; posici½n actual en pantalla.

Imprime    Proc 

    Push DX ; Preservar los registros
    Push AX

    Xor AH, AH ; Eliminar el contenido de AH

    Mov DL, 100 ; Obtener las centenas
    Div DL

    Add AL, '0' ; Convertir en d¡gito
    Mov Byte Ptr [CifraDecimal], AL

    Mov AL, AH ; Tomar el resto en AL
    Xor AH, AH ; y borrar AH

    Mov DL, 10 
    Div DL  ; Dividir el contenido de AX entre 10

    Add AL, '0'  ; Convertir en car cter
    Add AH, '0' ; cada d¡gito

        ; Pasarlos a la cadena
    Mov Word Ptr [CifraDecimal+1], AX 

    Mov DX, Offset CifraDecimal
    Mov AH, 9 ; Imprimir la cadena
    Int 21h

    Pop AX ; Recuperar el valor de AX
    Push AX

    Cmp AL, 1 ; ¨Se ha pulsado ESC?
    Jne NoEscape
       ; En caso afirmativo activar el Indicador
       ; provocando el fin del programa
    Mov [Indicador], AL

 NoEscape:

    Cmp AL, 28 ; ¨Se ha pulsado INTRO?
    Jne NoIntro

        ; Si es as¡ saltar una l¡nea
    Mov DX, Offset NuevaLinea
    Mov AH, 9
    Int 21h

 NoIntro:

    Pop AX ; Recuperar los registros
    Pop DX

    Ret ; y volver

Imprime         Endp

    ; Este ser  el nuevo gestor de la interrupci¢n
    ; de teclado

NuevoGestor Proc

    Push AX ; Preservar los registros a modificar

    In AL, 60h ; Leer el c¢digo de teclado
    Push AX ; y salvarlo en la pila

    In AL, 61h ; Indicar que ya se ha le¡do
    Or AL, 80h ; el c¢digo
    Out 61h, AL
    And AL, 7Fh
    Out 61h, AL

    Mov AL, 20h ; Enviar EOI al controlador
    Out 20h, AL ; de interrupciones

    Pop AX ; Recuperar el c¢digo
    Call Imprime ; e imprimirlo

    Pop AX ; Recuperar el contenido original de AX
    Iret ; y terminar la interrupci¢n

NuevoGestor Endp

    End

