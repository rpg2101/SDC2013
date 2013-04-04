;=====================================
; UDISK 1.0
;
; Programa de utilidad para manipular
; el sistema de archivos
;=====================================

%include "Colores.inc"

;*************************************
; Segmento de pila
;*************************************
        segment Pila stack
          resw 512
FinPila:

;*************************************
; Segmento de datos
;*************************************
        segment Datos
  ;-----------
  ; Mensaje de derechos y 
  ; varios avisos
  ;-----------
COPYRIGHT db 'UDISK 1.0',13,10 
          db 'Utilidad para manipulaci¢n de archivos'
          db 13,10
          db 'Francisco Charte Ojeda',13,10,10,'$'

MEN1      db 'Leyendo el directorio ...$'
MEN2      db 'Directorio vac¡o.$'
MEN3      db 22,26,AZUL,'Ordenando ...',0
MEN4      db 21,25,REVERSE + AZUL
          db 'Introduzca la nueva referencia ', 0
MEN5      db 21,25,REVERSE + AZUL
          db 'Introduzca el camino del nuevo directorio ', 0
MEN6      db 22,25,REVERSE + AZUL
          db 'Se produce un error. Pulse una tecla.', 0
MEN7      db 21,25,REVERSE + AZUL
          db 'Introduzca la letra de la nueva unidad de disco ', 0
MEN8      db 21,25,REVERSE + AZUL
          db 'Borrar (T)odos o (U)no ', 0
MEN9      db 21,25,REVERSE + AZUL
          db 'Escriba el nuevo nombre del archivo ', 0
MEN0      db 21,25,REVERSE + AZUL
          db 'Escriba el nombre del archivo destino ', 0
  ;-----------
  ; Variables para pedir la referencia de archivos
  ; sobre la que se trabajará, así como el
  ; directorio al que se desea cambiar
  ;-----------
REFER     db 22,25,AZUL,12
          times 12 db ' '
          db 0

DIREC     db 22,25,AZUL,50
          times 50 db ' '
          db 0
  ;-----------
  ; Los dos campos siguientes servirán para borrar
  ; la ventana de mensajes
  ;-----------
BORR1     db 21,24,BLANCO
          times 54 db ' '
          db 0
     
BORR2     db 22,24,BLANCO
          times 54 db ' '
          db 0
  ;-----------
  ; Este campo se usará para obtener un 
  ; directorio de los archivos a tratar,
  ; en principio todos
  ;-----------
TODOS     db '*.*         ', 0
  ;-----------
  ; A medida que vayan leyéndose archivos
  ; se irán imprimiendo puntos
  ;-----------
PUNTO     db '.$'
  ;-----------
  ; Los 128 bytes siguientes se utilizarán
  ; como área de transferencia de datos
  ;-----------
DTA       resb 128
  ;-----------
  ; En este campo se guardará la dirección del
  ; nombre del último archivo del directorio
  ;-----------
FINAL     dw 0

CUENTA    dw 0   ; Número de archivos en el directorio
LINEA     db 0   ; Línea actual en pantalla
PUNT1     dw 0   ; Archivo seleccionado en pantalla
PUNT2     dw 0   ; Primer archivo que aparece en pantalla
  ;-----------
  ; Variable para ir imprimiendo en la ventana
  ; de archivos los nombres de éstos. Aunque en
  ; la línea se indica 0 se modificará desde el código
  ;-----------
LIN_VEN   db 0,6,AZUL
          resb 12
          db 0
  ;-----------
  ; Zona para almacenar los nombres de los
  ; archivos existentes en el directorio
  ;-----------
DIRECTO   resb 12*1024
  ;-----------
  ; Variable temporal para intercambios
  ; al ordenar
  ;-----------
TEMP      resb 12
  ;-----------
  ; Direcciones de los elementos que 
  ; se están comparando
  ;-----------
ELEM1     dw 0
ELEM2     dw 0
  ;-----------
  ; Variables para almacenar los manejadores
  ; de entrada y salida y buffer de almacenamiento
  ; tempora para la opción de copia de archivos
  ;-----------
HANDLE_IN   dw 0
HANDLE_OUT  dw 0
BUFF_COPIA  resb 1024
  ;-----------
  ; Línea de cabecera de la pantalla.
  ; En la variable ACTUAL se almacenará el camino
  ; del directorio actual, y en CADENA el número
  ; de archivos seleccionados
  ;-----------
LIN1   db 0,0,REVERSE + AZUL
       db '  UDISK Versi¢n 1.0          '
ACTUAL db '                              '
CADENA db '     '
       db ' Archivos       ', 0
  ;-----------
  ; Líneas que componen la pantalla
  ;-----------
