        segment Pila stack
          resw 512
FinPila:

        segment Datos
Colores db 0 ; color negro
        db 8,1,9 ; tres azules
        db 16,2,18 ; tres verdes
        db 32,4,36 ; y tres rojos
        db 5,7,15,36,42,60 ; otros colores
        db 1 ; color del borde
                
        ; Segmento de c�digo
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; activamos el modo
        ; 640x350 con 16 colores
        mov al, 10h
        call EstableceModo
        
        ; vamos a trazar
        ; 16 l�neas
        mov cx, 16
Bucle0:
        ; calculamos la
        ; posici�n horizontal
        mov al,cl
        mov dl, 40
        mul dl 

        ; dejamos el resultado
        ; en DX        
        mov dx, ax       
        
        ; calculamos el color
        mov al, 16
        sub al, cl
        
        ; y dibujamos una l�nea
        call LineaVertical
        
        ; repetimos
        loop Bucle0
        
        ; esperamos la pulsaci�n
        ; de una tecla
        xor ah, ah
        int 16h
        
        ; alteramos la paleta
        ; de color
        call ModificaPaleta
        
        xor ah, ah
        int 16h ; esperamos tecla
        
        ; volvemos al modo
        ; de v�deo de texto
        mov al, 3
        call EstableceModo
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        
;-------------------------
; Esta rutina dibuja una
; l�nea vertical completa
; en la posici�n horizontal
; facilitada en DX y el 
; color indicado en AL
LineaVertical:    
        pusha ; guardamos registros
        
        ; vamos a dibujar la
        ; linea desde 0 a 350
        ; la posici�n vertical 75
        mov cx, 349
        ; en la p�gina 0
        xor bh, bh
        ; preparamos el servicio
        mov ah, 0Ch
        
BucleL0:
        ; El servicio espera las
        ; coordenadas en orden
        ; inverso
        xchg dx, cx
        
        ; dibujamos un punto
        int 10h
        
        ; volvemos a tener el
        ; contador en CX
        xchg dx, cx
        
        ; y repetimos hacia atr�s
        loop BucleL0

        ; recuperamos registros
        popa
        
        ret ; y volvemos      
        

;-------------------------
; Esta rutina establece el
; modo gr�fico deseado, que
; se facilitar� en AL
;-------------------------
EstableceModo:
        ; Ponemos AH a cero
        xor ah, ah
        ; y establecemos el modo
        int 10h
        
        ret ; volver

;---------------------------
; Esta rutina modifica los
; valores de los registros de
; paleta de color EGA
;---------------------------
ModificaPaleta:
         pusha ; guardar registros
         
         ; ES:DX apunta al �rea
         ; en que se han definido
         ; los colores
         mov ax, Datos
         mov es, ax
         mov dx, Colores
         
         ; establecemos paleta
         mov ax, 1002h
         xor bh, bh
         int 10h

         ; recuperamos registros         
         popa
         
         ret ; y volvemos
         