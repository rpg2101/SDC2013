        segment Pila stack
          resb 256

       ; Segmento de datos
       segment Datos
Multiplicando dw 3 ; Multiplicaremos
Multiplicador dw 5 ; 3 por 5
Dato dw 256 ; y hallaremos la raíz cuadrada de 256

; para almacenar los resultados
Resultado dw 0

        ; Segmento de código
        segment Codigo
..start:

        ; Hacemos que DS apunte al
        ; segmento de datos
        mov ax, Datos
        mov ds, ax
 
        ; introducimos en ST el primer
        ; operando de la multiplicación
        fild word [Multiplicando]
        
        ; y multiplicamos por el segundo
        fimul word [Multiplicador]
        
        ; extraemos el resultado de ST
        fistp word [Resultado]

        ; Introducimos en ST el Dato
        fild word  [Dato]        
        
        fsqrt ; para hallar su raíz cuadrada
        
        ; recuperamos el resultado
        fistp word [Resultado]
        
        ; salimos al sistema
        mov ah, 4ch
        int 21h