PAN  db  2, 3,BLANCO,201
     times 16 db 205
     db 187,0
     
     db  3, 3,BLANCO,186
     times 16 db ' '
     db 186,'  F1 - Ordena directorio por nombre',0
     
     db  4, 3,BLANCO,186
     times 16 db ' '
     db 186,0
     
     db  5, 3,BLANCO,186
     times 16 db ' '
     db 186,'  F2 - Ordena directorio por extensi¢n',0
     
     db  6, 3,BLANCO,186
     times 16 db ' '
     db 186,0
     
     db  7, 3,BLANCO,186
     times 16 db ' '
     db 186,'  F3 - Borra archivo(s)',0
     
     db  8, 3,BLANCO,186
     times 16 db ' '
     db 186,0
     
     db  9, 3,BLANCO,186
     times 16 db ' '
     db 186,'  F4 - Renombra archivo',0
     
     db 10, 3,BLANCO,186
     times 16 db ' '
     db 186,0
     
     db 11, 3,BLANCO,186
     times 16 db ' '
     db 186,'  F5 - Copia archivo',0
     
     db 12, 3,BLANCO,186
     times 16 db ' '
     db 186,0
     
     db 13, 3,BLANCO,186
     times 16 db ' '
     db 186,'  F6 - Cambia de disco',0
     
     db 14, 3,BLANCO,186
     times 16 db ' '
     db 186,0
     
     db 15, 3,BLANCO,186
     times 16 db ' '
     db 186,'  F7 - Cambia de directorio',0
     
     db 16, 3,BLANCO,186
     times 16 db ' '
     db 186,0
     
     db 17, 3,BLANCO,186
     times 16 db ' '
     db 186,'  F8 - Establecer referencia de b£squeda',0
     
     db 18, 3,BLANCO,186
     times 16 db ' '
     db 186,0
     
     db 19, 3,BLANCO,186
     times 16 db ' '
     db 186,'  ESC - Salir al DOS',0
     
     db 20, 3,BLANCO,186
     times 16 db ' '
     db 186,'  ',201
     times 54 db 205
     db 187,0
     
     db 21, 3,BLANCO,186
     times 16 db ' '
     db 186,'  ',186
     times 54 db ' '
     db 186,0
     
     db 22, 3,BLANCO,186
     times 16 db ' '
     db 186,'  ',186
     times 54 db ' '
     db 186,0
     
     db 23, 3,BLANCO,200
     times 16 db 205
     db 188,'  ',200
     times 54 db 205
     db 188,0
     
     db 255
  ;-----------
  ; Buffer para obtener el camino
  ; del directorio actual
  ;-----------
CAMINO resb 128
  ;-----------
  ; Tabla de opciones. Por cada opción
  ; se almacena un byte con el código
  ; extendido de la tecla de elección y
  ; una palabra con la dirección de la
  ; rutina a ejecutar por dicha tecla
  ;-----------
OPCIONES db 72
         dw SUBIR
         db 80
         dw ABAJO
         db 59
         dw ORDEN1
         db 60
         dw ORDEN2
         db 61
         dw BORR
         db 62
         dw RENOMBRAR
         db 63
         dw COPIAR
         db 64
         dw DISCO
         db 65
         dw DIRECTORIO
         db 66
         dw REFERENCIA
          
;*************************************
; Segmento de código
;*************************************
        segment Codigo
..start:
INICIO:
        ; Preparamos los registros de pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; y los del segmento de datos
        mov ax, Datos
        mov ds, ax
        mov es, ax
        
        ; Imprimir el mensaje de copyright
        mov dx,COPYRIGHT
        mov ah,9
        int 21h
        
        ; Leer los archivos del directorio
        call LEEDIR
        
        ; Borrar la pantalla
        call BORRA
        
        ; Imprime la máscara del programa
        call PANTA
        
        ; En principio la línea 4 será
        ; la resaltada
        mov byte [LINEA], 4
        ; el archivo elegido será el primero
        mov byte [PUNT1], 0
        ; el primer archivo a mostrar
        ; será el mismo
        mov byte [PUNT2], 0
        
        ; Hacemos desaparecer el cursor
        call SIN_CURSOR

BUC_CENTRAL:

        ; Imprime la lista de archivos
        ; en la ventana
        call LISTA_ARCH
        
ESPERA_TECLA:

        ; espera la pulsación de una tecla
        xor ah, ah
        int 16h
        
        ; ¿Es ESC?
        cmp al, 27
        ; de ser así terminar
        je FIN_UDISK
        
        ; apuntar a la tabla de opciones
        mov si,OPCIONES
        ; hay 10 opciones disponibles
        mov cx,10
        
BUC_COMPARA:

        ; comparar la tecla pulsada con
        ; la de la tabla
        cmp [si],ah
        ; si son iguales saltar
        je SALTA_RUTINA
        
        ; no coincide, saltar a la
        ; opción siguiente
        add si,3
        ; y seguir comparando
        loop BUC_COMPARA
        
        ; si no coincide ninguna esperar
        ; otra pulsación
        jmp ESPERA_TECLA
        
