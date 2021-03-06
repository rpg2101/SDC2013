  ;
  ; INT2F3.ASM
  ;
  ; Esta versi�n del programa permite 
  ; la desinstalaci�n
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

  ; Para preservar la direcci�n del controlador 
  ; anterior
  Antigua2F Dd  ?       
  ; Segmento del PSP del programa instalado
  SegmentoPSP Dw ?      

    ; Este procedimiento ser� el que quede 
    ; residente en memoria
GestorServicios Proc

    Cmp AH, 123 ; Comprobar si es para nosotros
    Jne NoLoes

    Cmp AL, 1 ; Orden de desinstalar
    ; Si no es, procede a la identificaci�n normal
    Jnz Identificacion 

    ; Obtener la direcci�n actual en el vector
    Mov AL, 2Fh   
    Mov AH, 35h   ; de la interrupci�n m�ltiple
    Int 21h

    ; Si no coincide con nuestra
    Cmp BX, Offset GestorServicios   
    Jne NoSePuede   ; propia direcci�n es porque 
    Mov BX, ES      ; se ha instalado otro programa 
    Cmp BX, Seg GestorServicios ; despu�s que este, 
    ; por lo que no es posible llevar a cabo la 
    ; desinstalaci�n
    Jne NoSePuede

    ; Obtener en DS:DX la antigua direcci�n
    Mov DX, Word Ptr CS:[Antigua2F]  
    Mov DS, Word Ptr CS:[Antigua2F+2]
    ; Y restituir el vector de interrupci�n
    Mov AL, 2Fh     
    Mov AH, 25h
    Int 21h

    ; Desactivar el flag de acarreo para indicar 
    ; que todo fue bien
    Clc  
    Retf 2 ; volver

  NoSePuede:

    Stc     ; Activar el indicador de acarreo
    Retf 2 ; para indicar que no es posible

  Identificacion:

    Mov AX, 54321 ; Devolver otro c�digo
    ; y el segmento del PSP
    Mov BX, CS:[SegmentoPSP] 

    ; Volver eliminando el registro de indicadores 
    ; de la pila
    Retf 2 

  NoLoEs:
    ; Saltar al siguiente gestor de la lista
    Jmp [CS:Antigua2F]   

GestorServicios EndP

    ; Este procedimiento se ejecutar� tan s�lo 
    ; al cargar el programa en memoria, no 
    ; quedando residente

Instalar Proc
    ; Preservar el segmento del PSP
    Mov CS:[SegmentoPSP], ES 

    Xor CH, CH
    ; CX contiene la longitud de la l�nea 
    ; de comandos
    Mov CL, ES:[80h]  

    ; Primer car�cter de la l�nea de comandos
    Mov DI, 81h 
    Mov AL, '/' ; Car�cter a buscar

    RepNe Scasb

    ; Si no se encontr� la barra no hay opciones
    Jnz NoHayOpciones 

    ; Mirar si hay una D detr�s de la barra
    Cmp Byte Ptr ES:[DI], 'D'       
    ; en caso contrario ignorar la l�nea de comandos
    Jne NoHayOpciones 

  ; Si se llega a esta etiqueta es porque 
  ; se quiere desinstalar
  Desinstalar:  

    Mov AH, 123
    Int 2Fh ; Comprobar si est� instalado

    Cmp AX, 54321
    Jne NoInstalado ; No est� instalado

    ; Preservar el segmento de PSP devuelto
    Push BX 

    ; Indicar a la parte residente que 
    ; restituya el vector
    Mov AH, 123        
    Mov AL, 1
    Int 2Fh

    ; Si no es posible, no continuar
    Jc NoSePuedeDesinstalar 

    Pop BX   ; Recuperar el segmento del PSP

    Mov DS, BX
    ; Obtener el segmento de entorno
    Mov ES, DS:[2Ch] 
    Mov AH, 49h   ; liberar la memoria que ocupa
    Int 21h
    Jc Fallo1 ; Indica si hay un fallo en liberaci�n

    ; Liberar el bloque principal del programa
    Mov ES, BX 
    Mov AH, 49h
    Int 21h
    Jc Fallo2

    ; Todo fue bien, el programa se ha desinstalado
    Mov DX, Offset Msg3 
    Jmp Imprimir

  Fallo1:
    ; Indicar con un mensaje el error encontrado
    Mov DX, Offset Msg5 
    Jmp Imprimir

  Fallo2:

    Mov DX, Offset Msg6
    Jmp Imprimir

  NoSePuedeDesinstalar:

    ; Descartar el valor que hab�amos 
    ; almacenado en la pila
    Pop DX 

    Mov DX, Offset Msg4 ; No se puede desinstalar
    Jmp Imprimir

  NoInstalado:

    ; El programa no est� instalado actualmente
    Mov DX, Offset Msg2     
    Jmp Imprimir ; terminar

   ;----------------------------
   ; A partir de aqu� tenemos el proceso normal
   ; en caso de que no se pasen par�metros.
   ;----------------------------

 NoHayOpciones: 

    ; Comprobar si ya est� instalado
    Mov AH, 123     
    Int 2Fh
    Cmp AX, 54321
    ; Si es as� no permitir la reinstalaci�n
    Je YaInstalado 

    ; Si no est� instalado vamos a proceder 
    ; a la instalaci�n

    ; Obtener la direcci�n del actual gestor
    Mov AL, 2fh     
    Mov AH, 35h
    Int 21h

    ; Preservar la direcci�n original
    Mov Word Ptr [CS:Antigua2F], BX   
    Mov Word Ptr [CS:Antigua2F+2], ES

    ; Instalar en el vector 
    Mov DX, Seg GestorServicios     
    ; la direcci�n apuntando a nuestro gestor
    Mov DS, DX                      
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
        
    Mov DX, Offset Msg

  Imprimir:

    Mov AX, Seg Msg ; Obtener la direcci�n 
    Mov DS, AX  ; del mensaje
    Mov AH, 9   ; mostrarlo
    Int 21h

    Mov AH, 4Ch ; y salir sin instalar
    Int 21h

Instalar EndP

    ; Mensajes de indicaci�n y error

Msg  Db "El programa ya est� instalado$"
Msg2 Db "El programa no est� instalado$"
Msg3 Db "El programa ha sido desinstalado$"
Msg4 Db "No es posible desinstalar el programa$"
Msg5 Db "Fallo en liberaci�n del bloque de entorno$"
Msg6 Db "Fallo en liberaci�n del bloque principal$"

  End
