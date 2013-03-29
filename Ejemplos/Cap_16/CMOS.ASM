
        segment Pila stack
          resw 512
FinPila:

        segment Datos

; Cadenas de texto para mostrar
; la información de memoria
MsgMemoriaBase      db '      Ks de memoria base - $'
MsgMemoriaExtendida db '      Ks de memoria extendida'
                    db 13, 10, 10, '$'

; Cadena común para los datos
; de las disqueteras
MsgDisquetera       db 'La disquetera '
  LetraDisquetera   db 'A: es de tipo $'

; Tenemos cinco cadenas distintas para
; indicar el tipo de la disquetera
Disquetera0 db '<No est  instalada>$'
Disquetera1 db '<5.25" y 360 Ks>$'
Disquetera2 db '<5.25" y 1.2 Mb>$'
Disquetera3 db '<3.5" y 720 Ks>$'
Disquetera4 db '<3.5" y 1.44 Mb>$'

; esta tabla apunta a cada una
; de las cinco cadenas anteriores
TblPunteros dw Disquetera0, Disquetera1, 
            dw Disquetera2, Disquetera3, 
            dw Disquetera4

; Cadena común para el disco duro
DiscoDuro  db 13, 10, 'Tipo del disco duro '
LetraDisco db 'C: - $'
; Cadena para indicar el tipo
TipoDisco  db '     ', 13, 10, '$'
; o su ausencia
NoInstalado db 'No est  instalado', 13, 10, '$'

AvanceLinea db 13, 10, '$'

; Cadena para mostrar la tabla de parámetros
; del disco duro
MsgParametros db 13, 10, 'Par metros del primer disco duro'
              db 13, 10
              db '--------------------------------'
              db 13, 10
              db 'Pistas:   '
     Pistas   resb 5
              db 13, 10
              db 'Cabezas:  '
     Cabezas  resb 5
              db 13, 10
              db 'Sectores: '
     Sectores resb 5
              db 13, 10, '$'
              
        ; Segmento de código
        segment Codigo
..start:
        ; Configuramos la pila
        mov ax, Pila
        mov ss, ax
        mov sp, FinPila
        
        ; DS y ES apuntan al segmento
        ; que contiene los datos
        mov ax, Datos
        mov ds, ax
        mov es, ax

        ; Mostramos información sobre
        ; la memoria base
        call MemoriaBase
        
        ; y la memoria extendida
        call MemoriaExtendida
        
        ; información sobre el tipo
        ; de las disqueteras
        call Disqueteras
        
        ; y los discos duros
        call DiscosDuros
  
        ; y por último los parámetros
        ; del primer disco
        call ParametrosDiscoDuro
                
        ; y salimos
        mov ah, 4ch
        int 21h

;--------------------------------
; Esta rutina muestra información
; sobre la memoria base instalada
;--------------------------------
MemoriaBase:
        ; leemos cantidad de
        ; memoria base
        mov bl, 22
        call LeeCMOS
        
        ; guardamos el byte de
        ; mayor peso en AH
        mov ah, al
        ; y leemos el de
        ; menor peso
        dec bl
        call LeeCMOS
        
        ; Tenemos en AX la 
        ; cantidad de memoria base
        
        ; la convertimos a cadena
        mov di, MsgMemoriaBase+4
        call EnteroCadena

        ; y mostramos
        mov dx, MsgMemoriaBase
        mov ah, 9
        int 21h        
         
        ret ; volver
        
;--------------------------------
; Esta rutina muestra información
; sobre la memoria extendida instalada
;----------------------------------        
MemoriaExtendida:
        ; leemos cantidad de
        ; memoria extendida
        mov bl, 49
        call LeeCMOS
        
        ; guardamos el byte de
        ; mayor peso en AH
        mov ah, al
        ; y leemos el de
        ; menor peso
        dec bl
        call LeeCMOS
        
        ; Tenemos en AX la 
        ; cantidad de memoria extendida
        
        ; la convertimos a cadena
        mov di, MsgMemoriaExtendida+4
        call EnteroCadena

        ; y mostramos
        mov dx, MsgMemoriaExtendida
        mov ah, 9
        int 21h        

        ret  ; volver

;--------------------------------
; Esta rutina mostrar el tipo de
; las disqueteras
;--------------------------------
Disqueteras:
        ; leemos el byte correspondiente
        ; al tipo de las disqueteras
        mov bl, 16
        call LeeCMOS
        
        push ax ; guardamos el dato
        
        ; nos quedamos con el
        ; nibble de la primera
        ; unidad
        shr al, 4
        
        ; y resolvemos su tipo
        call ResuelveDisquetera
        
        ; cambiamos la letra de A a B
        mov byte [LetraDisquetera], 'B'
        
        ; recuperamos el valor original
        pop ax
        
        ; y nos quedamos con el nibble
        ; de menor peso
        and al, 0fh
        
        ; resolvemos el tipo
        call ResuelveDisquetera
        
        ret ; y volvemos
        