SALTA_RUTINA:

        ; la tecla coincide
        ; incrementar SI para que apunte
        ; a la dirección
        inc si
        ; y llamar a la rutina correspondiente
        call [si]        
        
        ; tras ejecutar la rutina,
        ; volver al bucle principal
        jmp BUC_CENTRAL
        
  ;-----------
  ; Aquí se llega cuando se pulsa
  ; la tecla ESC
  ;-----------
FIN_UDISK:  
        call BORRA ; borramos la pantalla
        call CON_CURSOR ; mostramos el cursor
        
        mov ah, 4Ch ; y salimos al DOS
        int 21h
        
  ;-----------
  ; Aquí se llega cuando se pulsa
  ; el cursor hacia arriba
  ;-----------
SUBIR:
        ; toma el número de archivo
        ; actual en pantalla
        mov ax, [PUNT1]
        ; ¿es cero?
        or ax, ax
        ; de ser así saltar
        jz FIN_SUBIR
        
        ; si no 0 pasar al anterior
        dec ax
        ; y guardar el índice
        mov [PUNT1], ax
        
        ; ¿estamos en la línea 4?
        cmp byte [LINEA], 4
        ; de ser así salta a DESP_ABAJO
        je DESP_ABAJO
        
        ; en caso contrario
        ; reducimos la línea actual
        dec byte [LINEA]
        ; y volver
        ret
        
DESP_ABAJO:
    ; Si llegamos aquí es que hay que
    ; subir una línea pero estamos en
    ; la primera.
    ; Se reduce el puntero del primer
    ; archivo a mostrar, cono lo que al
    ; volver a imprimir la ventana se
    ; obtendrá un efecto de desplazamiento
    ; sobre la lista de archivos
    
    ; reducimos el puntero del primer
    ; archivo a mostrar
    dec word [PUNT2]
    ; y borramos el contenido de
    ; la ventana
    call LIMPIA_VEN
    
FIN_SUBIR:
    ret ; volver
    
  ;-----------
  ; Aquí se llega cuando se pulsa
  ; el cursor hacia abajo
  ;-----------
ABAJO:
     ; Tomar el número del archivo
     ; actual en pantalla
     mov ax, [PUNT1]
     ; ¿es el último de la lista?
     cmp ax, [CUENTA]
     ; de ser así salta
     je FIN_ABAJO
     
     ; incrementamos para pasar
     ; al archivo siguiente
     inc ax
     ; y lo guardamos
     mov [PUNT1], ax
     
     ; ¿estamos en la última línea de la ventana?
     cmp byte [LINEA], 21
     ; en caso afirmativo saltar
     je DESP_SUBIR
     
     ; en caso contrario incrementar
     ; la línea
     inc byte [LINEA]
     
     ret ; y volver
     
DESP_SUBIR:
     ; si se ha de pasar al archivo siguiente
     ; pero estamos en la última línea de pantalla,
     ; se incrementa el puntero del primer archivo
     ; visible, con lo que la lista dará la impresión
     ; de desplazarse hacia arriba una línea, aunque
     ; la línea actual no se mueva
     
     ; borramos la ventana de archivos
     call LIMPIA_VEN
     ; e incrementamos el puntero
     inc word [PUNT2]
     
FIN_ABAJO:
     ret ; volver

  ;-----------
  ; Aquí se llega cuando se pulsa
  ; la tecla F1, cuya finalidad es
  ; ordenar la lista de nombres de
  ; archivos alfabéticamente por
  ; nombre
  ;-----------
ORDEN1:
     ; imprimir el mensaje de espera
     mov si, MEN3
     call IMPRIME
     
     ; mover a CX el número de
     ; elementos
     mov cx, [CUENTA]
     
BUC_ORDEN0:
     push cx ; guardamos CX
     ; leer en CX el número
     ; de elementos a ordenar
     mov cx, [CUENTA]
     
     ; SI apunta al primer archivo
     mov si, DIRECTO
     ; y DI al segundo
     mov di, DIRECTO+12
     
BUC_ORDEN1:
     cld ; autoincremento de di y si
     
     push cx ; guardar CX
     ; guardar la dirección
     ; de los elementos a comparar
     mov [ELEM1], si
     mov [ELEM2], di
     
     ; comparar 8 caracteres
     mov cx, 8
     ; repite la comparación
     ; mientras coincida
     repe cmpsb
     
     ; si son iguales saltar
     jbe BIEN1
     
     ; en caso contrario intercambia
     ; los elementos
     call INTERCAM
     
