;--------------------------------
; Esta macro coloca el cursor 
; en el punto indicado sin
; modificar registros
;--------------------------------
%macro PosicionCursor 2
        push ax ; guardar AX
        push bx ; BX y DX
        push dx
        
        ; posición del cursor
        mov dl, %1
        mov dh, %2
        
        ; Ponemos el cursor en la
        ; posición indicada
        xor bh, bh
        mov ah, 2
        int 10h
        
        ; restauramos registros
        pop dx
        pop bx
        pop ax
%endmacro        

;--------------------------------
; Esta macro escribe el carácter
; indicado en la posición actual,
; tantas veces como diga el 
; segundo parámetro y con el 
; atributo del tercero
;--------------------------------
%macro EscribeCaracter 3
        push ax ; guardamos
        push bx ; registros
        push cx
        
        ; establecemos 
        ; carácter y atributo
        mov bl, %3
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

        ; Segmento de la pila
        segment Pila stack
          resw 512
FinPila:

        ; Segmento de datos
        segment Datos
        
; Constantes que representan
; los caracteteres para
; dibujar recuadros en 
; modo de texto        
EsqSI equ 218
EsqII equ 192
EsqSD equ 191
EsqID equ 217
Horz equ 196
Vert equ 179

; Constantes que identifican
; la posición de cada dato
; en la tabla siguiente        
PosX equ 0
PosY equ 1
Servicio equ 2
Mascara equ 3
Longitud equ 4
Texto equ 5

; Tamaño, en bytes, de cada
; elemento de la tabla siguiente  
TamanoTecla equ 15

; Tabla con 9 elementos, correspondientes
; a las 9 teclas a comprobar, conteniendo
; cada uno de ellos la posición X,Y donde
; se dibujará el recuadro, el servicio
; a usar, la máscara de bits a emplear
; para comprobar la tecla, la longitud del
; texto a mostrar y el texto propiamente dicho
Teclas db 5, 10, 2, 64, 10, 'Bloq May£s'
       db 7, 15, 2, 2, 5,   'May£s     '
       db 10, 20, 12h, 1, 7,  'Control   '
       db 20, 20, 12h, 2, 3,  'Alt       '
       db 50, 20, 12h, 8, 3,  'Alt       '
       db 60, 20, 12h, 4, 7,  'Control   '
       db 65, 15, 2, 1, 5,   'May£s     '
       db 45, 4, 2, 16, 10, 'Bloq Despl'
       db 63, 4, 2, 32, 8,  'Bloq N£m  '
        
Atributo db 0 ; para almacenar el atributo
                                 
        ; Segmento de código
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; DS apunta al segmento
        ; que contiene los datos
        mov ax, Datos
        mov ds, ax
        
        ; Limpiamos la pantalla
        call LimpiaPantalla
        
        ; y ocultamos el cursor
        ; para que no aparezca
        ; saltando por la pantalla
        call OcultaCursor

Bucle0: ; Bucle principal

        ; DS:BX apunta al primer
        ; elemento de la tabla
        mov bx, Teclas
        ; hay 9 elementos
        mov cx, 9        

Bucle1: ; Bucle que recorre los elementos

        ; Comprobamos si está pulsada
        ; la tecla del elemento 
        call CompruebaTecla
        
        ; dibujamos su marco
        call DibujaMarco
        
        ; e imprimimos su texto
        call ImprimeTexto
        
        ; pasar al siguiente 
        ; elemento de la tabla
        add bx, TamanoTecla    
      
        ; si se ha pulsado Esc
        call ExaminaTeclado
        ; terminamos
        jc Salir
        
        loop Bucle1 ; repetir
        
        ; cuando terminemos con los
        ; 9 elementos volver al
        ; principio
        jmp Bucle0
        
Salir:  ; al salir

        ; volvemos a mostrar el cursor
        call RestauraCursor
        
        ; devolver el control al sistema
        mov ah, 4ch
        int 21h        

;-------------------------------
; Esta rutina borra todo el 
; contenido de la pantalla
;-------------------------------
LimpiaPantalla:
        ; Ponemos el cursor en la
        ; esquina superior izquierda
        PosicionCursor 0, 0
        ; y escribimos 2000 espacios
        EscribeCaracter ' ', 2000, 7
                
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
        
      
;----------------------------
; Esta rutina comprueba si está
; pulsada o activa una cierta
; tecla.
; DS:BX apunta al elemento de
; la tabla cuya tecla hay que
; comprobar
;----------------------------      
CompruebaTecla:
        ; obtenemos el servicio
        mov ah, [bx+Servicio]
        int 16h ; y lo invocamos
        
        ; si el servicio no es el 12
        cmp byte [bx+Servicio], 12h
        jne Continua ; saltamos
        
        ; en caso contrario intercambiamos
        ; para quedarnos con los bits en AL
        xchg ah, al
        
