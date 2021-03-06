  ;
  ; INT2F.ASM
  ;
  ; Este programa queda residente en memoria 
  ; siendo accesible mediante la interrupci�n
  ; m�ltiple. Su c�digo de identificaci�n
  ; ser� el 123.
  ;

  ; Modelo de memoria peque�o
  .MODEL Small             
  ; Pueden usarse instrucciones del 386
  .386

  .STACK 512    ; 512 bytes de pila

  .CODE ; Inicio del segmento de c�digo
  ; Generar c�digo de configuraci�n
  .STARTUP

      Jmp Instalar   ; Saltar a la instalaci�n

; Para preservar la direcci�n del controlador anterior
Antigua2F Dd  ?       

    ; Este procedimiento ser� el que quede residente
    ; en memoria
GestorServicios Proc

    Cmp AH, 123 ; Comprobar si es para nosotros
    Jne NoLoes

    Mov AX, 54321 ; Devolver otro c�digo
    ; Volver eliminando el registro de indicadores 
    ; de la pila
    Retf 2 

NoLoEs:
    ; Saltar al siguiente gestor de la lista
    Jmp [CS:Antigua2F]   

GestorServicios EndP

    ; Este procedimiento se ejecutar� tan s�lo al 
    ; cargar el programa en memoria, no quedando 
    ; residente

Instalar Proc

    Mov AH, 123     ; Comprobar si ya est� instalado
    Int 2Fh
    Cmp AX, 54321
    Je YaInstalado ; Si es as� no permitir la reinstalaci�n

    Mov AL, 2fh  ; Obtener la direcci�n del actual gestor
    Mov AH, 35h
    Int 21h

    ; Preservar la direcci�n original
    Mov Word Ptr [CS:Antigua2F], BX   
    Mov Word Ptr [CS:Antigua2F+2], ES

    ; Instalar en el vector 
    Mov DX, Seg GestorServicios     
    Mov DS, DX                      
    ; la direcci�n apuntando a nuestro gestor
    Mov DX, Offset GestorServicios
    Mov AH, 25h
    Int 21h

    ; Calcular el tama�o a dejar residente
    Mov DX, Offset Instalar 
    Mov CL, 4
    Shr DX, CL
    Inc DX
    Add DX, 16

    Mov AX, 3100h ; Salir y quedar residente

    Int 21h

  YaInstalado:

    ; Mostramos el mensaje        
    Push CS
    Pop DS
    Mov DX, Offset Msg
    Mov AH, 9
    Int 21h

    ; y devolvemos el control
    Mov AH, 4Ch
    Int 21h

Instalar EndP

Msg     Db      "El programa ya est� instalado$"


  End