BIEN1:
     ; recuperar la dirección de 
     ; los dos elementos
     mov si, [ELEM1]
     mov di, [ELEM2]
     
     ; y sumar 12 para apuntar
     ; a los dos siguientes
     add si, 12
     add di, 12
     
     ; recuperamos el contador del
     ; bucle interno
     pop cx
     
     ; y repetimos la comparación
     loop BUC_ORDEN1
     
     ; recuperar el contador del
     ; bucle externo
     pop cx
     
     ; y repetir el ciclo de 
     ; comparaciones
     loop BUC_ORDEN0
     
     ; borrar la ventana de archivos
     call LIMPIA_VEN
     ; y la de mensajes
     call LIMPIA_MEN
     
     ; volver al bucle principal
     ; del programa
     ret

  ;-----------
  ; Aquí se llega cuando se pulsa
  ; la tecla F2, cuya finalidad es
  ; ordenar la lista de nombres de
  ; archivos alfabéticamente por
  ; extensión del archivo
  ;-----------
ORDEN2:
      ; imprimir mensaje de espera
      mov si, MEN3
      call IMPRIME
      
      ; CX contiene el número de
      ; ciclos de ordenación
      mov cx, [CUENTA]
      
BUC1_ORDEN0:
      ; guardamos CX
      push cx
      ; para asignarle el número
      ; de archivos a ordenar
      mov cx, [CUENTA]
      
      ; SI apunta al primer archivo
      mov si, DIRECTO
      ; y DI al segundo
      mov di, DIRECTO+12
      
BUC1_ORDEN1:
      cld ; autoincremento de SI y DI
      
      push cx ; guardar contador
      
      ; guardamos las direcciones 
      ; de los elementos
      mov [ELEM1], si
      mov [ELEM2], di
      
      ; buscar el '.' de separación en
      ; el archivo apuntado por ES:DI
      mov al, '.'
      ; en 9 caracteres máximo
      mov cx, 9
      ; repite mientras no lo encuentres
      repne scasb
      
      ; guardar DI, que tiene la dirección
      ; del punto en el nombre de archivo
      push di
      
      ; mover SI a DI
      mov di, si
      ; buscar en 9 caracteres
      mov cx, 9
      ; repite mientras no lo encuentres
      repne scasb
      
      ; pasar la dirección a SI
      mov si, di
      ; y recuperar la de DI
      pop di
      
      ; Llegados a este punto, SI y DI apuntan a
      ; la extensión de los nombres de archivo
      
      ; comparar tres caracteres
      mov cx, 3
      ; repite mientras sean iguales
      repe cmpsb
      
      ; si son iguales salta
      jbe BIEN2
      
      ; en caso contrario intercambiamos
      call INTERCAM
      
BIEN2:
      ; recuperar las direcciones de
      ; los elementos
      mov si, [ELEM1]
      mov di, [ELEM2]
      
      ; y actualizarlos para apuntar
      ; a los siguientes elementos
      add si, 12
      add di, 12
      
      ; recuperar el contador de
      ; archivos a comparar
      pop cx
      
      ; y seguir comparando
      loop BUC1_ORDEN1
      
      ; recuperar el contador de
      ; ciclos de ordenación
      pop cx
      
      ; y repetir
      loop BUC1_ORDEN0
      
      ; limpiar la ventana de archivos
      call LIMPIA_VEN
      ; y la de mensajes
      call LIMPIA_MEN
      
      ret ; volver
      
  ;-----------
  ; Esta rutina es usada por las dos
  ; anteriores para intercambiar los
  ; elementos apuntados por ELEM1 y ELEM2
  ;-----------
INTERCAM:
      ; Llevar el contenido del segundo
      ; elemento al espacio temporal
      mov si, [ELEM2]
      mov di, TEMP
      mov cx, 12
      rep movsb
      
      ; copiar el contenido del primer
      ; elemento al segundo
      mov di, [ELEM2]
      mov si, [ELEM1]
      mov cx, 12
      rep movsb
      
      ; por último llevar el área temporal
      ; al primer elemento
      mov di, [ELEM1]
      mov si, TEMP
      mov cx, 12
      rep movsb
      
      ret ; volver

  ;-----------
  ; A esta rutina se llega cuando se pulsa F3
  ; Su finalidad es borrar el archivo elegido
  ; en ese momento o todos los seleccionados
  ; en la ventana
  ;-----------
BORR:
      ; imprimir el mensaje que pregunta
      ; si se desea borrar el archivo 
      ; actual o todos
      mov si, MEN8
      call IMPRIME
      
      ; mostrar el cursor
      call CON_CURSOR
      
      ; colocarnos en la ventana
      ; de mensajes
      mov ah, 2
      mov dh, 22
      mov dl, 25
      int 10h
      
