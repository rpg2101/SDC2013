  ;
  ; INDICADO.ASM
  ;
  ; Muestra el estado de los indicadores 
  ; InDos y ErrorMode
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
  ; Para preservar la dirección
  ; del controlador anterior
  Antigua1C Dd  ?       
						
  ; Segmento del PSP del programa instalado
  SegmentoPSP Dw ?      

  ; Para almacenar la dirección de la pila del 
  ; otro programa
  PilaAnterior Dd ?     
  ; Dirección de nuestra pila
  PilaResidente Dd ?    

  ; Para almacenar el segmento de PSP anterior
  SegmentoPSPAnterior Dw ? 

  InDos Dd ?   ; Dirección del indicador InDos

  ; Este procedimiento ser  el que quede residente
  ; en memoria
GestorServicios Proc

  Cmp AH, 123 ; Comprobar si es para nosotros
  Jne NoLoes

    ;-------------------------------
    ; Intercambiar la pila y el PSP
    ;-------------------------------
  Cli ; Desactivar interrupciones mientras
      ; cambiamos la pila

    ; Preservar la direcci¢n de la pila
    ; del otro programa
  Mov Word Ptr CS:[PilaAnterior], SP
  Mov Word Ptr CS:[PilaAnterior+2], SS

    ; Fijar nuestra propia pila
  Lss SP, CS:[PilaResidente]

  Push AX ; Preservar AL

  Mov AH, 51h   ; Obtener segmento del PSP activo
  Int 21h
  Mov CS:[SegmentoPSPAnterior], BX ; Guardarlo

  Mov BX, CS:[SegmentoPSP] ; Fijar nuestro PSP
  Mov AH, 50h
  Int 21h

  Pop AX ; Recuperar AL

  Cmp AL, 1 ; Orden de desinstalar
  Jnz Salir ; Si no, procede de forma normal

    ; Obtener la dirección actual en el vector
  Mov AL, 2Fh
  Mov AH, 35h     ; de la interrupci¢n múltiple
  Int 21h

    ; Si no coincide con nuestra propia
  Cmp BX, Offset GestorServicios
  Jne NoSePuede   ; dirección es porque se ha
  Mov BX, ES      ; instalado otro programa
    ; después que este, por lo que no es posible
    ; llevar a cabo la desinstalación
  Cmp BX, Seg GestorServicios
  Jne NoSePuede

  ; Comprobar ahora el gestor de la 1Ch
  Mov AL, 1Ch 
  Mov AH, 35h
  Int 21h

  ; Si la dirección ha cambiado
  Cmp BX, Offset Nueva1C  
  Jne NoSepuede
  Mov BX, ES
  Cmp BX, Seg Nueva1C ; no es posible desinstalar
  Jne NoSePuede

    ; Obtener en DS:DX la antigua dirección
  Mov DX, Word Ptr CS:[Antigua2F]
  Mov DS, Word Ptr CS:[Antigua2F+2]
    ; Y restituir el vector de interrupción
  Mov AL, 2Fh  
  Mov AH, 25h
  Int 21h

    ; Restituir el antiguo gestor
  Mov DX, Word Ptr CS:[Antigua1C]
  Mov DS, Word Ptr CS:[Antigua1C+2]
  Mov AL, 1Ch
  Mov AH, 25h
  Int 21h

  Clc  ; Desactivar el flag de acarreo para
  Jmp Salir ; indicar que todo fue bien y volver

  NoSePuede:

  Stc     ; Activar el indicador de acarreo

  Salir:

    ; Restablecer el PSP
  Mov BX, CS:[SegmentoPSPAnterior]
  Mov AH, 50h
  Int 21h

  Mov AX, 54321 ; Devolver otro c¢digo
  Mov BX, CS:[SegmentoPSP] ; y el segmento del PSP

  ; Restablecer la pila anterior
  Lss SP, CS:[PilaAnterior] 
  Sti ; Activar las interrupciones

  Retf 2 ; Volver eliminando el registro de
       ; indicadores de la pila

  NoLoEs:

    ; Saltar al siguiente gestor de la lista
  Jmp [CS:Antigua2F]

GestorServicios EndP

  ;-------------------------------------
  ; Gestor para la interrupción 1Ch
  ;-------------------------------------
Nueva1C Proc

  Cli ; Desactivar las interrupciones

  Push AX     ; Guardar en la pila los registros
  Mov AX, ES  ; que se van a modificar
  Push AX
  Push DI

    ; Cargar en ES:DI la direcci¢n del
    ; indicador InDos
  Mov ES, Word Ptr CS:[InDos+2]
  Mov DI, Word Ptr CS:[InDos]
    ; Obtener en AL dicho indicador
  Mov AL, Byte Ptr ES:[DI]
    ; y en AH el indicador ErrorMode
  Mov AH, Byte Ptr ES:[DI-1]

  Push AX ; Conservar los valores

  Mov AX, 0B800h ; Cargar en ES:DI la dirección
  Mov ES, AX ; de memoria de vídeo para escribir
  Mov DI, 156 ;  en ella

  Pop AX    ; Recuperar el valor de AX
  Push AX

  ; Convertir a dígito el contenido de AL
  Add AL, '0'   
  Mov AH, 70h ; Negro sobre blanco
  Stosw        ; escribir el dígito

  Pop AX  ; Recuperar ahora el valor
  Mov AL, AH ; del registro AH
  ; para escribirlo también en pantalla
  Add AL, '0' 
  Mov AH, 70h
  Stosw

  Pop DI     ; Recuperar los valores originales
  Pop AX     ; de los registros modificados
  Mov ES, AX
  Pop AX

  Sti     ; Activar de nuevo las interrupciones

    ; Pasar el control al controlador anterior
  Jmp [CS:Antigua1C]
