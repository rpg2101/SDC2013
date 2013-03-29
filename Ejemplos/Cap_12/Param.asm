
        segment Pila stack
          resw 512
FinPila:          

        segment Datos
        ; Direcciones de las variables
Memoria dw 13h,40h
Columnas dw 4Ah,40h
Pulsos dw 6Ch,40h


        ; Segmento de código
        segment Codigo
..start:

        ; Preparamos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila

        ; ES apunta al segmento de datos        
        mov ax, Datos
        mov es, ax

        ; Cargamos en DS:SI el puntero
        lds si, [es:Memoria]
        ; y leemos la palabra
        lodsw
        
        ; Repetimos la operación
        lds si, [es:Columnas]
        lodsw
        
        ; Vamos a leer una doble palabra
        lds si, [es:Pulsos]
        lodsw
        ; dejándola en AX:DX
        mov dx, ax
        lodsw
        
        ; Salimos al sistema
        mov ah, 4ch
        int 21h
        