; Macro para calcular la posición
; de memoria correspondiente a 
; una cierta columna y fila
%define Posicion(x,y) y*160+x*2

        segment Pila stack
          resw 512
FinPila:          

        ; Segmento de código
        segment Codigo

..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; ES y DS apuntarán
        ; a la pantalla
        mov ax, 0b800h
        mov ds, ax
        mov es, ax

        ; establecemos en SI
        ; la línea de inicio
        mov si, Posicion(0,2)
        ; y en DI la de fin
        mov di, Posicion(0,15)
        
        ; número de caracteres
        mov cx, 80 ; acopiar
        cld
        
        ; copiamos
        rep movsw

        ; salimos al sistema
        mov ah, 4ch
        int 21h        