;-------------------------------
; Esta rutina resuelve el tipo
; de una disquetera cuyo código
; se facilita en AL
;-------------------------------        
ResuelveDisquetera:
        ; guardamos AL
        push ax
        
        ; imprimimos la primera
        ; parte del mensaje
        mov dx, MsgDisquetera
        mov ah, 9
        int 21h
        
        pop ax ; lo recuperamos
        
        ; multiplicamos AL
        ; por 2        
        mov bl, 2
        ; para tener en AX
        ; un desplazamiento
        mul bl
        
        ; BX apunta a la tabla
        ; de punteros
        mov bx, TblPunteros
        ; le sumamos AX
        ; como desplazamiento
        add bx, ax
        
        ; tomamos la dirección
        ; de la cadena apropiada
        ; en DX
        mov dx, [bx]
        
        ; y la imprimimos
        mov ah, 9
        int 21h

        ; Avanzamos una línea
        mov dx, AvanceLinea
        mov ah, 9
        int 21h
        
        ret ; volver
                
;----------------------------------
; Esta rutina muestra el tipo de
; los discos duros instalados
;----------------------------------                
DiscosDuros:
        ; recuperamos el byte
        ; con los tipos de disco
        mov bl, 18
        call LeeCMOS
        
        ; guardamos el dato
        push ax
        ; y nos quedamos con
        ; el nibble de mayor peso
        shr al, 4
        
        ; facilitamos la dirección
        ; del byte extendido
        mov bl, 25
        ; y resolvemos el tipo
        call ResuelveDisco
        
        ; cambiamos la letra
        ; de C a D
        mov byte [LetraDisco], 'D'
        
        ; recuperamos el dato
        pop ax
        
        ; y nos quedamos con el
        ; nibble de menor peso
        and al, 0fh
        
        ; indicamos la dirección 
        ; del byte extendido
        mov bl, 26
        ; y resolvemos el tipo
        call ResuelveDisco
        
        ret ; volver
        
;------------------------------
; Esta rutina recibe en AL un
; tipo de disco y en BL la 
; dirección del byte extendido
; por si fuese necesario
;------------------------------        
ResuelveDisco:
         ; guardamos el tipo
         push ax
         
         ; mostramos la cadena común
         mov dx, DiscoDuro
         mov ah, 9
         int 21h
           
         ; recuperamos el dato
         pop ax
         
         ; comprobamos si el tipo es 0
         or al, al
         ; de ser así no hay disco
         jz DiscoNoInstalado
         
         ; comprobamos si es 15
         cmp al, 0fh
         ; de no ser así ya tenemos
         ; en AL el tipo y saltamos
         ; para mostrarlo
         jne DiscoNoExtendido

         ; en caso contrario obtenemos
         ; el tipo extendido, ya que
         ; en BL tenemos su dirección
         call LeeCMOS
        
DiscoNoExtendido:         
         ; convertimos el tipo en
         ; cadena
         mov di, TipoDisco+4
         xor ah, ah 
         call EnteroCadena
         
         ; y mostramos el resto del mensaje
         mov dx, TipoDisco
         mov ah, 9
         int 21h
         
         ret ; volver
         
DiscoNoInstalado:
         ; indicamos que no hay disco
         ; instalado
         mov dx, NoInstalado
         mov ah, 9
         int 21h
         
         ret ; volver 
         
;---------------------------
; Esta rutina muestra los
; parámetros del primer 
; disco duro
;---------------------------         
ParametrosDiscoDuro:
         ; obtenemos el 
         ; número de pistas
         mov bl, 33
         call LeeCMOS
         mov ah, al
         dec bl
         call LeeCMOS
         
         ; y lo convertimos
         mov di, Pistas+4
         call EnteroCadena
         
         ; recuperamos el número
         ; de cabezas
         mov bl, 34
         call LeeCMOS
         xor ah, ah
         
         ; y lo convertimos
         mov di, Cabezas+4
         call EnteroCadena
         
         ; Leemos el número de sectores
         mov bl, 39
         call LeeCMOS
         xor ah, ah
         
         ; y lo convertimos
         mov di, Sectores+4
         call EnteroCadena
         
         ; mostramos la información
         mov dx, MsgParametros
         mov ah, 9
         int 21h
         
         ret        

;-----------------------
; Esta rutina recupera
; un byte de información
; de la memoria CMOS.
; Debe indicarse la 
; dirección en BL y se
; devuelve el dato en AL
;-----------------------
LeeCMOS:
        ; leemos el valor
        ; del puerto 70h
        in al, 70h
        ; ponemos a 0 los 5
        ; bits de menor peso
        and al, 128
        ; y sumamos la 
        ; dirección indicada
        or al, bl
        
        ; seleccionamos 
        ; dirección
        out 70h, al
        ; y leemos el dato
        in al, 71h
        
        ; volvemos
        ret
        
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