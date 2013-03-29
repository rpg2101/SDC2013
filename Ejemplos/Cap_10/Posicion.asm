; Macro para calcular la posición
; de memoria correspondiente a 
; una cierta columna y fila
%define Posicion(x,y) y*160+x*2

%macro MuestraCaracter 4
  mov bx, %1*2+%2*160
  mov byte [bx], %3
  inc bx
  mov byte [bx], %4
%endmacro

        segment Pila stack
          resw 512
FinPila:          

        ; Segmento de código
        segment Codigo

..start:
        ; DS apuntará a la pantalla
        mov ax, 0b800h
        mov ds, ax

        MuestraCaracter 40, 10, 'A', 70h
        MuestraCaracter 40, 15, '*', 60h        

        ; salimos al sistema
        mov ah, 4ch
        int 21h        
