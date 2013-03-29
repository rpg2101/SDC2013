        segment Pila stack
          resw 512
FinPila:

        segment Datos
; Las variables siguientes se tomarán
; como una sola a la hora de imprimir
; ya que sólo hay un indicador de fin
Cadena   db 'C¢digo de b£squeda: '
Busqueda db '123'
         db ' - C¢digo ASCII: '
ASCII    db '123'
         db 13, 10, '$'
                                 
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

        ; situamos el cursor
        ; al inicio de la 
        ; pantalla para borrarla
        xor dx, dx
        mov ah, 2
        int 10h
        
        ; introducimos 2000
        ; espacios en blanco
        mov bl, 7
        mov al, ' '
        xor bh, bh
        mov cx, 2000
        mov ah, 9
        int 10h
        
Bucle:
        ; Eliminamos el contenido de
        ; Busqueda y ASCII para 
        ; recoger los códigos
        call Limpia
        
        ; esperamos una tecla
        mov ah, 10h
        int 16h
        
        ; ¿Es Escape?
        cmp al, 27
        ; Si no es así saltar
        jne Procede        

        ; Salimos al sistema
        mov ah, 4ch
        int 21h

Procede:
        ; convertimos los
        ; códigos
        call Conver
        
        ; Ponemos el cursor en la
        ; línea 11 y columna 15
        mov dl, 15
        mov dh, 11
        mov ah, 2
        int 10h
        
        ; mostramos la cadena
        ; con los códigos
        mov dx, Cadena
        mov ah, 9
        int 21h
        
        ; repetimos el proceso
        jmp Bucle
        
;------------------------------
; Esta rutina tiene la finalidad
; de limpiar las dos partes
; variables del texto a imprimir
;------------------------------
Limpia:
        ; ES:DI apunta a Busqueda
        mov di, Busqueda
        ; introducimos tres espacios
        mov al, ' '
        mov cx, 3
        rep stosb
        
        ; lo mismo para la 
        ; variable ASCII
        mov di, ASCII
        mov cx, 3
        rep stosb
        
        ret ; volver
        
;------------------------------------
; Esta rutina convertirá el contenido
; de AX en dos cifras decimales y las
; almacenará en sus correspondientes
; posiciones. Se sirve de la rutina
; Con1 que se encarga de convertir AH
; en una cadena ASCII decimal
;-------------------------------------
Conver:
        push ax ; guardamos AX
        
        ; ES:DI apunta a Busqueda
        mov di, Busqueda        
        
        call Con1 ; convertimos
        
        pop ax ; recupera los códigos
        ; para convertir AL
        mov ah, al
        
        ; y almacenarlo en ASCII
        mov di, ASCII
        
        ; convertir
        call Con1
        
        ret ; volver
        
;-----------------------------------
; Esta rutina recibirá un valor a 
; convertir en AH y una dirección 
; de destino en ES:DI
;-----------------------------------
Con1:
        ; ¿Es AH menor que 100?
        cmp ah, 100
        ; si es así salta
        jb Salto1        
        
        ; en caso contrario dividir
        ; entre 100
        mov al, ah
        mov bl, 100
        xor ah, ah
        ; el resultado serán
        ; las centenas
        div bl
        
        ; convertirlo a ASCII
        add al, '0'
        ; y almacenarlo
        stosb
        
        xor al, al ; borrar AL
        
Salto1:
        ; ¿Es AH menor de 10?
        cmp ah, 10
        ; si es así salta
        jb Salto0
        
        ; en caso contrario
        ; dividir entre 10
        mov al, ah
        mov bl, 10
        xor ah, ah
        ; el resultado serán
        ; las decenas
        div bl
        
        ; convertirlo en ASCII
        add al, '0'
        ; y almacenarlo
        stosb
        
        xor al, al ; borrar AL
        jmp Salto2 ; y saltar
        
Salto0:
        ; aquí se llega si no 
        ; había decenas, por
        ; lo que almacenamos
        ; un 0 en esa posición
        mov al, '0'
        stosb
        
Salto2:
        ; Lo que queda en AH, tras
        ; las anteriores divisiones,
        ; son las unidades
        mov al, ah
        ; convertir en ASCII
        add al, '0'
        ; y almacenarlo
        stosb
        
        ret ; volver        