        segment Datos
; Reservamos espacio para poder
; guardar el contenido de la pantalla
Pantalla resb 25*80*2

        segment Pila stack
          resw 512
FinPila:          

        ; Segmento de c�digo
        segment Codigo
..start:

        ; Preparamos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; Guardamos el contenido
        ; de la pantalla
        call GuardaPantalla
        
        ; establecemos la primera fila
        ; y columna
        mov dl, 2
        mov dh, 10
        
        ; vamos a repetir 15 veces
        mov cx, 15

Movimiento:
        ; recuperamos la pantalla
        call RecuperaPantalla
        ; y dibujamos el recuadro
        call DibujaRecuadro
        
        ; guardamos el contador
        push cx
        
        ; esperamos 2 segundos
        mov cx, 2
        call Espera
        
        ; recuperamos el contador
        pop cx
        
        ; actualizamos la posici�n
        inc dl
        inc dh
        inc dh
        
        ; repetimos
        loop Movimiento

        ; restauramos el contenido de la pantalla
        call RecuperaPantalla        
        
Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h


;----------------------------
; Procedimiento para guardar
; el contenido de la pantalla
; en la variable Pantalla
;----------------------------
GuardaPantalla:
       pusha ; conservamos los registros
       push ds
       push es
       
        ; DS:SI apunta a la pantalla
        mov ax, 0b800h
        mov ds, ax
        xor si, si
        
        ; ES:DI apunta a nuestra variable
        mov ax, Datos
        mov es, ax
        mov di, Pantalla
        
        ; copiamos el origen
        ; en el destino
        mov cx, 2000
        cld
        rep movsw
        
        ; restaurar registros
        pop es
        pop ds
        popa
        
        ; y devolvemos el control
        ret
        
;----------------------------
; Procedimiento para retaurar
; el contenido de la pantalla
; desde la variable Pantalla
;----------------------------
RecuperaPantalla:
        pusha ; guardar registros
        push ds
        push es
        
        ; DS:SI apunta a la variable
        mov ax, Datos
        mov ds, ax
        mov si, Pantalla
        
        ; ES:DI apunta a la pantalla
        mov ax, 0b800h
        mov es, ax
        xor di, di
        
        ; efectuamos la transferencia
        call TransfiereDatos
        
        ; restaurar registros
        pop es
        pop ds
        popa
        
        ; y devolvemos el control
        ret

;----------------------------
; Procedimiento que efect�a 
; la transferencia de datos
;----------------------------
TransfiereDatos:
        ; Vamos a copiar 4000 bytes
        mov cx, 4000
        cld ; incrementar autom�ticamente SI y DI
        
 Bucle0:
        ; movemos el contenido de la celdilla
        ; apuntada por SI a la que indica DI
        movsb 
        loop Bucle0 ; repetir
        
        ret ; devolvemos el control
        
;----------------------------
; Procedimiento que dibuja el
; cuadrado en pantalla
;
; Espera recibir en DL,DH la
; posici�n en que debe ponerlo
;----------------------------
DibujaRecuadro:
        pusha ; guardamos registros
        push ds
        
        ; DS apuntar� al segmento
        ; de pantalla
        mov ax, 0b800h
        mov ds, ax
        
        mov cx, 8 ; n�mero de l�neas
        
BucleLineas:
        push dx ; guardamos la posici�n

        ; guardamos CX en la pila
        push cx
        
        mov cx, 20 ; n�mero de columnas
        
BucleColumnas:
         ; Calculamos la posici�n
         mov al, 160 ; bytes por l�nea
         mul dl ; por n�mero de l�nea
         
         mov bx, ax ; guardamos en BX
         
         mov al, 2 ; bytes por columna
         mul dh ; por n�mero de columna
         
         add bx, ax ; sumamos a bx
         
         ; ponemos un car�cter en esa posici�n
         mov word [bx], 070feh
         
         inc dh ; incrementamos la columna
         
         loop BucleColumnas ; y repetimos
         
         ; al finalizar todas las columnas
         ; de una l�nea
         
         pop cx ; recuperamos contador l�neas

         pop dx ; recuperamos la posici�n         
         inc dl ; y pasamos a l�nea siguiente
         
         loop BucleLineas ; y repetimos

         pop ds ; recuperamos registros
         popa 
         
         ret ; volvemos
         
;----------------------------
; Procedimiento que provoca
; una espera de N segundos
;
; Espera recibir en CX el 
; n�mero de segundos
;----------------------------
Espera:
         pusha ; guardar registros

         ; obtenemos el n�mero
         ; de minutos y segundos que
         ; indica el reloj ahora         
         call SegundosActual
         ; lo movemos a BX
         mov ax, bx
         ; y le sumamos los segundos
         ; a esperar
         add ax, cx
         
Bucle1:
         ; vigilamos los minutos y
         ; segundos del reloj
         call SegundosActual
         ; viendo si ya se ha completado
         ; la espera
         cmp ax, bx
         ; volviendo al bucle
         ; de no ser as�
         ja Bucle1
         
         popa ; recuperamos registros
         ret ; y volvemos
         
;----------------------------
; Procedimiento que obtiene
; los minutos y segundos del
; reloj, los convierte a 
; segundos y devuelve en BX 
;----------------------------
SegundosActual:
         push ax ; guardamos AX
         
         ; queremos leer los minutos
         mov al, 2
         out 70h, al
         in al, 71h
         
         ; los multiplicamos por 60
         mov bl, 60
         mul bl
         
         ; y guardamos en BX
         mov bx, ax
         
         ; queremos leer los segundos
         xor al, al
         out 70h, al
         in al, 71h
         
         ; los sumamos
         xor ah, ah
         add bx, ax
         
         pop ax ; y volvemos
         ret
