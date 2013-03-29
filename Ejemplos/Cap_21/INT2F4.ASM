  ;
  ; INT2F4.ASM
  ;
  ; Esta versi¢n del programa fijar su propia pila y PSP
  ;

  ; Modelo de memoria pequeño
  .MODEL Small             
  ; Pueden usarse instrucciones del 386
  .386

  .STACK 512    ; 512 bytes de pila

  .CODE ; Inicio del segmento de código
  ; Generar código de configuración
  .STARTUP

     Jmp Instalar   ; Saltar a la instalación

  ; Para preservar la dirección del controlador 
  ; anterior
  Antigua2F Dd  ?       
  ; Segmento del PSP del programa instalado
  SegmentoPSP Dw ?      

  ; Para almacenar la dirección de la pila del 
  ; otro programa
  PilaAnterior Dd ?     
  ; Dirección de nuestra pila
  PilaResidente Dd ?    

  ; Para almacenar el segmento de PSP anterior
  SegmentoPSPAnterior Dw ? 

    ; Este procedimiento ser  el que quede residente
    ; en memoria
GestorServicios Proc

    Cmp AH, 123 ; Comprobar si es para nosotros
    Jne NoLoes

    ;-------------------------------
    ; Intercambiar la pila y el PSP
    ;-------------------------------
    
    ; Desactivar interrupciones mientras 
    ; cambiamos la pila
    Cli     

    ; Preservar la dirección de
    Mov Word Ptr CS:[PilaAnterior], SP       
    ; la pila del otro programa
    Mov Word Ptr CS:[PilaAnterior+2], SS     

    ; Fijar nuestra propia pila
    Lss SP, CS:[PilaResidente] 

    Push AX ; Preservar AL

    Mov AH, 51h  ; Obtener segmento del PSP activo
    Int 21h
    Mov CS:[SegmentoPSPAnterior], BX ; Guardarlo

    Mov BX, CS:[SegmentoPSP] ; Fijar nuestro PSP
    Mov AH, 50h
    Int 21h

    Pop AX

    ;---------------------------

    Cmp AL, 1 ; Orden de desinstalar
    ; Si no es, procede a la identificación normal
    Jnz Salir 

    ; Obtener la dirección actual en el vector
    Mov AL, 2Fh   
    Mov AH, 35h   ; de la interrupci¢n múltiple
    Int 21h

    ; Si no coincide con nuestra
    Cmp BX, Offset GestorServicios   
    Jne NoSePuede   ; propia dirección es porque 
    Mov BX, ES      ; se ha instalado otro programa 
    Cmp BX, Seg GestorServicios ; después que este, 
    ; por lo que no es posible llevar a cabo la 
    ; desinstalación
    Jne NoSePuede

    ; Obtener en DS:DX la antigua direcci¢n
    Mov DX, Word Ptr CS:[Antigua2F]  
    Mov DS, Word Ptr CS:[Antigua2F+2]
    ; Y restituir el vector de interrupción
    Mov AL, 2Fh     
    Mov AH, 25h
    Int 21h

    ; Desactivar el flag de acarreo para indicar 
    ; que todo fue bien
    Clc  

    Jmp Salir ; volver

  NoSePuede:

    Stc     ; Activar el indicador de acarreo

  Salir:
    ; Restablecer el PSP
    Mov BX, CS:[SegmentoPSPAnterior] 
    Mov AH, 50h
    Int 21h

    Mov AX, 54321 ; Devolver otro código
    ; y el segmento del PSP
    Mov BX, CS:[SegmentoPSP] 

    ; Restablecer la pila anterior
    Lss SP, CS:[PilaAnterior] 
    Sti ; Activar las interrupciones

    ; Volver eliminando el registro de 
    ; indicadores de la pila
    Retf 2 

  NoLoEs:
    ; Saltar al siguiente gestor de la lista
    Jmp [CS:Antigua2F]   

GestorServicios EndP

  ; Reservamos 64 bytes para la pila
  EspacioDePila Db 64 Dup(?) 
  ; dentro de la parte que va a quedar residente
  EtiquetaPila: 

                ; Este procedimiento se ejecutar  tan s¢lo al cargar
    ; el programa en memoria, no quedando residente

