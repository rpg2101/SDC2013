;--------------------------
; Esta rutina borra la 
; pantalla asumiendo que
; el modo siempre es el 3
;--------------------------        
BORRA:
     xor dx, dx ; ponemos el cursor
     mov ah, 2  ; al principio
     int 10h    ; de la pantalla
     
     mov cx, 2000 ; e imprimimos
     mov al, ' '  ; 2000 espacios
     xor bh, bh
     mov bl, 7
     mov ah, 9
     int 10h
     
     ret ; volver

