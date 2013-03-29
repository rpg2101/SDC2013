        segment Pila stack
          resb 256

        ; Segmento de código
        segment Codigo
..start:

        mov al, 5
        add al,7
        aaa ; ajuste BCD no empaquetado
        
        mov ax, 0 ; Poner AX a 0
        
        mov al, 5
        add al, 7
        daa ; ajuste BCD empaquetado

        mov ax, 165h
        add ax, 43h
        daa
        adc ah,0
        
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

