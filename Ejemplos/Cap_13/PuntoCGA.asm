        segment Pila stack
          resw 512
FinPila:

        ; Segmento de c�digo
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; activamos el modo 4
        ; 320x200 puntos
        mov al, 4
        xor ah, ah
        int 10h
        
        ; vamos a dibujar la
        ; primera l�nea en
        ; la posici�n vertical 75
        mov dx, 75
        ; con el color 1
        mov al, 1
        ; en la p�gina 0
        xor bh, bh
        ; preparamos el servicio
        mov ah, 0Ch
        
        ; dibujaremos tres l�neas
        mov cx, 3
        
Bucle0:
        ; guardamos el contador
        ; del bucle
        push cx    
        
        ; para establecer la 
        ; posici�n horizontal    
        mov cx, 200
Bucle1:
        ; dibujamos un punto
        int 10h
        ; y repetimos hacia atr�s
        loop Bucle1
      
        ; incrementamos la
        ; posici�n vertical
        add dx, 50
        ; y el color
        inc al
        
        ; recuperamos el contador
        ; del bucle y repetimos
        pop cx
        loop Bucle0
        
        ; esperamos la pulsaci�n
        ; de una tecla
        xor ah, ah
        int 16h
        
        call AlternaPaleta
        
        ; volvemos al modo
        ; de v�deo de texto
        mov al, 3
        xor ah, ah
        int 10h
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h

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
         
BucleEspera:
         ; vigilamos los minutos y
         ; segundos del reloj
         call SegundosActual
         ; viendo si ya se ha completado
         ; la espera
         cmp ax, bx
         ; volviendo al bucle
         ; de no ser as�
         ja BucleEspera
         
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

;---------------------------
; Esta rutina, asumiendo que
; nos encontramos en el modo
; de 320x200 con 4 colores,
; alterna la paleta actual
; varias veces con una pausa
; entre cambios.
;---------------------------
AlternaPaleta:
         ; n�mero del servicio
         mov ah, 0Bh
         ; BH debe tener 1
         mov bh, 1
         
         ; alternaremos entre
         ; las paletas 1 y 0
         mov bl, 1
         xor dl, dl
         
         ; 10 veces
         mov cx, 10
         
BuclePaleta:
         ; establecemos la paleta
         int 10h
         
         ; guardamos el contador
         push cx
         ; establecemos 1 segundo
         mov cx, 1
         ; de espera
         call Espera
         
         ; intercambiamos paleta
         xchg dl, bl
         
         ; recuperamos contador
         pop cx
         ; y repetimos
         loop BuclePaleta
         
         ret ; volver