BORR_1:
      ; esperamos la pulsación
      ; de una tecla
      xor ah, ah
      int 16h
      
      ; convertimos a mayúscula
      and al, 11011111b
      
      ; ¿es la 'T'?
      cmp al, 'T'
      ; si es así saltar
      je BOR_TODOS
      
      ; ¿es la 'U'?
      cmp al, 'U'
      ; si no, repetir la solicitud
      jne BORR_1
      
UNO:
      ; borrar el archivo elegido
      ; en este momento
      call BOR_FIC
      
FIN_BOR:
      ; ocultar el cursor
      call SIN_CURSOR
      
      ; limpiar la ventana de mensajes
      call LIMPIA_MEN
      
      ; poner a 0 el número
      ; de archivos
      mov word [CUENTA], 0
      
      ; borrar la pantalla
      call BORRA
      
      ; y volver a leer el directorio
      jmp INICIO
      
  ; Esta rutina tiene el objetivo de borrar
  ; el archivo indicado por PUNT1      
BOR_FIC:
      ; limpiar el espacio donde va
      ; a tomarse el nombre
      call LIMPIA_BUF
      
      mov ax, [PUNT1] ; archivo número PUNT1
      mov bx, 12  ; 12 caracteres cada nombre
      mul bx  ; multiplicar
      
      ; SI apunta al inicio de la tabla
      mov si, DIRECTO
      ; sumar para acceder al elemento deseado
      add si, ax
      
      ; copiar el nombre de la tabla al
      ; espacio de trabajo
      call PASA_BUF
      
      ; que está en LIN_VEN+3
      mov dx, LIN_VEN+3
      mov ah, 41h ; función de borrado
      int 21h
      
      ret ; volver

   ; Esta rutina borra todos los archivos
   ; seleccionados en la ventana
BOR_TODOS:
      ; tomamos el número de archivos
      mov cx, [CUENTA]
      ; lo incrementamos porque contamos
      ; desde 0
      inc cx
      ; PUNT1 apuntará al primer archivo
      mov word [PUNT1], 0
      
BUCLE_BOR:
      ; guardamos CX
      push cx
      
      ; llamar a la rutina que borra
      ; el archivo actual
      call BOR_FIC
      
      ; incrementar el puntero
      inc word [PUNT1]
      
      ; recuperar el contador
      pop cx
      
      ; y seguir
      loop BUCLE_BOR
      
      ; Establecer la referencia para
      ; seleccionar de nuevo todos 
      ; los archivos
      mov byte [TODOS], '*'
      mov byte [TODOS+1], '.'
      mov byte [TODOS+2], '*'
      mov byte [TODOS+3], 0
      
      ; saltar a FIN_BOR
      jmp FIN_BOR

  ;-----------
  ; A esta rutina se llega cuando se pulsa F4
  ; Su finalidad es renombrar el archivo que
  ; esté elegido en ese momento
  ;-----------
RENOMBRAR:
      ; imprimr el mensaje de petición
      ; del nuevo nombre para el archivo
      mov si, MEN9
      call IMPRIME
      
      ; mostrar el cursor
      call CON_CURSOR
      
      ; borrar el buffer donde va a
      ; pedirse el nuevo nombre
      mov di, REFER+4
      mov cx, 12
      mov al, ' '
      cld
      rep stosb
      
      ; dato a pedir
      mov si, REFER
      call PETICION ; rutina de petición
      
      ; Limpiar el buffer a donde pasar
      ; el nombre del archivo a renombrar
      call LIMPIA_BUF
      
      ; PUNT1 contiene el número de
      ; archivo elegido
      mov ax, [PUNT1]
      ; 12 caracteres por archivos
      mov bx, 12
      ; multiplicar para obtener el
      ; desplazamiento
      mul bx
      
      ; SI apunta al elemento que tiene
      ; el nombre del archivo a renombrar
      mov si, DIRECTO
      add si, ax
      
      ; pasar al buffer, que es LIN_VEN
      call PASA_BUF
      
      ; DX apunta al nombre actual
      mov dx, LIN_VEN+3
      ; y DI al nuevo
      mov di, REFER+4
      ; función de renombrado
      mov ah, 56h
      int 21h
      
      ; borramos la pantalla
      call BORRA
      
      ; ponemos a 0 el número de
      ; archivos leídos
      mov word [CUENTA], 0
      
      ; ocultar el cursor
      call SIN_CURSOR
      
      ; volver a leer el directorio
      jmp INICIO

  ;-----------
  ; A esta rutina se llega cuando se pulsa F5
  ; Su finalidad es copiar el archivo elegido
  ; en ese momento
  ;-----------
