        segment Pila stack
          resw 512
FinPila:

        segment Datos
; Cadena con el mensaje que indicará
; la cantidad total de memoria extendida
Mensaje   db 'Hay '
 Memoria  resb 5
          db ' Ks de memoria extendida', 13, 10, '$'
          
; Cadena para la cantidad de memoria
; existente por debajo de los 16 Mb          
MsgInf16  db 'Hay '
 MemInf16 resb 5          
          db ' Ks de memoria por debajo de 16 Mb', 13, 10, '$'
          
; Cadena para la cantidad de memoria
; existente por encima de los 16 Mb          
MsgSup16  db 'Hay '
 MemSup16 resb 5
          db ' Ks de memoria por encima de 16 Mb$'
          
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
        mov es, ax
        
        ; recuperamos información
        ; sobre la cantidad de 
        ; memoria extendida
        mov ah, 88h
        int 15h
          
        ; convertimos cadena
        mov di, Memoria+4
        call EnteroCadena
        
        ; y mostramos
        mov dx, Mensaje
        mov ah, 9
        int 21h
              
        ; Recuperamos información sobre
        ; memoria extendida por encima
        ; y por debajo de los 16 Mb
        mov ax, 0E801h
        int 15h

        ; guardamos la que hay
        ; por encima
        push bx
        
        ; convertimos la que hay
        ; por debajo, en AX
        mov di, MemInf16+4
        call EnteroCadena
        
        ; y mostramos
        mov dx, MsgInf16
        mov ah, 9
        int 21h
        
        ; recuperamos el antiguo
        ; contenido de BX
        pop ax
        ; viene expresado en bloques
        ; de 64 Ks
        mov bx, 64
        mul bx
        
        ; convertir a cadena
        mov di, MemSup16+4
        call EnteroCadena
        
        ; y mostrarlo
        mov dx, MsgSup16
        mov ah, 9
        int 21h

        ; y salimos
        mov ah, 4ch
        int 21h
        
;-----------------------------
; Este procedimiento convierte
; el valor de AX en una cadena
; de hasta cinco caracteres
; 
; Entrada: AX = número a convertir
;          ES:DI = destino cadena
;-----------------------------
EnteroCadena:
        ; DX debe estar a cero
        push dx ; lo guardamos
        xor dx, dx
        
        ; establecemos valor inicial
        mov byte [di], '0'
        
        ; comprobamos si AL es cero
        or ax, ax
        ; de ser así, no hay más
        ; que hacer
        jz FinConversion

        push bx ; guardamos bx
        ; y establecemos el divisor
        mov bx, 10        
        
 Bucle0:
        ; vamos dividiendo por 10
        div bx 
        
        ; quedándonos con el resto
        ; que convertimos a ASCII
        add dl, '0'
        ; y guardamos
        mov [di], dl
        ; retrocediendo al dígito anterior
        dec di
        
        ; eliminamos el contenido
        ; de DX para quedarnos con
        ; el cociente de AX
        xor dx, dx
        
        ; si el cociente es mayor que 9
        cmp ax, 9
        ; seguimos dividiendo
        ja Bucle0
        
        ; en caso contrario guardamos
        add al, '0'
        mov [di], al
        
        pop bx ; recuperamos BX
        
FinConversion:
        pop dx ; recuperamos DX
        ret