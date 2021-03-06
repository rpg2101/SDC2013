  ;
  ; INTGRAF1.ASM
  ;
  ; Este programa funciona de forma id�ntica a INTGRAF, con la
  ; diferencia de ser mucho m�s peque�o.
  ;

  .MODEL Tiny   ; Modelo de memoria peque�o

  .STACK 512    ; 512 bytes de pila

  .CODE

    Jmp Instalar    ; Saltar a la instalaci�n

    ; Este procedimiento ser� el que quede residente
    ; en memoria
GestorServicios Proc

    Or AH, AH   ; Si AH no es cero
    Jnz Salir   ; saltar a la etiqueta Salir

    Mov AH, 255 ; Si AH es cero facilitar la identificaci�n

  Salir:

    IRet ; Vuelta de la interrupci�n

GestorServicios EndP

    ; Este procedimiento se ejecutar� tan s�lo al cargar
    ; el programa en memoria, no quedando residente

Instalar Proc

    Mov DX, Seg Mensaje1 ; DS apuntando a los mensajes
    Mov DS, DX

    Mov CX, 80h ; Vamos a inspeccionar 128 vectores
    Mov AL, 80h ; a partir del vector 128

    Mov AH, 35h ; El servicio 35h de la INT 21h nos permite leer un vector

  Bucle :

    Int 21h ; Leer el vector indicado en AL

    Mov DX, ES  ; La direcci�n se devuelve en ES:BX

    Or BX, DX ; Si tanto ES, que est� en DX, como BX son cero
    Jz VectorLibre ; es que el vector est� libre

    Inc AL ; En caso contrario saltar al siguiente vector

    Loop Bucle ; y repetir el proceso

      ; Esta etiqueta es s�lo indicativa. Se llegar� a ella
      ; cuando habi�ndose recorrido todos los vectores no se
      ; haya encontrado uno libre.
  NoHayVectorLibre :

    Mov DX, Offset Mensaje1 ; DS:DX apuntando al Mensaje1
    Mov AH, 9h ; Servicio para imprimir
    Int 21h

    Jmp SalirInstalacion ; Salir sin finalizar la instalaci�n

      ; A esta etiqueta se llegar� cuando se haya encontrado
      ; un vector de interrupci�n libre.
  VectorLibre :

    Push AX ; Preservar el n�mero de vector que est� en AL

    Mov BL, AL  ; Pasar el n�mero de vector a BL
    Mov CL, 4
    Shr BL, CL      ; Quedarse con los cuatro bits altos o nibble m�s significativo

    Add BL, '0' ; Convertir en n�mero decimal

    Cmp BL, '9' + 1 ; Si se trata de un d�gito no superior a 9
    Jl Valido1 ; la conversi�n es v�lida

    Add BL, 7 ; En caso contrario convertir en una letra de la A a la F

  Valido1:
    Mov Byte Ptr [NumVector], BL ; Guardar el primer d�gito

    And AL, 0Fh ; Quedarse con los cuatro bits bajos o nibble menos significativo

    Add AL, '0' ; Y repetir el anterior proceso de conversi�n
    Cmp AL, '9' + 1
    Jl Valido2

    Add AL, 7

  Valido2:

    Mov Byte Ptr [NumVector+1], AL ; para conseguir el segundo d�gito

    Mov DX, Offset Mensaje2 ; Imprimir el mensaje indicando el
    Mov AH, 9h ; vector en que se ha instalado INTGRAF
    Int 21h

    Pop AX ; Recuperar el valor de AL

    Mov DX, Seg GestorServicios ; Obtener en DS:DX la direcci�n de GestorServicios
    Mov DS, DX
    Mov DX, Offset GestorServicios

    Mov AH, 25h ; y modificar el vector de interrupci�n
    Int 21h   ; para que apunte a �l

    Mov DX, Offset Instalar ; Direcci�n de este procedimiento, que no quedar� residente
    Mov CL, 4 ; Convertir los bytes
    Shr DX, CL ; en p�rrafos dividiendo por 16

    Inc DX ; Un p�rrafo m�s por seguridad

    Add DX, 16 ; A�adir los 16 p�rrafos (256 bytes) que ocupa el PSP

    Mov AL, 0 ; C�digo de retorno 0
    Mov AH, 31h ; Servicio salir y quedar residente

    Int 21h ; Salir quedando residente

  SalirInstalacion : ; Salir sin terminar la instalaci�n

    Mov AH, 4Ch
    Int 21h

Instalar EndP

    ; Mensajes

  Mensaje1    Db    "Imposible instalar INTGRAF, no hay vectores libres.$"
  Mensaje2    Db  "INTGRAF instalado en el vector "
  NumVector Db    "00h.$"

  End
