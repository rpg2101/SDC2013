        segment Datos

Pantalla resb 25*80*2

        segment Pila stack
          resb 64
FinPila:          

        ; Segmento de código
        segment Codigo
..start:

        ; Preparamos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; DS:SI apunta a la pantalla
        mov ax, 0b800h
        mov ds, ax
        xor si, si
        
        ; ES:DI apunta a nuestra variable
        mov ax, Datos
        mov es, ax
        mov di, Pantalla
        
        ; Vamos a copiar 4000 bytes
        mov cx, 4000
        cld ; incrementar automáticamente SI y DI
        
Guarda:
        ; movemos el contenido de la celdilla
        ; apuntada por SI a la que indica DI
        movsb 
        loop Guarda ; repetir
        
        ; Llenamos la pantalla de asteriscos
        
        mov cx, 2000 ; 2000 caracteres
        xor bx, bx   ; desde el principio de pantalla
        mov al, '*'  ; asteriscos
        mov ah, 70h  ; en vídeo inverso
        
Llena:
        mov [bx], ax ; introducimos carácter y atributo
        inc bx       ; pasamos a la posición siguiente
        inc bx
        loop Llena   ; y repetimos hasta el final
        
        xor cx, cx   ; Ponemos CX a cero
Espera:
        loop Espera  ; para repetir 65536 veces
        
        ; esperamos la pulsación de una tecla
        xor ah, ah
        int 16h
        
        ; Invertimos ES y DS
        mov ax, ds
        mov bx, es
        mov ds, bx
        mov es, ax
        
        ; preparamos los índices
        xor di, di
        mov si, Pantalla
        
        ; para restaurar 4000 bytes
        mov cx, 4000
        
Restaura:
        movsb
        loop Restaura
        
Salir:
        ; salimos al sistema
        mov ah, 4ch
        int 21h
