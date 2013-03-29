        segment Pila stack
          resw 512
FinPila:
        
        segment Datos
; Nombre del archivo temporal 
; para la copia        
Archivo db "c:\temp.dat", 0

; Manejador del archivo
Manejador dw 0

; Reservamos espacio para
; leer una pista completa
Buffer resb 18*512

; Cara y pista que están leyéndose
Cara db 0
Pista db 0

;
; Mensajes que usará el programa
;

MEN1 db 1,1,7
     db 'Inserte el disquete original y '
     db 'pulse una tecla ...', 0
     
MEN2 db 3,1,7
     db 'Inserte el disquete destino y '
     db 'pulse una tecla ...', 0
     
MEN3 db 10,1,7
     db '¿Desea otra copia de este disco? ', 0
     
MEN4 db 10,1,7
     db '¿Desea copiar otro disco? ', 0
     
MEN5 db 10,1,7,'Leyendo ...', 0
MEN6 db 10,1,7,'Escribiendo ...', 0

;
; Cadena para borrar una determinada
; línea de pantalla
;

Vacia db 0,1,7
      times 50 db ' '
      db 0
      
;
; Cadena para ir imprimiendo por pantalla
; la pista y cara que se procesan
;

Info db 5,1,7
     db 'Cara :       Pista :        ', 0      

;*********************************
; Segmento de código
;*********************************
        segment Codigo
..start:
Inicio:
        ; Preparar los registros de pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; y del segmento de datos
        mov ax, Datos
        mov ds, ax
        mov es, ax

        ; Tomamos el nombre de archivo
        mov dx, Archivo
        ; sin atributos especiales
        xor cx, cx
        ; creamos el archivo
        mov ah, 3Ch
        int 21h
        
        ; guardamos el manejador
        mov [Manejador], ax
        
        ; borramos la pantalla
        call BORRA
        
        ; imprimir el mensaje de
        ; inserción del disco de origen
        mov si, MEN1
        call IMPRIME
        
        ; esperamos la pulsación
        ; de una tecla
        xor ah, ah
        int 16h
        
        ; borrar la línea
        mov byte [Vacia], 1
        mov si, Vacia
        call IMPRIME
        
        ; imprimir el mensaje de
        ; que está leyéndose
        mov si, MEN5
        call IMPRIME
        
; En este bucle se irán leyendo las 
; pistas que forman el disco, y se
; irán escribiendo en un archivo del
; disco duro

Bucle:

        ; Convertimos el número
        ; de cara en cadena
        mov di, Info+9
        mov al, [Cara]
        inc al
        xor ah, ah
        call EnteroCadena
        
        ; Hacemos los mismos con
        ; el número de pista
        mov di, Info+23
        mov al, [Pista]
        inc al
        xor ah, ah
        call EnteroCadena
        
        ; Imprimimos la línea que
        ; informa de la cara y 
        ; pista que se leen
        mov si, Info
        call IMPRIME
        
Try:
        ; Leer de la unidad 0 (A:)
        xor dl, dl          
        ; DH contiene la cara
        mov dh, [Cara]
        ; y CH la pista
        mov ch, [Pista]
        ; leeremos desde el sector 1
        mov cl, 1
        ; los 18 sectores de la pista
        mov al, 18
        ; indicamos el área donde
        ; dejar la información
        mov bx, Buffer
        ; función de lectura
        mov ah, 2
        
        ; intentamos leer
        int 13h
        ; si se produce un error
        ; volver a intentarlo
        jc Try
        
        ; Ponemos en BX el manejador
        ; del archivo
        mov bx, [Manejador]
        ; Escribir los bytes de 
        ; 18 sectores
        mov cx,18*512
        ; dirección donde están los datos
        mov dx, Buffer
        ; función de escritura en archivo
        mov ah, 40h
        int 21h ; guardamos la pista
        
        ; pasamos a la siguiente pista
        inc byte [Pista]
        ; si no es la 80
        cmp byte [Pista], 80
        ; continuar con la siguiente
        jne Bucle
        
        ; Volvemos a la primera pista
        mov byte [Pista], 0
        
        ; pasamos a la siguiente cara
        inc byte [Cara]
        ; ¿se han leído las dos caras?
        cmp byte [Cara], 2
        ; de no ser así seguir leyendo
        jne Bucle
        
        ; hemos terminado de leer
        ; el disquete
        
        ; Cerramos el archivo
        mov bx, [Manejador]
        mov ah, 3Eh
        int 21h
        