COPIAR:
       ; mostrar el mensaje de petición
       ; del camino de destino
       mov si, MEN0
       call IMPRIME
       
       ; mostrar el cursor
       call CON_CURSOR
       
       ; limpiar el buffer donde va a 
       ; pedirse el camino
       mov di, REFER+4
       mov al, ' '
       mov cx, 12
       cld
       rep stosb
       
       ; pedir el camino de destino
       mov si, REFER
       call PETICION
       
       ; limpiar el buffer donde va a
       ; almacenarse el nombre del
       ; archivo a copiar
       call LIMPIA_BUF
       
       ; calcular la dirección del nombre
       ; del archivo dentro de la tabla
       mov ax, [PUNT1]
       mov bx, 12
       mul bx
       mov si, DIRECTO
       add si, ax
       
       ; copiar el nombre al buffer
       call PASA_BUF
       
       ; abrir el archivo para lectura
       mov dx, LIN_VEN+3
       mov ah, 3Dh
       xor al, al
       int 21h
       
       ; guardamos el manejador
       mov [HANDLE_IN], ax
       
       ; abrir el archivo de destino
       ; creándolo
       mov dx, REFER+4
       mov ah, 3Ch
       xor cx, cx
       int 21h
       
       ; guardar el manejador devuelto
       mov [HANDLE_OUT], ax
       
BUCLE_COPIA:
       ; leemos 1 kilobyte del
       ; archivo de origen
       mov bx, [HANDLE_IN]
       mov cx, 1024
       ; dejándolo en BUFF_COPIA
       mov dx, BUFF_COPIA
       mov ah, 3Fh
       int 21h
       
       ; saltar si hay error
       jc FIN_COPIA
       
       ; saltar si se llegó 
       ; al final del archivo
       or ax, ax
       jz FIN_COPIA
       
       ; escribimos la información leída
       ; en el archivo de destino
       mov bx, [HANDLE_OUT]
       mov cx, ax
       mov dx, BUFF_COPIA
       mov ah, 40h
       int 21h
       
       ; repetir el proceso
       jmp BUCLE_COPIA
       
FIN_COPIA:
       ; ocultar el cursor
       call SIN_CURSOR
       
       ; limpiamos la ventana de mensajes
       call LIMPIA_MEN
       
       ; ponemos a 0 el contador de
       ; archivos
       mov word [CUENTA], 0
       
       ; borramos la pantalla
       call BORRA
       
       ; y volvemos a leer el directorio
       jmp INICIO

  ;-----------
  ; A esta rutina se llega cuando se pulsa F6
  ; Su finalidad es cambiar la unidad de disco
  ; por defecto
  ;-----------
DISCO:
       ; imprimir el mensaje de petición
       ; de nueva letra de unidad
       mov si, MEN7
       call IMPRIME
       
       ; mostrar el cursor
       call CON_CURSOR
       
       ; y ponerlo en la ventana
       ; de mensajes
       mov dh, 22
       mov dl, 25
       mov ah, 2
       int 10h
       
       ; esperar la pulsación de una tecla
       xor ah, ah
       int 16h
       
       ; convertir a mayúscula
       and al, 11011111b
       
       ; le restamos 'A' con lo que se
       ; obtiene 0 si era A, 1 si era B, etc
       sub al, 'A'
       
       ; pasamos la unidad a DL
       mov dl, al
       ; función de cambio de unidad
       mov ah, 0Eh
       int 21h
       
       ; ocultamos el cursor
       call SIN_CURSOR
       
       ; limpiamos la ventana de mensajes
       call LIMPIA_MEN
       
       ; borrar la pantalla
       call BORRA
       
       ; poner a 0 el contador de archivos
       mov word [CUENTA], 0
       
       ; leer el directorio de la
       ; nueva unidad
       jmp INICIO

  ;-----------
  ; A esta rutina se llega cuando se pulsa F7
  ; Su finalidad es permitir el cambio del
  ; directorio actual
  ;-----------
DIRECTORIO:
        ; imprimir el mensaje de petición
        ; del nuevo camino
        mov si, MEN5
        call IMPRIME
        
        ; mostrar el cursor
        call SIN_CURSOR
        
        ; limpiar el buffer de petición
        mov di, DIREC+4
        mov al, ' '
        mov cx, 50
        cld
        rep stosb
        
        ; pedir el nuevo camino
        mov si, DIREC
        call PETICION
        
        ; cambiar al camino
        ; indicado
        mov dx, DIREC+4
        mov ah, 3Bh
        int 21h
        
        ; ponemos a 0 el contador
        mov word [CUENTA], 0
        
        ; borrar la pantalla
        call BORRA
        
        ; y volver a leer el directorio
        jmp INICIO

  ;-----------
  ; A esta rutina se llega cuando se pulsa F8
  ; Su finalidad es permitir el cambio de la
  ; referencia usada para seleccionar los
  ; archivos y, por ejemplo, poder borrar
  ; un grupo de archivos
  ;-----------
