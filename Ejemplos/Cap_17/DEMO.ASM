        ; Segmento de pila
        segment Pila stack
          resw 512
FinPila:

        ; Segmento de datos
        segment Datos

; Este campo indicar� el n�mero
; de programas a ejecutar        
NumProgramas dw 3     
        
; Descripciones y nombres de los programas       
Desc1 db 'Demostraci�n de color en CGA$'
Prog1 db '.\puntocga.exe', 0
Desc2 db 'Demostraci�n de color en EGA$'
Prog2 db '.\colorega.exe', 0
Desc3 db 'Efectos de color en VGA$'
Prog3 db '.\colorvga.exe', 0        
        
; Tabla de punteros a las
; cadenas con anteriores
TblPunteros dw Desc1, Prog1
            dw Desc2, Prog2 
            dw Desc3, Prog3

; Bloque de par�metros para
; el servicio 4Bh de la int 21h
BloqueParametros
   dw 0 ; usar entorno del DOS
   dd LineaComandos ; cadena de par�metros
   dd FCB1, FCB2 ; FCBs  
   
; La cadena de par�metros est� vac�a
LineaComandos db 0,13         
; como los FCB
FCB1 resb 20
FCB2 resb 20
        
; Esta etiqueta marca el
; fin del segmento de datos        
FinDatos        

        ; Segmento de c�digo
        segment Codigo
..start:

        ; Configuramos los
        ; registros de pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; y los registros de
        ; segmento de datos
        mov ax, Datos
        mov ds, ax
     
        ; Ajustamos la memoria
        ; asignada a justo la
        ; que necesitamos
        call AjustaMemoria

        ; Hacer que ES tambi�n
        ; apunte a los datos
        push ds
        pop es
                    
        ; obtenemos el contador
        ; de programas a ejecutar
        mov cx, [NumProgramas]
        
        ; BX apunta a la tabla
        ; de punteros a cadenas
        mov bx, TblPunteros
        
Bucle: 
        ; obtenemos en DX la
        ; direcci�n de una cadena
        ; con la descripci�n del
        ; programa a ejecutar
        mov dx, [bx]        
        
        ; la mostramos
        mov ah, 9
        int 21h
        
        ; y esperamos una tecla
        mov ah, 0Ch
        mov al, 7
        int 21h
        
        ; nos desplazamos al 
        ; siguiente puntero
        add bx, 2
        
        ; recuperamos la direcci�n
        ; del nombre del programa
        mov dx, [bx]
        
        ; lo ejecutamos
        call Ejecuta
        
        ; pasamos al siguiente puntero
        add bx, 2
        
        ; y repetimos el proceso
        loop Bucle
        
        ; Devolvemos el control
        ; al sistema
        mov ah, 4ch
        int 21h

;-------------------------------
; Esta rutina calcula la memoria
; que necesita el programa y 
; reajusta el bloque asignado
; por el sistema.
; Es importante no haber modificado
; el contenido del registro ES
; antes de llamar a esta rutina
;-------------------------------
AjustaMemoria:
         ; Tomamos en BX la direcci�n
         ; del final del c�digo m�s
         ; 256 bytes del PSP
         mov bx,FinCodigo+256
         ; le a�adimos lo que ocupa
         ; el segmento de pila
         add bx, FinPila
         ; y tambi�n lo que ocupa
         ; el segmento de datos
         add bx, FinDatos
         
         ; dividimos entre 16 para
         ; convertir a p�rrafos
	       shr bx,4
	       
	       ; sumamos un p�rrafo por
	       ; cada segmento que tenemos:
	       ; pila, datos y c�digo, para
	       ; compensar los ajutes
	       add bx, 3
	       
	       ; redimensionamos el bloque
	       ; de memoria asignado 
	       mov ah,4ah	
	       int 21h		
	       
	       ; y volvemos
	       ret
        
;----------------------------------
; Esta rutina recibe en DX la
; direcci�n de una cadena con el 
; nombre del programa a ejecutar 
;----------------------------------        
Ejecuta:
        ; guardamos registros
        push ds
        push es
        pusha

        ; ponemos AL a 0 para indicar
        ; que deseamos ejecutar
        xor al, al
        
        ; n�mero del servicio
        mov ah, 4Bh
        
        ; DS:DX ya tiene la direcci�n
        ; del nombre del programa
        ; ES:BX debe apuntar al 
        ; bloque de par�metros
        
        ; direcci�n del bloque
        mov bx, BloqueParametros
        ; ejecutamos
        int 21h
        
        ; recuperamos los registros
        popa
        pop es 
        pop ds
       
        ret ; y volvemos
        
; Esta etiqueta marca el final
; del segmento de c�digo        
FinCodigo:                