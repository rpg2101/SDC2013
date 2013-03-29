;-----------------------------------
; La finalidad de esta rutina es
; facilitar la introducción de datos
;
; Al llamarla DS:SI deben apuntar a
; un descriptor con la siguiente
; estructura:
;
;  Línea,Columna,Color,Longitud,Buffer
;-----------------------------------
PETICION:
     ; llamar a la rutina LIMPIA
     call LIMPIA
     
     ; lleva la dirección de 
     ; descriptor a BX
     mov bx, si
     ; y hacer que SI apunte
     ; al buffer de almacenamiento
     mov si, 4
     
     ; guardamos la dirección
     ; del descriptor del dato
     push bx
     
     ; recogemos la línea
     mov dh, [bx]
     ; y la columna
     mov dl, [bx+1]
     xor bh, bh ; página 0
     ; colocamos el cursor
     mov ah, 2
     int 10h
     
     ; recuperamos la dirección
     ; del descriptor
     pop bx
     
BUC_PET1:
     ; esperamos la pulsación
     ; de una tecla
     xor ah, ah
     int 16h
     
     ; ¿se pulsó Intro?
     cmp al, 13
     ; de ser así saltar
     je FIN_PET
     
     ; ¿se pulsó la tecla de retroceso?
     cmp al, 8
     ; si no es así saltar
     jne SALT_PET1
     
     ; Se ha pulsado la tecla
     ; de retroceso
     
     ; Ver si estamos al principio
     ; del dato
     cmp si, 4
     ; de ser así ignoramos la pulsación
     jle BUC_PET1
     
     ; en caso contrario retrocedemos
     ; reduciendo el puntero
     dec si
     
     ; guardamos la dirección
     ; del descriptor
     push bx
     
     ; leemos la posición actual
     ; del cursor en pantalla
     mov ah, 3
     xor bh, bh
     int 10
     
     ; hacemos retroceder el cursor
     dec dl
     mov ah, 2
     int 10h
     
     ; recuperamos la dirección
     ; del descriptor
     pop bx
     
     ; continuamos con la petición
     jmp BUC_PET1     
     
SALT_PET1: ; No se ha pulsado Intro ni retroceso

     ; ¿es la flecha hacia arriba?
     cmp ax, 4800h
     ; en caso afirmativo salta
     je ARRIBA
     
     ; comparar la tecla con el código 31
     cmp al, 31
     ; si es menor o igual ignorarlo
     jle BUC_PET1
     
     ; comparar la tecla con el código 123
     cmp al, 123
     ; si es mayor o igual ignorarlo
     jge BUC_PET1
     
     ; comparar con el código 96
     cmp al, 96
     ; si es menor o igual saltar
     jle SALT_PET
     
     ; en caso contrario es una letra
     ; minúscula y la convertimos
     ; a mayúscula
     and al, 11011111b
     
SALT_PET:
     ; Si es un carácter válido introducirlo
     ; en el buffer.
     ; BX contiene la dirección de inicio
     ; del descriptor y SI el número de
     ; carácter pulsado más 4, que es el 
     ; comienzo del buffer dentro del descriptor
     mov [bx+si],al
     
     ; guardamos la dirección
     ; del descriptor
     push bx
     
     ; tomamos el byte de color
     mov bl, [bx+2]
     xor bh, bh ; página 0
     mov cx, 1
     ; imprimimos el carácter
     ; que se ha pulsado
     mov ah, 9
     int 10h
     
     ; incrementamos SI, que apunta
     ; al siguiente byte del buffer
     inc si
     
     ; recuperamos la dirección
     ; del descriptor
     pop bx
     
     ; restamos 4 a SI para saber
     ; la longitud actual del dato
     sub si, 4
     
     ; leemos el byte de longitud
     ; del descriptor
     mov al, [bx+3]
     ; convertimos en palabra
     ; para poder comparar con SI
     xor ah, ah
     
     ; ver si ya tenemos el número
     ; de caracteres solicitado
     cmp ax, si
     ; de ser así saltar
     je FIN_PET
     
     ; en caso contrario volver
     ; a dar su valor a SI
     add si, 4
     
     ; guardar la dirección
     ; del descriptor
     push bx
     
     ; leemos la posición actual
     ; del cursor en pantalla
     mov ah, 3
     xor bh, bh
     int 10h
     
     ; incrementamos la columna
     inc dl
     
     ; y volvemos a colocarlo
     mov ah, 2
     int 10h
     
     ; recuperamos el descriptor
     pop bx
     
     ; y continuamos pidiendo caracteres
     jmp BUC_PET1
     
ARRIBA:
     ; si se pulsó la tecla del cursor
     ; hacia arriba devolver un 1 en AL
     ; para notificarlo
     mov al, 1
     
     ; y terminar
     ret
     
FIN_PET:
     ; si se ha terminado por la pulsación
     ; de Intro o al llegar a la longitud
     ; máxima, damos 0 a AL
     xor al, al
     
     ret ; volver
     
;-------------------------------
; Esta rutina se encarga de 
; preparar el dato que va a
; pedirse
;-------------------------------
LIMPIA:
     ; tomar la dirección del dato en DI
     mov di, si
     ; DS y ES apuntan al mismo segmento
     push ds
     pop es
     
     ; incrementar DI
     add di, 3
     ; para leer la longitud del dato
     mov cl, [di]
     ; ahora tenemos en CX la longitud
     xor ch, ch               
     
     ; hacer que DI apunte al
     ; primer carácter
     inc di
     
     cld ; autoincremento de DI
     mov al, ' ' ; llena con espacios
     rep stosb
     
     ret ; volver
     