REFERENCIA:        
        ; imprimir el mensaje de petición
        ; de la nueva referencia
        mov si, MEN4
        call IMPRIME
        
        ; limpiar el buffer donde va
        ; a pedirse la referencia
        mov di, REFER+4
        mov cx, 12
        mov al, ' '
        cld
        rep stosb
        
        ; mostrar el cursor
        call CON_CURSOR
        
        ; pedir la nueva referencia
        mov si, REFER
        call PETICION
        
        ; mover la nueva referencia al espacio
        ; que usa la rutina de visualización
        ; de archivos
        mov si, REFER+4
        mov di, TODOS
        mov cx, 12
        rep movsb
        
        ; borramos la pantalla
        call BORRA
        
        ; ponemos a 0 el contador de archivos
        mov word [CUENTA], 0
        
        ; volver a leer el directorio
        ; usando la nueva referencia
        jmp INICIO

  ;-----------
  ; Su finalidad es permitir el cambio de la
  ; referencia usada para seleccionar los
  ; archivos y, por ejemplo, poder borrar
  ; un grupo de archivos
  ;-----------
LISTA_ARCH:
        ; SI apunta al inicio de la tabla
        mov si, DIRECTO
        
        ; calcular la dirección del
        ; primer elemento a mostrar,
        ; que viene indicado por PUNT2
        mov ax, [PUNT2]
        mov bx, 12
        mul bx
        add si, ax
        
        ; imprimir 18 archivos en pantalla
        mov cx, 18
        ; establecer el color AZUL
        mov byte [LIN_VEN+2], AZUL
        ; la primera línea de la 
        ; ventana es la 4
        mov dh, 4
        
BUC_LISTA:
        ; guardamos el contador de archivos
        push cx
        
        ; mover DH a la línea de la variable
        ; de impresión
        mov [LIN_VEN], dh
        
        ; incrementar la línea
        inc dh
        ; y guardarla
        push dx
        
        ; Limpiamos LIN_VEN
        call LIMPIA_BUF
        ; y pasa el fichero de la tabla
        ; apuntado por SI
        call PASA_BUF
        
        ; guardar la dirección del archivo siguiente
        push si
        ; e imprimirlo
        mov si, LIN_VEN
        call IMPRIME
        
        pop si ; recuperar la dirección
        pop dx ; la línea del cursor
        pop cx ; y el contador
        
        ; ¿Hemos llegado al final de la tabla?
        cmp si, [FINAL]
        ; si es así saltar
        jge FIN_BUFFER
        
        ; en caso contrario seguir
        loop BUC_LISTA
        
FIN_BUFFER:
        ; Una vez impresos los nombres en la ventana,
        ; se muestra en vídeo inverso el nombre del
        ; archivo seleccionado actualmente
        
        ; establecer el color
        mov byte [LIN_VEN+2], REVERSE + AZUL
        ; tomar la línea actual
        mov al, [LINEA]
        ; y ponerla en LIN_VEN
        mov [LIN_VEN], al
        
        ; calcular la dirección del archivo
        ; elegido actualmente 
        mov si, DIRECTO
        mov ax, [PUNT1]
        mov bx, 12
        mul bx
        add si, ax
        
        ; lo pasamos al buffer para
        ; imprimirlo
        call LIMPIA_BUF
        call PASA_BUF
        
        ; mostrar el nombre
        mov si, LIN_VEN
        call IMPRIME
        
        ret ; volver

  ;-----------
  ; Esta rutina limpia la ventana de archivos,
  ; para que al desplazar su contenido no queden
  ; en las líneas trozos de los nombres anteriores
  ;-----------
LIMPIA_VEN:
        xor al, al ; 0 líneas
        mov bh, BLANCO ; y color blanco
        mov ch, 4  ; marca las esquinas 
        mov cl, 6  ; de la ventana de archivos
        mov dh, 21
        mov dl, 18
        mov ah, 6 ; scroll arriba
        
        int 10h ; borramos
        
        ret ; volver

  ;-----------
  ; Esta rutina borra el contenido de la ventana
  ; de mensajes
  ;-----------
LIMPIA_MEN:
        ; borramos la primera línea
        mov si, BORR1
        call IMPRIME
        ; y la segunda
        mov si, BORR2
        call IMPRIME
        
        ret ; volver

  ;-----------
  ; Para muchas operaciones se usa LIN_VEN. La 
  ; finalidad de esta rutina es limpiar el 
  ; buffer de 12 caracteres que tiene dicha variable
  ;-----------
LIMPIA_BUF:
        ; apuntar al buffer
        mov di, LIN_VEN+3
        mov cx, 12  ; 12 caracteres
        mov al, ' ' ; rellenar de espacios
        rep stosb
        
        ret ; volver

  ;-----------
  ; Esta rutina pasa los 12 caracteres apuntados
  ; por SI al buffer de LIN_VEN
  ;-----------