Destino:
        ; mostramos el mensaje que solicita
        ; la inserción del disco de destino        
        mov si, MEN2
        call IMPRIME
        
        ; esperamos la pulsación de una tecla
        xor ah, ah
        int 16h
        
        ; eliminamos lo último escrito en pantalla
        mov byte [Vacia], 3
        mov si, Vacia
        call IMPRIME
        
        ; mostrar el mensaje de que
        ; está escribiéndose
        mov si, MEN6
        call IMPRIME
        
        ; abrimos el archivo donde se
        ; guardó la información
        xor al, al
        mov ah, 3Dh
        mov dx, Archivo
        int 21h
        
        ; comenzar a escribir desde la
        ; cara 0 y pista 0
        mov byte [Cara], 0
        mov byte [Pista], 0
        
Bucle1:
        ; Introducir en la cadena Info los
        ; valores de Cara y Pista debidamente
        ; convertidos a cadena
        mov di, Info+9
        mov al, [Cara]
        inc al
        xor ah, ah
        call EnteroCadena
        
        mov di, Info+23
        mov al, [Pista]
        inc al
        xor ah, ah
        call EnteroCadena
        
        ; mostramos la línea informativa
        mov si, Info
        call IMPRIME
        
        ; Leemos una pista desde el archivo
        ; en el que se guardó
        mov bx, [Manejador]
        mov cx, 18*512
        ; dejando la información en Buffer
        mov dx, Buffer
        mov ah, 3Fh
        int 21h
        
Try1:
        ; Unidad 0 (A)
        xor dl, dl
        ; En DH la cara
        mov dh, [Cara]
        ; y en CH la pista
        mov ch, [Pista]
        ; escribir a partir del sector 1
        mov cl, 1
        ; 18 sectores
        mov al, 18
        ; tomando la información que
        ; acaba de leerse del archivo
        mov bx, Buffer
        mov ah, 3
        
        ; escribimos
        int 13h
        ; reintentando si hay error
        jc Try1
        
        ; incrementamos la pista
        inc byte [Pista]
        ; ¿hemos llegado a la última?
        cmp byte [Pista], 80
        ; de no ser así continuar
        jne Bucle1
        
        ; volver a la primera pista
        mov byte [Pista], 0
        
        ; pasar a la cara siguiente
        inc byte [Cara]
        ; ¿se han escrito las dos caras?
        cmp byte [Cara], 2
        ; de no ser así continuar
        jne Bucle1
        
        ; Hemos terminado
        
        ; Cerramos el archivo
        mov bx, [Manejador]
        mov ah, 3Eh
        int 21h
        
Respuesta:
        ; Preguntar si se desea otra
        ; copia del mismo disco
        mov si, MEN3
        call IMPRIME
        
        ; colocamos el cursor
        mov ah, 2
        xor bh, bh
        mov dl, 35
        mov dh, 10
        int 10h
        
        ; esperamos la respuesta
        xor ah, ah
        int 16h
        
        ; y la guardamos en la pila
        push ax
        
        ; borramos el mensaje de pregunta
        mov byte [Vacia], 10
        mov si, Vacia
        call IMPRIME
        
        ; recuperamos la respuesta
        pop ax
        ; y la convertimos a mayúscula
        and al, 11011111b
        
        ; si no desea otra copia
        cmp al, 'N'
        ; saltar a la etiqueta otra
        je Otra
        
        ; si desea otra copia
        cmp al, 'S'
        ; saltar a Destino
        je Destino
        
        ; repetir la pregunta
        jmp Respuesta
        
Otra:
        ; Preguntar si se desea
        ; copiar otro disco
        mov si, MEN4
        call IMPRIME
        
        ; colocamos el cursor
        mov ah, 2
        xor bh, bh
        mov dl, 35
        mov dh, 10
        int 10h
        
        ; esperar la respuesta
        xor ah, ah
        int 16h                                
        
        ; la guardamos en la pila
        push ax
        
        ; eliminamos la pregunta
        ; de la pantalla
        mov si, Vacia
        call IMPRIME
        
        ; recuperamos
        pop ax
        ; y convertimos a mayúscula
        and al, 11011111b
        
        ; si no se desea copiar más
        cmp al, 'N'
        ; terminar el programa
        je Salir
        
        ; si quiere otra copia
        cmp al, 's'
        ; saltar al principio
        je Inicio
      
        ; repetir la pregunta
        jmp Otra
          
Salir:        
        ; devolvemos el control
        ; al sistema
        mov ah, 4Ch
        int 21h
        
%include "Borra.inc"
%include "Imprime.inc"
%include "Convert.inc"
        