Instalar Proc

        Mov CS:[SegmentoPSP], ES ; Preservar el segmento del PSP

        Xor CH, CH
        Mov CL, ES:[80h]        ; CX contiene la longitud de la l¡nea de comando

        Mov DI, 81h ; Primer car cter de la l¡nea de comando
        Mov AL, '/' ; Car cter a buscar

        RepNe Scasb

        Jnz NoHayOpciones ; Si no se encontr¢ la barra no hay opciones

        Cmp Byte Ptr ES:[DI], 'D'       ; Mirar si hay una D detr s de la barra
        Jne NoHayOpciones ; en caso contrario ignorar la l¡nea de comando

  Desinstalar:  ; Si se llega a esta etiqueta es porque se quiere desinstalar

        Mov AH, 123
        Int 2Fh ; Comprobar si est  instalado

        Cmp AX, 54321
        Jne NoInstalado ; No est  instalado

        Push BX ; Preservar el segmento de PSP devuelto

        Mov AH, 123        ; Indicar a la parte residente que restituya el vector
        Mov AL, 1
        Int 2Fh

        Jc NoSePuedeDesinstalar ; Si no es posible, no continuar

        Pop BX        ; Recuperar el segmento del PSP

        Mov DS, BX
        Mov ES, DS:[2Ch] ; Obtener el segmento de entorno
        Mov AH, 49h     ; liberar la memoria que ocupa
        Int 21h
        Jc Fallo1       ; Indica si hay un fallo en liberaci¢n

        Mov ES, BX ; Liberar el bloque principal del programa
        Mov AH, 49h
        Int 21h
        Jc Fallo2

        Mov DX, Offset Msg3 ; Todo fue bien, el programa se ha desinstalado
        Jmp Imprimir

  Fallo1:
        Mov DX, Offset Msg5 ; Indicar con un mensaje el error encontrado
        Jmp Imprimir

  Fallo2:

        Mov DX, Offset Msg6
        Jmp Imprimir

  NoSePuedeDesinstalar:

        Pop DX ; Descartar el valor que hab¡amos almacenado en la pila

        Mov DX, Offset Msg4 ; No se puede desinstalar
        Jmp Imprimir

  NoInstalado:

        Mov DX, Offset Msg2     ; El programa no est  instalado actualmente
        Jmp Imprimir ; terminar

   ;----------------------------
   ; A partir de aqu¡ tenemos el proceso normal
   ; en caso de que no se pasen par metros.
   ;----------------------------

  NoHayOpciones: 

        Mov AH, 123     ; Comprobar si ya est  instalado
        Int 2Fh
        Cmp AX, 54321
        Je YaInstalado ; Si es as¡ no permitir la reinstalaci¢n

                ; Si no est  instalado vamos a proceder a la instalaci¢n

        Mov Word Ptr CS:[PilaResidente], Offset EtiquetaPila ; Preparar la pila del residente
        Mov Word Ptr CS:[PilaResidente+2], Seg EtiquetaPila

        Mov AL, 2Fh     ; Obtener la direcci¢n del actual gestor
        Mov AH, 35h
        Int 21h

        Mov Word Ptr CS:[Antigua2F], BX   ; Preservar la direcci¢n original
        Mov Word Ptr CS:[Antigua2F+2], ES

        Mov DX, Seg GestorServicios     ; Instalar en el vector 
        Mov DS, DX                      ; la direcci¢n apuntando a nuestro gestor
        Mov DX, Offset GestorServicios
        Mov AH, 25h
        Int 21h

        Mov DX, Offset Instalar ; Calcular el tama¤o a dejar residente
        Mov CL, 4
        Shr DX, CL
        Inc DX
        Add DX, 16

        Mov AX, 3100h ; Salir y quedar residente

        Int 21h

  YaInstalado:
        
        Mov DX, Offset Msg

  Imprimir:

        Mov AX, Seg Msg         ; Obtener la direcci¢n del mensaje
        Mov DS, AX
        Mov AH, 9               ; mostrarlo
        Int 21h

        Mov AH, 4Ch ; y salir sin instalar
        Int 21h

Instalar EndP

        ; Mensajes de indicaci¢n y error

Msg     Db      "El programa ya est  instalado$"
Msg2    Db      "El programa no est  instalado$"
Msg3    Db      "El programa ha sido desinstalado$"
Msg4    Db      "No es posible desinstalar el programa$"
Msg5    Db      "Fallo en liberaci¢n del bloque de entorno$"
Msg6    Db      "Fallo en liberaci¢n del bloque principal$"

  End