PASA_BUF:
       ; DI apunta al destino
       mov di, LIN_VEN+3
       mov cx, 12 ; mover 12 caracteres
       rep movsb
       
       ret ; volver
       
;---------------------------
; Esta rutina es invocada al
; principio del programa para
; leer el directorio y poner
; los nombres de los archivos
; en la matriz apuntada por
; la variable DIRECTO
;---------------------------
LEEDIR:
      ; Imprimir el mensaje de que
      ; se está leyendo el directorio
      mov dx,MEN1
      mov ah,9
      int 21h
      
      ; Establecer la dirección de
      ; transferencia de datos
      mov dx,DTA
      mov ah,1Ah
      int 21h
      
      ; Apuntar a la referencia que 
      ; se busca
      mov dx,TODOS
      mov ah,4Eh ; buscar primera coincidencia
      xor cx,cx ; archivos normales
      int 21h
      
      ; si hay archvos que cumplan la
      ; referencia saltar a SALTO1
      jnc SALTO1
      
      ; El directorio está vacío
      
      ; imprimir el mensaje de error
      mov dx,MEN2
      mov ah,9
      int 21h
      
      ; y devolver el control al DOS
      mov ah,4Ch
      int 21h

SALTO1:

      ; DI apunta a la tabla para
      ; almacenar los nombres
      mov di,DIRECTO
      
BUCLE_LEE:

      ; SI apunta al nombre dentro de la DTA
      mov si,DTA+30
      mov cx,12 ; 12 caracteres
      rep movsb ; moverlos a la tabla de nombres
      
      ; incrementar el contador de archivos leídos
      inc byte [CUENTA]
      
      ; buscar siguiente coincidencia
      mov ah,4Fh
      int 21h
      
      ; si no hay más saltar a FIN
      jc FIN
      
      ; en caso contrario imprimir un punto
      mov dx,PUNTO
      mov ah,9
      int 21h
      
      ; y repetir el proceso
      jmp BUCLE_LEE

FIN:

      ; reducir CUENTA en una unidad porque
      ; el primer archivo en la tabla es el 0
      dec byte [CUENTA]
      
      ; mover a FINAL la última dirección
      ; de la tabla
      mov [FINAL],DI
      
      ret ; volver

  ;-----------
  ; Esta rutina imprime la pantalla definida
  ; en el segmento de datos, con la información
  ; del directorio actual y el número de 
  ; archivos leídos
  ;-----------
PANTA:
      xor dl, dl  ; unidad actual
      ; apuntar al buffer donde se
      ; dejará el camino
      mov si, CAMINO
      ; obtenemos el camino actual
      mov ah, 47h
      int 21h
      
      ; limpiar el buffer donde va a
      ; almacenarse el camino
      mov di, ACTUAL
      mov cx, 30
      mov al, ' '
      rep stosb
      
      ; DI apunta al inicio del buffer
      mov di, ACTUAL
      ; copiar como máximo 30 caracteres
      mov cx, 30

BUC_PANTA:
      ; ¿Es 0 el byte a copiar?
      cmp byte [si], 0
      ; en cas afirmativo hemos terminado
      je SALTO_PANTA1
      
      ; en caso contrario pasar el
      ; byte de DS:SI a ES:DI
      movsb
      
      loop BUC_PANTA ; repetir
      
SALTO_PANTA1:
      ; tomar en AX el número de archivos leídos
      mov ax, [CUENTA]
      ; incrementar para contar el 0
      inc ax
      
      ; DI apunta al buffer donde debe
      ; dejarse la conversión
      mov di, CADENA+4
      
      call EnteroCadena ; convertir
      
      ; Apuntar a la línea de cabecera
      mov si, LIN1
      call IMPRIME ; e imprimir
      
      ; apunta a las líneas que
      ; componen la pantalla
      mov si, PAN
      
BUC_PANTA1:
      call IMPRIME  ; imprimir la línea
      
      inc si ; apuntar al byte siguiente
      ; si no es 255
      cmp byte [si], 255
      ; continuar imprimiendo
      jnz BUC_PANTA1
      
      ret ; volver
      
  ;-----------
  ; Esta rutina oculta el cursor asignándole un
  ; tamaño que no puede tener
  ;-----------
SIN_CURSOR:
       mov ch, 15  ; línea de comienzo y fin 15
       mov cl, 15
       mov ah, 1
       int 10h
       
       ret ; volver

  ;-----------
  ; Esta rutina es complementaria de la anterior,
  ; volviendo a mostrar el cursor
  ;-----------
CON_CURSOR:        
       mov ch, 7  ; línea de comienzo y fin 7
       mov cl, 7
       mov ah, 1
       int 10h

       ret ; volver

%include "Borra.inc"
%include "Imprime.inc"
%include "Peticion.inc"        
%include "Convert.inc"