Nueva1C EndP

  ; Reservamos 64 bytes para la pila
  ; dentro de la parte que va a quedar residente
  EspacioDePila Db 64 Dup(?)
  EtiquetaPila:

  ;-------------------------------------------
  ; Este procedimiento se ejecutar  tan sólo 
  ; al cargar el programa en memoria, no 
  ; quedando residente
  ;--------------------------------------------

Instalar Proc

  ; Preservar el segmento del PSP
  Mov CS:[SegmentoPSP], ES 

  ; CX contiene la longitud de la l¡nea de comando
  Xor CH, CH
  Mov CL, ES:[80h]

  ; Primer carácter de la línea de comandos
  Mov DI, 81h 
  Mov AL, '/' ; Carácter a buscar

  RepNe Scasb

  Jnz NoHayOpciones ; Si no se encontró la barra
            ; no hay opciones

  ; Mirar si hay una D detrás de la barra
  Cmp Byte Ptr ES:[DI], 'D'
  ; en caso contrario ignorar la línea de comandos
  Jne NoHayOpciones

  Desinstalar:  ; Si se llega a esta etiqueta es
        ; porque se quiere desinstalar

  Mov AH, 123
  Int 2Fh ; Comprobar si está instalado

  Cmp AX, 54321
  Jne NoInstalado ; No está instalado

  Push BX ; Preservar el segmento de PSP devuelto

    ; Indicar a la parte residente que restituya 
    ; el vector
  Mov AH, 123
  Mov AL, 1
  Int 2Fh

    ; Si no es posible, no continuar
  Jc NoSePuedeDesinstalar 

  Pop BX        ; Recuperar el segmento del PSP

  Mov DS, BX
  Mov ES, DS:[2Ch] ; Obtener el segmento de entorno
  Mov AH, 49h     ; liberar la memoria que ocupa
  Int 21h
  Jc Fallo1 ; Indica si hay un fallo en liberación

    ; Liberar el bloque principal del programa
  Mov ES, BX 
  Mov AH, 49h
  Int 21h
  Jc Fallo2

  Mov DX, Offset Msg3 ; Todo fue bien, el
  Jmp Imprimir ; programa se ha desinstalado

Fallo1:

    ; Indicar con un mensaje el error encontrado
  Mov DX, Offset Msg5
  Jmp Imprimir

Fallo2:

  Mov DX, Offset Msg6
  Jmp Imprimir

NoSePuedeDesinstalar:

  Pop DX ; Descartar el valor que habíamos
      ; almacenado en la pila

  Mov DX, Offset Msg4 ; No se puede desinstalar
  Jmp Imprimir

NoInstalado:

    ; El programa no está instalado actualmente
  Mov DX, Offset Msg2
  Jmp Imprimir ; terminar

   ;----------------------------
   ; A partir de aquí tenemos el proceso normal
   ; en caso de que no se pasen parámetros.
   ;----------------------------

  NoHayOpciones:

  Mov AH, 123     ; Comprobar si ya está instalado
  Int 2Fh
  Cmp AX, 54321
  ; Si es asá no permitir la reinstalación
  Je YaInstalado 

    ; Si no está instalado vamos a proceder
    ; a la instalación

    ; Preparar la pila del residente
  Mov Word Ptr CS:[PilaResidente], Offset EtiquetaPila
  Mov Word Ptr CS:[PilaResidente+2], Seg EtiquetaPila

    ; Obtener la dirección del actual gestor
  Mov AL, 2Fh
  Mov AH, 35h
  Int 21h

    ; Preservar la dirección original
  Mov Word Ptr CS:[Antigua2F], BX
  Mov Word Ptr CS:[Antigua2F+2], ES

  Mov AL, 1Ch     ; Obtener la dirección
  Mov AH, 35h   ; del actual gestor de la
  Int 21h     ; interrupción 1Ch

    ; Guardar la antigua dirección
  Mov Word Ptr CS:[Antigua1C], BX
  Mov Word Ptr CS:[Antigua1C+2], ES

  Mov AH, 34h    ; Obtener la dirección del InDos
  Int 21h

  Mov Word Ptr CS:[InDos], BX     ; y preservarla
  Mov Word Ptr CS:[InDos+2], ES

    ; Instalar en el vector la dirección
    ; apuntando a nuestro gestor
  Mov DX, Seg GestorServicios
  Mov DS, DX
  Mov DX, Offset GestorServicios
  Mov AL, 2Fh
  Mov AH, 25h
  Int 21h

    ; Instalar el nuevo gestor para la 1Ch
  Mov DX, Seg Nueva1C
  Mov DS, DX
  Mov DX, Offset Nueva1C
  Mov AH, 25h
  Mov AL, 1Ch
  Int 21h

    ; Calcular el tamaño a dejar residente
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

  ; Obtener la dirección del mensaje
  Mov AX, Seg Msg 
  Mov DS, AX
  Mov AH, 9       ; mostrarlo
  Int 21h

  Mov AH, 4Ch ; y salir sin instalar
  Int 21h

Instalar EndP

    ; Mensajes de indicación y error

Msg  Db "El programa ya est  instalado$"
Msg2 Db "El programa no est  instalado$"
Msg3 Db "El programa ha sido desinstalado$"
Msg4 Db "No es posible desinstalar el programa$"
Msg5 Db "Fallo en liberaci¢n del bloque de entorno$"
Msg6 Db "Fallo en liberaci¢n del bloque principal$"

  End


