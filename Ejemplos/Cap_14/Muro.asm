;--------------------------------
; Esta macro coloca el cursor 
; en el punto indicado sin
; modificar registros
;--------------------------------
%macro PosicionCursor 0
        push ax ; guardar AX
        push bx ; y BX
        
        ; Ponemos el cursor en la
        ; posición indicada
        xor bh, bh
        mov ah, 2
        int 10h
        
        ; restauramos registros
        pop bx
        pop ax
%endmacro        

;--------------------------------
; Esta macro escribe el carácter
; indicada en la posición actual
;--------------------------------
%macro EscribeCaracter 2
        push ax ; guardamos
        push bx ; registros
        push cx
        
        ; establecemos 
        ; carácter y atributo
        mov bl, 7
        mov al, %1
        xor bh, bh
        mov cx, %2
        
        ; escribimos el carácter
        mov ah, 9
        int 10h
        
        ; recuperamos registros
        pop cx
        pop bx
        pop ax
%endmacro        

; Constantes con los caracteres
Pelota equ 'O'
Pala   equ 196

        segment Pila stack
          resw 512
FinPila:

        segment Datos
; Número máximo de pelotas        
Mensaje    db 'Quedan '                      
NumPelotas db '3'
           db ' pelotas$'
           
        ; Segmento de código
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; DS y ES apuntan al segmento
        ; que contiene los datos
        mov ax, Datos
        mov ds, ax
        mov es, ax

        ; limpiamos la pantalla
        call LimpiaPantalla

        ; nos situamos en la esquina
        ; superior derecha
        mov dl, 60
        xor dh, dh
        PosicionCursor
        
        ; y mostramos el mensaje
        mov dx, Mensaje
        mov ah, 9
        int 21h
        
        ; Bucle principal del programa
BuclePrincipal:   
        ; ponemos la pala en pantalla

        ; obtenemos una columna aleatoria     
        ; para la salida de la pelota
        call PosicionAleatoria

        ; colocamos el cursor
        mov dh, 24
        PosicionCursor
        
        ; y mostramos la pala
        EscribeCaracter Pala, 3
        
        ; la pelota partirá de la fila 1
        mov dh, 1
        
        ; factor de movimiento
        ; inicial para columna y fila
        mov cl, 1
        mov ch, 1
        
        ; posición inicial
        ; de la pala
        mov bl, dl
        mov bh, 24
        
BucleMovimiento:
        ; Examina el teclado
        call ExaminaTeclado
        jc Fin ; saltar si se pulsa ESC
        
        ; ActualizaPala
        call ActualizaPala

        ; colocamos el cursor
        PosicionCursor
        
        ; y mostramos la pelota
        EscribeCaracter Pelota, 1
        
        ; Examina el teclado
        call ExaminaTeclado
        jc Fin ; saltar si se pulsa ESC
        
        ; ActualizaPala
        call ActualizaPala

        ; Esperamos una fracción 
        ; de segundos
        call Espera 
        
        ; Examina el teclado
        call ExaminaTeclado
        jc Fin ; saltar si se pulsa ESC
        
        ; ActualizaPala
        call ActualizaPala

        ; eliminamos la pelota
        PosicionCursor
        EscribeCaracter ' ', 1
        
        ; Actualizamos la posición
        call ActualizaPelota
        ; si se ha salido saltar
        jc SiguientePelota
        
        jmp BucleMovimiento ; continuar
        
        ; La pelota se ha salido por
        ; la parte inferior
SiguientePelota:          
        ; reducimos el número de pelotas 
        dec byte [NumPelotas]

        push dx ; guardamos posición
                
        ; limpiamos la pantalla
        call LimpiaPantalla

        ; nos situamos en la esquina
        ; superior derecha
        mov dl, 60
        xor dh, dh
        PosicionCursor
        
        ; y mostramos el mensaje
        mov dx, Mensaje
        mov ah, 9
        int 21h
        
        pop dx ; recuperamos posición
        
        ; comprobamos si es '0'
        cmp byte [NumPelotas], '0'
        ; si no es cero continuamos
        jnz BuclePrincipal     
        
Fin:
        ; Salimos al sistema
        mov ah, 4ch
        int 21h

;-------------------------------
; Esta rutina se encargará de
; actualizar la posición de la
; pelota en pantalla.
;
; La posición actual es DL,DH
; Los desplazamientos están en CL,CH
;-------------------------------
ActualizaPelota:
        ; incrementamos las coordenadas
        add dl, cl
        add dh, ch
        
        ; comprobamos si estamos
        ; en la columna 79
        cmp dl, 79
        ; de no ser así saltar
        jne NoCol79
        
        ; en caso contrario
        mov cl, -1
        
