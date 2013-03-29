  ;
  ; INTGRAF1.ASM
  ;
  ; Este programa funciona de forma idéntica a INTGRAF, con la
  ; diferencia de ser mucho más pequeño.
  ;

  .MODEL Tiny   ; Modelo de memoria pequeño

  .STACK 512    ; 512 bytes de pila

  .CODE

    Jmp Instalar    ; Saltar a la instalación

    ; Este procedimiento será el que quede residente
    ; en memoria
GestorServicios Proc

    Or AH, AH   ; Si AH no es cero
    Jnz Salir   ; saltar a la etiqueta Salir

    Mov AH, 255 ; Si AH es cero facilitar la identificación

  Salir:

    IRet ; Vuelta de la interrupción

GestorServicios EndP

    ; Este procedimiento se ejecutará tan sólo al cargar
    ; el programa en memoria, no quedando residente

Instalar Proc

    Mov DX, Seg Mensaje1 ; DS apuntando a los mensajes
    Mov DS, DX

    Mov CX, 80h ; Vamos a inspeccionar 128 vectores
    Mov AL, 80h ; a partir del vector 128

    Mov AH, 35h ; El servicio 35h de la INT 21h nos permite leer un vector

  Bucle :

    Int 21h ; Leer el vector indicado en AL

    Mov DX, ES  ; La dirección se devuelve en ES:BX

    Or BX, DX ; Si tanto ES, que está en DX, como BX son cero
    Jz VectorLibre ; es que el vector está libre

    Inc AL ; En caso contrario saltar al siguiente vector

    Loop Bucle ; y repetir el proceso

      ; Esta etiqueta es sólo indicativa. Se llegará a ella
      ; cuando habiéndose recorrido todos los vectores no se
      ; haya encontrado uno libre.
  NoHayVectorLibre :

    Mov DX, Offset Mensaje1 ; DS:DX apuntando al Mensaje1
    Mov AH, 9h ; Servicio para imprimir
    Int 21h

    Jmp SalirInstalacion ; Salir sin finalizar la instalación

      ; A esta etiqueta se llegará cuando se haya encontrado
      ; un vector de interrupción libre.
  VectorLibre :

    Push AX ; Preservar el número de vector que está en AL

    Mov BL, AL  ; Pasar el número de vector a BL
    Mov CL, 4
    Shr BL, CL      ; Quedarse con los cuatro bits altos o nibble más significativo

    Add BL, '0' ; Convertir en número decimal

    Cmp BL, '9' + 1 ; Si se trata de un dígito no superior a 9
    Jl Valido1 ; la conversión es válida

    Add BL, 7 ; En caso contrario convertir en una letra de la A a la F

  Valido1:
    Mov Byte Ptr [NumVector], BL ; Guardar el primer dígito

    And AL, 0Fh ; Quedarse con los cuatro bits bajos o nibble menos significativo

    Add AL, '0' ; Y repetir el anterior proceso de conversión
    Cmp AL, '9' + 1
    Jl Valido2

    Add AL, 7

  Valido2:

    Mov Byte Ptr [NumVector+1], AL ; para conseguir el segundo dígito

    Mov DX, Offset Mensaje2 ; Imprimir el mensaje indicando el
    Mov AH, 9h ; vector en que se ha instalado INTGRAF
    Int 21h

    Pop AX ; Recuperar el valor de AL

    Mov DX, Seg GestorServicios ; Obtener en DS:DX la dirección de GestorServicios
    Mov DS, DX
    Mov DX, Offset GestorServicios

    Mov AH, 25h ; y modificar el vector de interrupción
    Int 21h   ; para que apunte a él

    Mov DX, Offset Instalar ; Dirección de este procedimiento, que no quedará residente
    Mov CL, 4 ; Convertir los bytes
    Shr DX, CL ; en párrafos dividiendo por 16

    Inc DX ; Un párrafo más por seguridad

    Add DX, 16 ; Añadir los 16 párrafos (256 bytes) que ocupa el PSP

    Mov AL, 0 ; Código de retorno 0
    Mov AH, 31h ; Servicio salir y quedar residente

    Int 21h ; Salir quedando residente

  SalirInstalacion : ; Salir sin terminar la instalación

    Mov AH, 4Ch
    Int 21h

Instalar EndP

    ; Mensajes

  Mensaje1    Db    "Imposible instalar INTGRAF, no hay vectores libres.$"
  Mensaje2    Db  "INTGRAF instalado en el vector "
  NumVector Db    "00h.$"

  End