Continua:        
        ; usamos la máscara para 
        ; comprobar el bit
        and al, [bx+Mascara]
        ; si está pulsada saltamos
        jnz Pulsada
        
        ; si no está pulsada dibujamos
        ; en blanco sobre negro
        mov byte [Atributo], 7
        
        ret ; volver
        
Pulsada:
        ; si la tecla está pulsada
        ; dibujamos en blanco sobre azul
        mov byte [Atributo], 1fh
        
        ret  ; volver

;-------------------------------
; Esta rutina dibujará el marco
; según los parámetros del 
; elemento apuntado por BX
;-------------------------------
DibujaMarco:
        pusha ; guardamos registros
        
        ; recuperamos la posición
        ; X,Y en AL,AH
        mov al, [bx+PosX]
        mov ah, [bx+PosY]
        ; el atributo en DL
        mov dl, [Atributo]
        ; y la longitud en CX
        mov cl, [bx+Longitud]
        xor ch, ch
        
        ; Nos ponemos en la esquina
        ; superior izquierda
        PosicionCursor al, ah
        ; y escribimos la esquina
        EscribeCaracter EsqSI, 1, dl
        
        ; pasamos a la línea siguiente
        inc ah
        ; para dibujar la línea vertical
        PosicionCursor al, ah
        EscribeCaracter Vert, 1, dl
        
        ; y a la siguiente
        inc ah
        ; para escribir la esquina inferior
        PosicionCursor al, ah
        EscribeCaracter EsqII, 1, dl
        
        ; pasamos a la siguiente columna
        inc al
        ; y dibujamos la linea
        ; horizontal inferior
        PosicionCursor al, ah
        EscribeCaracter Horz, cx, dl
        
        ; volvemos a la línea superior
        sub ah, 2
        ; para dibujar el otro borde
        PosicionCursor al, ah
        EscribeCaracter Horz, cx, dl
        
        ; nos vamos a la última
        ; columna del recuadro
        add al, cl
        ; para dibujar una esquina
        PosicionCursor al, ah
        EscribeCaracter EsqSD, 1, dl
        
        ; línea siguiente
        inc ah
        ; escribimos borde vertical
        PosicionCursor al, ah
        EscribeCaracter Vert, 1, dl
        
        ; y en la línea siguiente
        inc ah
        ; la esquina inferior derecha
        PosicionCursor al, ah
        EscribeCaracter EsqID, 1, dl
        
        popa ; recuperamos registros
        
        ret ; y volvemos
        
;-----------------------------
; Esta rutina imprime el texto
; del elemento apuntado por BX
;-----------------------------        
ImprimeTexto:
        pusha ; guardamos registros
        
        ; obtenemos columna
        mov dl, [bx+PosX]
        ; y la incrementamos
        inc dl
        ; obtenemos línea
        mov dh, [bx+PosY]
        ; y la incrementamos
        inc dh
        ; obtenemos longitud en CX
        mov cl, [bx+Longitud]
        xor ch, ch
        ; SI apuntará al texto
        mov si, bx
        add si, Texto
        ; tomamos el atributo en BL
        mov bl, [Atributo]
        
BucleI0: ; Bucle de escritura

        lodsb ; leemos un carácter
        ; colocamos el cursor
        PosicionCursor dl, dh
        ; y lo escribimos
        EscribeCaracter al, 1, bl
        
        ; pasamos a la siguiente columna
        inc dl
        loop BucleI0 ; y repetimos
        
        popa ; recuperamos registros
        
        ret ; volver
        
;-----------------------------               
; Esta rutina oculta el cursor
;-----------------------------        
OcultaCursor:
        ; activamos el bit 6
        ; de ch
        mov ch, 64
        xor cl, cl
        ; y usamos el servicio
        ; para definir el aspecto
        ; del cursor
        mov ah, 1
        int 10h
        
        ret ; volver
        
;-------------------------------
; Esta rutina restaura el cursor
;-------------------------------        
RestauraCursor:
        ; devolvemos la apariencia
        ; por defecto al cursor
        mov ch, 6
        mov cl, 7
        mov ah, 1
        int 10h
        
        ret ; volver