NoCol79:        
        ; comprobar si estamos
        ; en la columna 0
        or dl, dl
        ; de no ser así saltar
        jne NoCol0
        
        ; en caso contrario
        mov cl, 1
NoCol0:
        ; comprobamos si estamos
        ; en la línea 23
        cmp dh, 23
        ; de no ser así saltar
        jne NoLin23
        
        ; en caso contrario
        ; comprobar si la pala
        ; está justo debajo
        cmp bl, dl
        ja SeFue
        
        ; la pala tiene 3
        ; caracteres de ancho
        add bl, 2
        cmp bl, dl
        jb SeFue
        
        sub bl, 2
        
        ; rebota
        mov ch, -1
        ret
        
SeFue:        
        stc ; activar carry
        ret ; y volver
        
NoLin23:        
        ; comprobar si estamos
        ; en la línea 1
        cmp dh, 1
        ; de no ser así saltar
        jne NoLin1
        
        ; en caso contrario
        mov ch, 1
NoLin1:
        ret ; volver

;--------------------------------
; Esta rutina examina el teclado 
; para ver si hay alguna tecla
; pulsada
;---------------------------------       
ExaminaTeclado:
        ; comprobamos si hay 
        ; alguna tecla pulsada
        mov ah, 1
        int 16h

        ; Si Z está a 1 es que no
        jz NoHayTeclas
        
        ; de haberla la extraemos
        xor ah, ah
        int 16h
        
        ; comprobar si es Esc
        cmp al, 27
        ; de no ser así saltar
        jne NoEsESC
        
        ; en caso contrario
        ; activar el carry
        stc
        
        ret ; y volver
        
NoHayTeclas:
        xor ax, ax    
            
NoEsESC:        
        clc ; poner a 0 el carry
        ret ; volver

;----------------------------------
; Esta rutina actualiza la posición
; de la pala según la tecla pulsada
;----------------------------------
ActualizaPala:
         ; ver si se ha pulsado
         cmp ah, 75
         ; el cursor a izquierda
         je Izquierda
         
         ; o el cursor a derecha
         cmp ah, 77
         je Derecha

Volver:
         ret ; volver
         
Izquierda:
         ; si estamos en la columna 0
         or bl, bl
         jz Volver
         
         ; en caso contrario quitar
         ; de la posición actual
         xchg dl, bl
         xchg dh, bh
         PosicionCursor
         EscribeCaracter ' ', 3
         
         ; y reducir la columna
         dec dl
         
         ; para volver a mostrar
         PosicionCursor
         EscribeCaracter Pala, 3

         ; dejar los registros
         ; como estaban
         xchg dl, bl
         xchg dh, bh
         
         ret ; y volver

Derecha: 
         ; si estamos en la columna 77
         cmp al, 77
         jz Volver
         
         ; en caso contrario quitar
         ; de la posición actual
         xchg dl, bl
         xchg dh, bh
         PosicionCursor
         EscribeCaracter ' ', 3

         ; e incrementar
         inc dl
         
         ; para volver a mostrar
         PosicionCursor
         EscribeCaracter Pala, 3

         ; dejar los registros
         ; como estaban
         xchg dl, bl
         xchg dh, bh

         ret ; y volver        

;---------------------------
; Esta rutina limpia la 
; pantalla
;---------------------------
LimpiaPantalla:
        xor dx, dx
        PosicionCursor        
        ; establecemos 
        ; carácter y atributo
        mov bl, 7
        mov al, ' '
        xor bh, bh
        mov cx, 2000
        
        ; escribimos el carácter
        mov ah, 9
        int 10h
        
        ret ; volvemos

;------------------------------
; Esta rutina devuelve una 
; posición horizontal pseudo-aleatoria
; en el registro DL
;------------------------------
PosicionAleatoria:
         ; obtenemos el número 
         ; actual de segundos
         call SegundosActual
         
         ; llevamos a ax
         mov ax, bx
         ; y dividimos entre 80
         mov bl, 80
         div bl
         
         ; en AH tenemos un resto
         ; entre 0 y 79
         mov dl, ah
         
         ret ; volvemos
                
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

;-----------------------------
; Rutina que espera una fracción
; de segundo         
;-----------------------------
Espera:
         pusha ; guardar registros
         
         ; leer número de pulsos
         xor ah, ah
         int 1Ah
         
         ; copiar en BX
         mov bx, dx
         add bx, 2 ; e incrementar
BucleE0:
         ; esperar hasta que 
         ; haya transcurrido
         int 1Ah
         cmp bx, dx
         
         ja BucleE0
         
         popa ; recuperar
         
         ret ; y volver
                        