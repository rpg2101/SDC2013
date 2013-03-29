;---------------------------------
; Rutina de impresión por pantalla
;
; Al invocar a esta rutina DS:SI
; deben contener la dirección de
; una cadena de bytes con la
; estructura siguiente:
;
;   Línea,Columna,Color,"Texto",0
;----------------------------------

IMPRIME:
     ; recogemos la línea en DH
     mov dh, [si]
     inc si ; apuntar al dato siguiente
     ; recoger la columna en DL
     mov dl, [si]
     
     ; posicionamos el cursor
     mov ah, 2
     xor bh, bh ; página 0
     int 10h
     
     inc si  ; pasar al siguiente dato
     ; recoger el color en BL
     mov bl, [si]
     ; apuntar al primer byte de texto
     inc si
     xor bh, bh ; trabajar en página 0
     
IMP_BUCLE:
     ; recoger el carácter apuntado por SI
     mov al, [si]
     ; comprobar si es el final
     or al, al
     ; de ser así saltar
     jz IMP_FIN
     
     ; en caso contrario imprimirlo
     mov cx, 1
     mov ah, 9
     int 10h
     
     ; pasar al siguiente carácter
     inc si
     
     ; leemos la posición actual
     ; del cursor
     mov ah, 3
     int 10
     ; incrementamos la columa
     inc dl
     ; y recolocamos el cursor
     mov ah, 2
     int 10h
     
     ; repetir
     jmp IMP_BUCLE
     
IMP_FIN:
     ; cuando se termine la cadena
     ret ; volver          
