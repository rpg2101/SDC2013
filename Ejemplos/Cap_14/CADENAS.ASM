        ; Segmento de la pila
        segment Pila stack
          resw 512
FinPila:

        ; Segmento de datos
        segment Datos

; Las siguientes cadenas de caracteres
; solicitarán los datos a introducir
Titulo1 db 10,  8, 'Nombre ....: $'
Titulo2 db 10, 10, 'Apellidos .: $'
Titulo3 db 10, 12, 'Direcci¢n .: $'
Titulo4 db 10, 14, 'Tel‚fono ..: $'

; La siguiente tabla de datos servirá
; para solicitar cada uno de los datos.
; Cada elemento se compone de la columna
; y línea donde debe pedirse el dato, un
; byte con la máxima longitud del dato,
; otro byte donde se almacenará el 
; número de caracteres pedidos y, por
; último, un área para alojar los caracteres
Dato1 db 23,  8, 10, 0
      resb 10
Dato2 db 23, 10, 15, 0
      resb 15
Dato3 db 23, 12, 20, 0
      resb 20
Dato4 db 23, 14, 13, 0
      resb 13
                        
        ; Segmento de código
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; DS apunta al segmento
        ; que contiene los datos
        mov ax, Datos
        mov ds, ax
        
        ; borramos el contenido
        ; de la pantalla
        call LimpiaPantalla
        
        ; mostramos los textos
        call MuestraTextos
        
        ; pide los datos
        call PideDatos
        
        ; salir al sistema
        mov ah, 4ch
        int 21h
        
;-------------------------------
; Esta rutina pide los datos
;-------------------------------
PideDatos:
        ; DX apunta al primero
        mov dx, Dato1
        ; pedir el dato
        call Entrada

        ; repetir
        mov dx, Dato2
        call Entrada
        
        mov dx, Dato3
        call Entrada

        mov dx, Dato4
        call Entrada

        ret ; volver
        
;-------------------------------
; Esta rutina recibe en DX la 
; dirección de uno de los elementos
; de la tabla de datos y lo
; solicita
;-------------------------------
Entrada:
        pusha ; guardar registros
        
        ; tomamos la dirección en BX
        mov bx, dx
        ; e incrementamos DX para
        ; acceder a la longitud
        inc dx
        inc dx
        push dx ; lo guardamos
        
        ; tomamos la columna
        mov dl, [bx]
        ; incrementamos la dirección
        inc bx
        ; y leemos la línea
        mov dh, [bx]
        xor bh, bh
        ; colocamos el cursor
        mov ah, 2
        int 10h
        
        ; recuperamos la dirección
        pop dx
        ; y la pasamos a bx
        mov bx, dx
        
        ; tomamos la longitud en cx
        mov cl, [bx]
        xor ch, ch
        ; quitamos el Intro final
        dec cx
        ; carácter de subrayado
        mov al, '_'
        ; atributo normal
        mov bl, 7
        xor bh, bh
        ; imprimimos la secuencia
        ; de subrayados
        mov ah, 9
        int 10h
        
        ; pedimos el dato apuntado
        ; por DS;DX
        mov ah, 0Ah
        int 21h
        
        popa ; recuperar registros
        
        ret ; volver
        
;-------------------------------
; Esta rutina muestra los textos
;-------------------------------
MuestraTextos:
        ; cuatro textos
        mov cx, 4
        ; DX apunta a la primera cadena
        mov dx, Titulo1
        
BucleM0:        
        ; mostramos cadena
        call Imprimir
        ; pasamos a la siguiente
        add dx, 16
        ; y repetimos
        loop BucleM0
        
        ret ; volver
        
;------------------------------
; Esta rutina recibe en DX la
; dirección de uno de los elementos
; y lo muestra en la posición
; adecuada
;------------------------------
Imprimir:
        pusha ; guardar registros
        
        ; movemos la dirección a BX
        mov bx, dx        
        ; y guardamos DX
        push DX
        
        ; leemos la columna
        mov dl, [bx]
        ; incrementamos la dirección
        inc bx
        ; y tomamos la línea
        mov dh, [bx]
        xor bh, bh
        ; colocamos el cursor
        mov ah, 2
        int 10h
        
        ; recuperamos la dirección
        ; de la cadena
        pop dx
        ; incrementamos para
        ; apuntar al texto
        inc dx
        inc dx
        
        ; y lo imprimimos
        mov ah, 9
        int 21h
        
        popa ; recuperar registros
        
        ret ; volver
        
;-------------------------------
; Esta rutina limpia la pantalla
;-------------------------------
LimpiaPantalla:
        xor dx, dx ; ponemos el cursor
        xor bh, bh ; en la esquina superior
        mov ah, 2  ; izquierda
        int 10h
        
        ; para introducir 2000
        ; espacios
        mov bl, 7
        mov al, ' '
        mov cx, 2000
        mov ah, 9
        int 10h
        
        ret ; volver        