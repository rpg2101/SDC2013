	;
    ; TblASC3.ASM
	;
	; Programa residente que presenta una tabla
    ; ASCII cuando es activado, permitiendo
    ; seleccionar un car cter y llevarlo al
    ; buffer de teclado, de tal forma que sea
    ; recibido por el programa que se est‚
    ; ejecutando en ese momento.
	;
    ; ¸ Francisco Charte  - Enero 
	;
    ; Esta versi¢n del programa utiliza un
    ; bloque separado de datos para cada VM, y
    ; adem s carga un programa Windows en
    ; respuesta al mensaje de identificaci¢n.

    ;-----------------------------------------
    ; Definici¢n de constantes
    ;-----------------------------------------

    ; C¢digo de la tecla de activaci¢n del programa
TECLA_ACTIVACION    EQU     20  ; T

    ; Identificador del programa para la INT 2Fh
ID_PROGRAMA         EQU     123

    ; C¢digo de confirmaci¢n del programa
CONFIRMACION        EQU     54321

    ; Con estos c¢digos se dibujar n los bordes
    ; de la tabla de caracteres
ESQ1    EQU     201     ; É
ESQ2    EQU     200     ; È
ESQ3    EQU     187     ; »
ESQ4    EQU     188     ; ¼
HORZ    EQU     205     ; Í
VERT    EQU     186     ; º

    ; Segmento de memoria de v¡deo
SEG_PANTALLA    EQU     0B800h

    ; Bytes que ocupa una pantalla
    ; de texto
BYTES_PANTALLA  EQU     4000

    ; Atributo para la tabla.
ATTR_TABLA      EQU     1Fh

    ; Ancho de la tabla menos laterales
ANCHO_TABLA     EQU     72

    ; N£mero de bytes de cada l¡nea
    ; de pantalla en modo texto
BYTES_LINEA     EQU     160

    ; N£mero de columnas y filas en la tabla
COLUMNAS        EQU     12
FILAS           EQU     22

    ; Segmento de datos del BIOS
SEGMENTO_BIOS   EQU     40h

    ; N£mero de caracteres que ocupa cada
    ; entrada en la tabla
CARACTERES_ELEMENTO EQU     6

    ; C¢digos de las teclas a controlar en
    ; el programa
CURSOR_ARRIBA       EQU     72
CURSOR_IZQUIERDA    EQU     75
CURSOR_DERECHA      EQU     77
CURSOR_ABAJO        EQU     80
TECLA_ESCAPE        EQU      1
TECLA_INSERTAR      EQU     82

    ; Distintas direcciones de puertos
PPI_PORT_A          EQU     60h
PPI_PORT_B          EQU     61h
PIC                 EQU     20h
EOI                 EQU     20h

    ; Distintas direcciones de datos
MODO_VIDEO              EQU     49h
PAGINA_VIDEO            EQU     62h
OFFSET_PAGINA_ACTUAL    EQU     4Eh
PESCRITURA_TECLADO      EQU     1Ch
INICIO_BUFFER_TECLADO   EQU     1Eh
FIN_BUFFER_TECLADO      EQU     3Eh
SHIFT_STATUS            EQU     17h
SEG_BLOQUE_ENTORNO      EQU     2Ch

    ; Tama¤o de la pila para la parte residente
TAMANO_PILA             EQU     128

	.Model Small     ; Modelo de memoria peque¤o
	.386

	.Stack 512      ; Pila para la parte transitoria

	.Code
	.Startup

	Jmp Instalar    ; Saltar a la instalaci¢n

	;--------------------------------------------
	; Se definen todos los par metros que ser n
	; utilizados por el programa, y que por lo
	; tanto deber n quedar residentes.
	;--------------------------------------------

	; Estructura para mantener la informaci¢n
	; de cada uno de los vectores de interrupci¢n
	; a modificar.
BlqInt Struc
	Numero          Db ?
	AnteriorGestor  Dd ?
	NuevoGestor     Dd ?
BlqInt Ends

	; Datos de cada una de las interrupciones
INT09   BlqInt    <09h, ?, Gestor09>
INT10   BlqInt    <10h, ?, Gestor10>
INT13   BlqInt    <13h, ?, Gestor13>
INT08   BlqInt    <08h, ?, Gestor08>
INT28   BlqInt    <28h, ?, Gestor28>
INT2F   BlqInt    <2Fh, ?, Gestor2F>
INT1B   BlqInt    <1Bh, ?, Gestor1B>
INT23   BlqInt    <23h, ?, Gestor23>
INT24   BlqInt    <24h, ?, Gestor24>

PilaAnterior Dd ?   ; Para salvar la pila
PSPAnterior  Dw ?   ; y el PSP

PilaResidente Dd ?  ; Direcci¢n de la propio pila
PSPResidente  Dw ?  ; Segmento del PSP propio

InDos   Dd  ?   ; Direcci¢n del indicador InDos

InBios      Db  0   ; Indicadores auxiliares
Activar     Db  0
Activado    Db  0
EnInt28     Db  0

ContadorTiempo Db 0 ; Contador de tiempo

    ; Bloque para salvar pantalla
Pantalla Db BYTES_PANTALLA Dup(?) 

Cursor Dw ? ; Posici¢n del cursor en la pantalla

PaginaActiva Db ? ; P gina de texto activa
OffsetPagina Dw ? ; Offset de la p gina en el segmento

Columna Db 0    ; Columna y fila del car cter
Fila    Db 0    ; seleccionado en la tabla

    ; Calcular el total de bytes de datos
BytesDatos EQU ($-Offset INT09)

    ; Estructura para indicar la direcci¢n
    ; y tama¤o de cada bloque de datos.
BloqueDatos Struc
    DireccionBloque     Dd  ?
    TamanoBloque        Dw  ?
BloqueDatos EndS

    ; Estructura a devolver en respuesta a la
    ; llamada a la INT 2Fh con el servicio 1605h
BloqueInicializacion Struc
    VersionWin          Db      3, 10
    NextDevPtr          Dd      ?
    VirtDevFilePtr      Dd      0
    ReferenceData       Dd      0
    InstanceDataPtr     Dd      ?
BloqueInicializacion EndS

Inicializacion BloqueInicializacion <>
DatosTSR BloqueDatos    <>
PilaTSR  BloqueDatos    <>
         BloqueDatos    <0, 0>

    ; Bloque de datos para indentificaci¢n
    ; del programa y cargar una aplicaci¢n
    ; Windows.
BloqueIdentificacion Struc
    SiguienteTSR        Dd      ?
    SegmentoPSP         Dw      ?
    VersionEstructura   Dw      100h
    Indicadores         Dw      1
    Visualizacion       Dw      0
    Comando             Dd      ?
    Reservado           Dd      0
    FirmaTSR            Dd      ?
    PunteroDatos        Dd      ?
BloqueIdentificacion Ends

Identificacion BloqueIdentificacion <>

CadenaComando   Db  'TBLWIN.EXE', 0

BloqueFirmaTSR      Dw  15
                    Db  'Tabla ASCII.', 0

    ;------------------------------------------
    ; Este procedimiento contiene el c¢digo
    ; con la funcionalidad del programa, en
    ; este caso mostrando una tabla de c¢digos
    ; ASCII.
    ;------------------------------------------
TablaAscii Proc

        ; Cargamos en ES:DI la direcci¢n
        ; de pantalla
    Mov AX, SEG_PANTALLA
    Mov ES, AX
    Mov DI, CS:[OffsetPagina]

    Mov AH, ATTR_TABLA  ; Atributo de texto

    Mov AL, ESQ1 ; Primera esquina
    Stosw

    Mov AL, HORZ    ; Car cter horizontal
    Mov CL, ANCHO_TABLA ; para dibujar la
    Rep Stosw   ; parte superior

    Mov AL, ESQ3
    Stosw       ; Otra esquina

    Xor DL, DL ; Contador de l¡neas

BucleLineas:

        ; Tomar la direcci¢n base
    Mov DI, CS:[OffsetPagina]

        ; Y sumar el incremento necesario
        ; para llegar a la l¡nea actual
    Mov AL, BYTES_LINEA
    Inc DL
    Mul DL   ; BYTES_LINEA * L¡nea actual
    Dec DL
    Add DI, AX

    Mov AH, ATTR_TABLA     ; Cargamos de nuevo el atributo

    Mov AL, VERT   ; Margen izquierdo
    Stosw

    Mov AL, COLUMNAS  ; columnas por fila
    Mul DL  ; Obtenemos en AL el c¢digo del primer
            ; car cter de esta l¡nea

    Mov AH, ATTR_TABLA  ; Preparamos el atributo
    Mov CX, COLUMNAS ; y el contador del bucle

BucleColumnas:

    Stosw   ; Imprimimos el car cter

    Push AX ; Guardamos el c¢digo

    Mov AL, '-' ; Un gui¢n une a cada car cter
    Stosw  ; con su c¢digo

    Pop AX ; Recuperamos c¢digo

        ; Mostramos el c¢digo ASCII correspondiente
    Call ImprimeCodigo

    Inc AL ; Pasamos al siguiente car cter

    Or AL, AL   ; Ver si ya est n todos
    Jz FinTabla    ; si es as¡ no continuar

    Loop BucleColumnas ; Hasta terminar la fila

    Mov AL, VERT  ; Margen derecho
    Stosw

    Inc DL ; Incrementamos el contador de l¡neas

    Jmp BucleLineas ; Hasta terminar toda la tabla

FinTabla: ; Ya se han mostrado los 256 caracteres

    Mov CX, 48  ; Resto de espacios en la fila
    Mov AL, ' ' ; rellenarlo
    Rep Stosw

    Mov AL, VERT    ; Margen derecho
    Stosw

        ; Tomar la direcci¢n base
    Mov DI, CS:[OffsetPagina]

        ; Y sumar el incremento necesario
        ; para llegar a la £ltima l¡nea
    Mov AL, BYTES_LINEA
    Inc DL
    Inc DL
    Mul DL
    Add DI, AX

    Mov AH, ATTR_TABLA     ; Cargamos de nuevo el atributo

    Mov AL, ESQ2    ; Una esquina
    Stosw

    Mov AL, HORZ        ; La l¡nea inferior
    Mov CX, ANCHO_TABLA
    Rep Stosw

    Mov AL, ESQ4 ; y la otra esquina
    Stosw

        ; Hemos terminado de dibujar la tabla, ahora
        ; entramos en el bucle de selecci¢n de car cter

        ; Dejar ES apuntando al segmento de datos
        ; del BIOS
    Mov AX, SEGMENTO_BIOS
    Mov ES, AX

BucleTeclado:

        ; Calcular la columna de pantalla
        ; correspondiente a la columna actual de
        ; la tabla
    Mov AL, CS:[Columna]
    Mov DL, CARACTERES_ELEMENTO
    Mul DL
    Inc AL
    Mov DL, AL  ; Columna del car cter elegido

    Mov DH, CS:[Fila]   
    Inc DH   ; Fila del car cter elegido

    Mov BH, CS:[PaginaActiva]
    Mov AH, 2
    Int 10h     ; Posicionamos el cursor

EsperaTecla:

    Xor AH, AH
    Int 16h     ; Esperamos la pulsaci¢n de una tecla

        ; Seg£n al tecla que se haya
        ; pulsado pasamos el control
        ; a una etiqueta u otra.
    Cmp AH, CURSOR_ARRIBA
    Je Arriba
    Cmp AH, CURSOR_IZQUIERDA
    Je Izquierda
    Cmp AH, CURSOR_DERECHA
    Je Derecha
    Cmp AH, CURSOR_ABAJO
    Je Abajo
    Cmp AH, TECLA_ESCAPE
    Je SalirBucleTeclado
    Cmp AH, TECLA_INSERTAR
    Je Insertar

        ; Si no es ninguna de las teclas aneriores
    Mov CL, 8  ; generar un pitido
    Call Pitido
    Jmp EsperaTecla ; y volver a esperar una tecla

Arriba: ; Se ha pulsado el cursor arriba

    Cmp CS:[Fila], 0 ; Si ya estamos en la primera 
    Jz EsperaTecla ; fila, no continuar

    Dec CS:[Fila] ; Decrementar la fila
    Jmp BucleTeclado  ; y volver

Izquierda: ; Se ha pulsado el cursor a la izquierda

    Cmp CS:[Columna], 0 ; Si ya estamos en la primera
    Jz EsperaTecla ; columna, no continuar

    Dec CS:[Columna] ; Decrementar la columna
    Jmp BucleTeclado ; y volver

Derecha: ; Se ha pulsado el cursor a la derecha

        ; Si estamos en la £ltima columna de la fila
    Cmp CS:[Columna], COLUMNAS-1
    Je EsperaTecla  ; ignorar la pulsaci¢n

    Inc CS:[Columna] ; Incrementar la columna
    Jmp BucleTeclado ; y volver

Abajo: ; Se ha pulsado el cursor abajo

        ; Si estamos en la £ltima fila de la tabla
    Cmp CS:[Fila], FILAS-1
    Je EsperaTecla ; ignorar la pulsaci¢n

    Inc CS:[Fila] ; Incrementar la fila
    Jmp BucleTeclado ; y volver

Insertar:  ; Insertar la tecla en el buffer de teclado

    Mov AL, CS:[Fila] ; Tomamos la fila actual
    Mov DL, COLUMNAS  ; la multiplicamos por el
    Mul DL ; n£mero de columnas en cada fila
    Add AL, CS:[Columna] ; y le sumamos la columna

        ; Ya tenemos en AL el c¢digo ASCII del
        ; car cter elegido en la tabla

        ; Obtenemos en BX el puntero de escritura
        ; en el buffer de teclado
    Mov BX, ES:[PESCRITURA_TECLADO]
    Mov ES:[BX], AL ; insertamos la tecla

    Inc BX ; Incrementamos el puntero
    Mov Byte Ptr ES:[BX], 0 ; e insertamos el scan code

    Inc BX ; Volvemos a incrementar el puntero
        ; Ver si estamos al final del buffer de teclado
    Cmp BX, FIN_BUFFER_TECLADO 
    Jb NoHaySalto  ; Si no es as¡ saltar
        ; En caso necesario apuntar al inicio del buffer
    Mov BX, INICIO_BUFFER_TECLADO

NoHaySalto:
        ; Escribir el nuevo puntero de escritura
    Mov ES:[PESCRITURA_TECLADO], BX

SalirBucleTeclado:

    Ret  ; Salir

TablaAscii Endp

    ;--------------------------------------
    ; Este procedimiento se encarga  de
    ; convertir el dato facilitado en AL
    ; en una cadena, imprimi‚ndola en la
    ; posici¢n actual en pantalla.
    ;--------------------------------------
ImprimeCodigo Proc

    Push DX ; Preservar los registros que vamos
    Push AX ; a modificar 

    Xor AH, AH ; Eliminar el contenido de AH

    Mov DL, 100 ; Obtener las centenas
    Div DL

    Push AX ; Preservar el resto

    Add AL, '0' ; Convertir en d¡gito las centenas
    Mov AH, ATTR_TABLA ; y escribirlas en pantalla
    Stosw

    Pop AX  ; Recuperamos el resto de la divisi¢n

    Mov AL, AH ; Tomar el resto en AL
    Xor AH, AH ; y borrar AH

    Mov DL, 10 ; Obtener las decenas
    Div DL  ; Dividiendo el contenido de AX entre 10

    Add AL, '0'  ; Convertir en car cter
    Add AH, '0' ; cada d¡gito

    Push AX ; Preservar las unidades

    Mov AH, ATTR_TABLA ; Mostramos las decenas
    Stosw ; en pantalla

    Pop AX ; Recuperamos las unidades
    Mov AL, AH ; las pasamos a AL
    Mov AH, ATTR_TABLA ; y las mostramos en pantalla
    Stosw

    Mov AL, ' '  ; Un espacio para separar del 
    Stosw ; siguiente car cter

    Pop AX  ; Restablecemos el valor de los
    Pop DX  ; registrados salvados en la pila

    Ret ; y volvemos
ImprimeCodigo Endp

    ;------------------------------------
    ; Este procedimiento tiene como £nica
    ; finalidad generar un pitido durante
    ; un segundo, para indicar alg£n tipo
    ; de error.
    ; El tono del pitido depender  del
    ; valor que se facilite en CL.
    ;------------------------------------
Pitido Proc 
    Push AX ; Preservamos registros a modificar

        ; Ponemos a cero el contador de tiempo
    Mov CS:[ContadorTiempo], 0

        ; Fijamos el tipo de activaci¢n
    Mov AL, 10110110b
    Out 43h, AL
    Xor AL, AL   ; y la frecuencia del pitido
    Out 42h, AL
    Mov AL, CL   ; CL tiene la frecuencia
    Out 42h, AL

    In AL, PPI_PORT_B  ; Activamos el pitido
    Or AL, 3
    Out PPI_PORT_B, AL

BuclePitido:
        ; Esperamos aproximadamente un segundo
    Cmp Byte Ptr CS:[ContadorTiempo], 18
    Jb BuclePitido

    In AL, PPI_PORT_B      ; Desactivamos el pitido
    And AL, 252
    Out PPI_PORT_B, AL

    Pop AX     ; Recuperamos registros

    Ret         ; Volver
Pitido Endp

    ;--------------------------------------
    ; Gestor de la interrupci¢n de teclado
    ;--------------------------------------
Gestor09 Proc
	Push AX ; Salvamos AX

    In AL, PPI_PORT_A ; Leemos el c¢digo de tecla
      ;  ¨Es la tecla de activaci¢n?
    Cmp AL, TECLA_ACTIVACION
    Jne NoEsPeticion ; si no saltar

	Push ES     ; Salvar ES
    Mov AX, SEGMENTO_BIOS ; Cargar en AL el contenido del
	Mov ES, AX  ; indicador de estado almacenado
    Mov AL, ES:[SHIFT_STATUS]

	Pop ES      ; Recuperamos ES

	And AL, 8 ; Comprobar si est  pulsada la tecla ALT
	Jz NoEsPeticion ; Si no as¡ no continuar

    In AL, PPI_PORT_B  ; Indicar que la tecla ya
	Or AL, 80h  ; ha sido le¡da
    Out PPI_PORT_B, AL
	And AL, 7Fh
    Out PPI_PORT_B, AL

    Mov AL, EOI ; Enviar EOI al controlador
    Out PIC, AL ; de interrupciones

        ; Ver si estamos ahora mismo activos
    Cmp CS:[Activado], 1
        ; Si es as¡ no seguir
    Je NoIndicarActivar

	Mov CS:Activar, 1 ; Activar el indicador

NoIndicarActivar:

	Pop AX  ; Recuperar AX
	Iret    ; y salir

NoEsPeticion:

	Pop AX ; Recuperar AX

	Pushf   ; Meter el registro de flags
		; y llamar al anterior gestor 
	Call CS:INT09.AnteriorGestor
	Iret ; Volver

Gestor09 Endp

    ;--------------------------------------
    ; Gestor de la interrupci¢n de v¡deo
    ;--------------------------------------
Gestor10 Proc

		; Incrementar el indicador InBios                                        
	Inc CS:[InBios]

		; Llamar al anterior gestor
	Pushf
	Call CS:INT10.AnteriorGestor

		; Decrementar el indicador InBios
	Dec CS:[InBios]

	Iret ; y volver
Gestor10 Endp

    ;----------------------------------------
    ; Gestor de la interrupci¢n de disco
    ;----------------------------------------
Gestor13 Proc

		; Incrementar el indicador InBios                                        
	Inc CS:[InBios]

		; Llamar al anterior gestor
	Pushf
	Call CS:INT13.AnteriorGestor

		; Decrementar el indicador InBios
	Dec CS:[InBios]

	Iret ; y volver
Gestor13 Endp

    ;-------------------------------------------
    ; Gestor de la interrupci¢n de reloj
    ;-------------------------------------------
Gestor08 Proc

		; Llamar al anterior gestor
	Pushf
    Call CS:INT08.AnteriorGestor

        ; Incrementar continuamente el
        ; contador de tiempo
    Inc CS:[ContadorTiempo]

		; Comprobar si es posible la
		; activaci¢n
	Call CompruebaEstado
	Jc NoApropiado

	Call ActivarResidente ; Si es as¡ activar

NoApropiado:
	Iret    ; salir
Gestor08 Endp

    ;-----------------------------------------
    ; Gestor de la interrupci¢n 28h
    ;-----------------------------------------
Gestor28 Proc

		; Indicar que se est  en la INT 28
	Mov CS:[EnInt28], 1

    Call CompruebaEstado ; Comprobar si es posible
    Jc NoApropiado2  ; la activaci¢n

    Call ActivarResidente ; Si es as¡, activar

NoApropiado2:

	Mov CS:[EnInt28], 0

		; Llamar al anterior gestor
	Pushf
    Call CS:INT28.AnteriorGestor

	Iret    ; salir
Gestor28 Endp

    ;--------------------------------------
    ; Gestor de la interrupci¢n m£ltiple
    ;--------------------------------------
Gestor2F Proc
    Cmp AX, 160Bh       ; ¨Petici¢n de identificaci¢n?
    Jne CargaWindows   ; Si no saltar

        ; Almacenar ES:DI en SiguienteTSR
    Mov Word Ptr CS:Identificacion.SiguienteTSR, DI
    Mov Word Ptr CS:Identificacion.SiguienteTSR[2], ES

    Push AX

        ; Obtener el segmento del PSP y
        ; almacenarlo en la estructura
    Mov AX, CS:PSPResidente
    Mov CS:Identificacion.SegmentoPSP, AX

        ; Pasar la direcci¢n de la cadena de comando
    Mov AX, Offset CadenaComando
    Mov Word Ptr CS:Identificacion.Comando, AX
    Mov Word Ptr CS:Identificacion.Comando[2], CS

        ; Pasar la direcci¢n con la firma
    Mov AX, Offset BloqueFirmaTSR
    Mov Word Ptr CS:Identificacion.FirmaTSR, AX
    Mov Word Ptr CS:Identificacion.FirmaTSR[2], CS

    Pop AX      
    Mov DI, Offset Identificacion   
    Push CS     ; ES:DI apuntando a Identificaci¢n
    Pop ES

		; Saltar al siguiente gestor de la lista
	Jmp CS:INT2F.AnteriorGestor
    
CargaWindows:
    Cmp AX, 1605h        ; ¨Se va a cargar Windows?
    Jne ProcesoNormal   ; Si no es as¡ proceder de forma normal

    Pushf               ; Llamar al anterior gestor
    Call CS:INT2F.AnteriorGestor

        ; Almacenar la direcci¢n del
        ; gestor anterior en la estructura
    Mov Word Ptr CS:Inicializacion.NextDevPtr[0], BX
    Mov Word Ptr CS:Inicializacion.NextDevPtr[2], ES

        ; Obtener la direcci¢n de inicio y tama¤o del bloque
        ; de datos y almacenarlo
    Mov BX, Offset INT09
    Mov Word Ptr CS:DatosTSR.DireccionBloque, BX
    Mov Word Ptr CS:DatosTSR.DireccionBloque[2], CS
    Mov CS:DatosTSR.TamanoBloque, BytesDatos

        ; Obtener la direcci¢n de inicio y tama¤o
        ; de la pila y almacenarlo
    Mov BX, Offset EspacioDePila
    Mov Word Ptr CS:PilaTSR.DireccionBloque, BX
    Mov Word Ptr CS:PilaTSR.DireccionBloque[2], CS
    Mov CS:PilaTSR.TamanoBloque, TAMANO_PILA

        ; Tomar la direcci¢n de las estructuras anteriores
        ; y almacenarla en el bloque de inicializaci¢n
    Mov BX, Offset DatosTSR
    Mov Word Ptr CS:Inicializacion.InstanceDataPtr, BX
    Mov Word Ptr CS:Inicializacion.InstanceDataPtr[2], CS

    Push CS ; ES:BX apuntando a nuestra propia
    Pop ES  ; estructura de inicializaci¢n
    Mov BX, Offset Inicializacion

    Iret  ; terminar

ProcesoNormal:
    Cmp AH, ID_PROGRAMA ; Comprobar si es para nosotros
	Jne NoLoes

	Cmp AL, 1 ; Orden de desinstalar
	Jnz Salir ; Si no, procede de forma normal

		; Cargar la direcci¢n base de la
		; tabla de interrupciones
	Mov SI, Offset INT09
	Mov CX, 6

BucleCompara:

		; Obtener la direcci¢n actual en el vector
	Mov AL, CS:[SI].BlqInt.Numero
	Mov AH, 35h
	Int 21h

		; Si no coincide con nuestra propia
	Cmp BX, Word Ptr CS:[SI].BlqInt.NuevoGestor[0]
	Jne NoSePuede   ; direcci¢n es porque se ha
	Mov BX, ES      ; instalado otro programa
		; despu‚s que este, por lo que no es posible
		; llevar a cabo la desinstalaci¢n
	Cmp BX, Word Ptr CS:[SI].BlqInt.NuevoGestor[2]
	Jne NoSePuede

	Add SI, 9 ; Apuntar al siguiente bloque

	Loop BucleCompara ; y repetir

		; Cargar de nuevo la direcci¢n base de la
		; tabla de interrupciones, en este caso
		; para restituir sus valores originales
	Mov SI, Offset INT09
	Mov CX, 6

BucleRestituye:

		; Obtenemos el contenido anterior del
		; vector de interrupci¢n y su n£mero
	Lds DX, CS:[SI].BlqInt.AnteriorGestor
	Mov AL, CS:[SI].BlqInt.Numero

	Mov AH, 25h ; restituy‚ndolo
	Int 21h

	Add SI, 9 ; Apuntar al siguiente bloque

	Loop BucleRestituye ; y repetir

	Clc  ; Desactivar el flag de acarreo para
	Jmp Salir ; indicar que todo fue bien y volver

NoSePuede:

	Stc     ; Activar el indicador de acarreo

Salir:

    Mov AX, CONFIRMACION ; Devolver otro c¢digo
	Mov BX, CS:[PSPResidente] ; y el segmento del PSP

    Iret ; Volver 

NoLoEs: ; La llamado no es para nosotros

		; Saltar al siguiente gestor de la lista
	Jmp CS:INT2F.AnteriorGestor

Gestor2F Endp

    ;-----------------------------------------
    ; Gestor de la interrupci¢n de Ctrl+Break
    ;-----------------------------------------
Gestor1B Proc
    Iret  ; Simplemente ignoramos
Gestor1B Endp

    ;-----------------------------------------
    ; Gestor de la interrupci¢n de Ctrl+C
    ;-----------------------------------------
Gestor23 Proc
    Iret  ; Simplemente ignoramos
Gestor23 Endp

    ;-------------------------------------------
    ; Gestor de la interrupci¢n de error cr¡tico
    ;-------------------------------------------
Gestor24 Proc
    Mov AL, 3 
	Iret
Gestor24 Endp

    ;-------------------------------------------
    ; Este procedimiento se encarga de hacer
    ; todas las comprobaciones necesarias para
    ; saber si hay que activar la parte residente
    ; y si es seguro hacerlo en este momento.
    ;-------------------------------------------
CompruebaEstado Proc
    Push ES   ; Preservar los registros a modificar
	Push SI
    Push AX
    Push BX

	Mov AL, CS:[Activar]
	Or AL, AL   ; Comprobar si est  a 1 el indicador
	Jz NoActivar ; en caso contrario no activar

	Mov AL, CS:[Activado]
	Or AL, AL ; Comprobar si el programa est  activo
    Jnz NoActivar ; de ser as¡ no continuar

        ; Cargamos en ES:BX la direcci¢n almacenada
        ; en InDOS
    Mov AX, Word Ptr CS:[InDos+2]
    Mov ES, AX
    Mov BX, Word Ptr CS:[InDos]

    Mov AL, ES:[BX-1] ; Cargar en AL el indicador ErrorMode
	Or AL, AL
	Jnz NoActivar ; Si est  activado no continuar

	Mov AL, CS:[InBios]
	Or AL, AL   ; Si hay alg£n servicio BIOS en curso
	Jnz NoActivar  ; no continuar

	Mov AL, CS:[EnInt28] ; Si la llamada es desde INT28
    Or AL, AL
    Jnz SiActivar  ; Se puede activar

    Mov AL, ES:[BX] ; en caso contrario mirar el InDos
    Or AL, AL ; Si no est  a cero
    Jnz NoActivar ; no se puede activar

SiActivar: ; La activaci¢n es posible

	Clc ; Poner a cero el carry
    Jmp SalirComprobacion

NoActivar: ; La activaci¢n no es posible

	Stc ; Indicar que no se debe activar

SalirComprobacion:

    Pop BX
    Pop AX
	Pop SI  ; Recuperar registros
    Pop ES

    Ret ; y volver

CompruebaEstado Endp

    ;-----------------------------------------
    ; Este procedimiento se encarga de hacer
    ; todo lo necesario para poner en marcha
    ; la parte residente, activando su pila,
    ; su PSP, etc.
    ;-----------------------------------------
ActivarResidente Proc

	Mov CS:[Activar], 0 ; Poner a cero el indicador
	Mov CS:[Activado], 1 ; Indicar que est  activo

		;-------------------------------
		; Intercambiar la pila y el PSP
		;-------------------------------
	Cli     ; Desactivar interrupciones mientras
			; cambiamos la pila

		; Preservar la direcci¢n de la pila
		; del otro programa
    Mov Word Ptr CS:[PilaAnterior], SP
    Mov Word Ptr CS:[PilaAnterior+2], SS

		; Fijar nuestra propia pila
    Lss SP, CS:[PilaResidente]

    Sti

    Push DS ; Preservar los valores de los registros
    Push ES ; que se van a ver afectados
    Push AX
    Push BX
    Push CX
    Push DX
    Push SI
    Push DI
    
    Mov AH, 51h     ; Obtener segmento del PSP activo
    Int 21h
    Mov CS:[PSPAnterior], BX ; Guardarlo

    Mov BX, CS:[PSPResidente] ; Fijar nuestro PSP
    Mov AH, 50h
    Int 21h

        ; Modificar los vectores de interrupci¢n de
        ; Ctrl-Break, Ctrl-C y error cr¡tico

    Mov CX, 3  ; Son tres vectores
    Mov SI, Offset INT1B ; a partir de INT1B

BucleInt1:

    Mov AL, CS:[SI].BlqInt.Numero
    Mov AH, 35h  ; Obtenemos el contenido 
    Int 21h     ; actual del vector

        ; y lo guardamos
    Mov Word Ptr CS:[SI].BlqInt.AnteriorGestor[0], BX
    Mov Word Ptr CS:[SI].BlqInt.AnteriorGestor[2], ES

        ; Cargamos en DS:DX la direcci¢n de
        ; nuestro propio gestor
    Mov DX, Word Ptr CS:[SI].BlqInt.NuevoGestor[0]
    Mov DS, Word Ptr CS:[SI].BlqInt.NuevoGestor[2]
    Mov AH, 25h ; y la escribimos en el vector
    Int 21h

    Add SI, 9   ; Pasar al siguiente bloque
    Loop BucleInt1 ; y continuar

    Mov AX, SEGMENTO_BIOS ; Mirar si estamos
    Mov ES, AX  ; en el modo de v¡deo adecuado
    Cmp Byte Ptr ES:[MODO_VIDEO], 3
    Je ModoAdecuado

    Mov CL, 10
    Call Pitido ; Si no es as¡ provocar un pitido
    Jmp ModoNoAdecuado ; y no continuar

ModoAdecuado:

        ; Obtener en SI la direcci¢n en la que
        ; se almacena la posici¢n del cursor
    Mov SI, 50h
    Mov AL, Byte Ptr ES:[PAGINA_VIDEO]
    Mov CS:[PaginaActiva], AL
    Xor AH, AH
    Add SI, AX

        ; Obtener la posici¢n del cursor
    Mov AX, ES:[SI]
    Mov CS:[Cursor], AX ; y guardarla

        ; Cargamos en CX el n£mero de bytes
    Mov CX, BYTES_PANTALLA

        ; Cargamos en SI el desplazamiento
        ; en el segmento de memoria de v¡deo
        ; de la p gina actual
    Mov SI, ES:[OFFSET_PAGINA_ACTUAL]
    Mov CS:[OffsetPagina], SI

    Mov AX, SEG_PANTALLA ; DS:SI apuntan al contenido
    Mov DS, AX  ; actual de la pantalla

    Mov AX, Seg Pantalla
    Mov ES, AX  ; ES:DI apuntan a nuestro bloque
    Mov DI, Offset Pantalla  ; de memoria

    Cld ; Copiar hacia adelante

    Rep Movsb   ; todo el contenido

    Call TablaAscii ; Mostrar la tabla ASCII

        ; Realizamos la operaci¢n inversa,
        ; restituyendo el contenido de la pantalla

    Mov AX, SEGMENTO_BIOS
    Mov ES, AX

        ; Obtenemos de nuevo el tama¤o en bytes
    Mov CX, BYTES_PANTALLA

        ; y el desplazamiento de la p gina activa
        ; en el segmento de memoria de v¡deo
    Mov DI, ES:[OFFSET_PAGINA_ACTUAL]

    Mov AX, SEG_PANTALLA
    Mov ES, AX  ; ES:DI apuntan ahora a la p gina
                ; actual de v¡deo

    Mov AX, Seg Pantalla
    Mov DS, AX  ; DS:SI apuntan a nuestro bloque, 
    Mov SI, Offset Pantalla ; que tiene los datos

    Cld ; Copiar hacia adelante

    Rep Movsb   ; todo el contenido

        ; Restituir la posici¢n del cursor
    Mov DX, CS:[Cursor]
    Mov AH, 2
    Mov BH, CS:[PaginaActiva]
    Int 10h

ModoNoAdecuado:

        ; Una vez que hemos terminado debemos dejar
        ; el sistema tal y como lo encontramos al
        ; provocar la interrupci¢n.

    Mov CX, 3       ; Restituimos los tres vectores
    Mov SI, Offset INT1B

BucleInt2:

        ; Cargamos en AL el n£mero de interrupci¢n
    Mov AL, CS:[SI].BlqInt.Numero
        ; y en DS:DX la direcci¢n del gestor original
    Mov DX, Word Ptr CS:[SI].BlqInt.AnteriorGestor[0]
    Mov DS, Word Ptr CS:[SI].BlqInt.AnteriorGestor[2]

    Mov AH, 25h ; lo escribimos en el vector
    Int 21h

    Add SI, 9   ; Pasar al siguiente bloque
    Loop BucleInt2 ; y repetir

    Mov BX, CS:[PSPAnterior] ; Dejamos el PSP anterior
    Mov AH, 50h
    Int 21h

    Pop DI      ; Recuperamos el contenido 
    Pop SI      ; de los registros
    Pop DX
    Pop CX
    Pop BX
    Pop AX
    Pop ES
    Pop DS

    Cli
    Lss SP, CS:[PilaAnterior] ; Recuperamos la pila
    Sti

    Mov CS:[Activado], 0 ; y terminamos
    Ret

ActivarResidente Endp

    ;----------------------------------------
    ; Al final de todo el c¢digo que quedar 
    ; residente definimos el espacio de pila.
    ;----------------------------------------
EspacioDePila   Db  TAMANO_PILA Dup(?)
 EtiquetaPila:

    ;------------------------------------------
    ; Este procedimiento ser  el que se ejecute
    ; al cargar el programa desde la l¡nea de
    ; comandos del DOS. A diferencia del resto
    ; del c¢digo, esta parte no quedar  residente.
    ;------------------------------------------
Instalar Proc

    Push CS
    Pop DS      ; DS apuntando al segmento de c¢digo

        ; Preservamos el segmento del PSP
    Mov [PSPResidente], ES

        ; Cargar en CX la longitud de la l¡nea
        ; de comando, tomada del PSP
    Xor CH, CH
    Mov CL, ES:[80h]

    Or CL, CL       ; Si la longitud es cero
    Jz NoHayOpciones ; es que no hay opciones

        ; Mirar a partir del primer car cter
        ; de la l¡nea de comandos
    Mov DI, 81h
    Mov AL, '/' ; Car cter a buscar

    RepNe Scasb ; Buscar

        ; Si no se encuentra la barra es que
        ; no hay opciones
    Jnz NoHayOpciones

        ; Mirar si hay una 'D' detr s de la barra
    Cmp Byte Ptr ES:[DI], 'D'
    Jne NoHayOpciones ; Si no es as¡ seguir

        ;--------------------------------
        ; Si se llega a este punto es
        ; porque se quiere desinstalar
        ; el programa
        ;--------------------------------
    Mov AH, ID_PROGRAMA ; Comprobar si est  instalado
    Xor AL, AL
    Int 2Fh

    Cmp AX, CONFIRMACION
    Jne NoInstalado ; Si no es as¡ salir

        ; Si est  instalado guardamos el segmento
        ; del PSP, que se nos ha devuelto en BX
    Push BX

        ; Indicamos a la parte que est 
        ; residente que restituya los vectores
        ; de interrupci¢n modificados.
    Mov AH, ID_PROGRAMA
    Mov AL, 1
    Int 2Fh

        ; Si no es posible restituir los vectores
        ; de interrupci¢n no podemos desinstalar
    Jc NoSePuedeDesinstalar

    Pop BX ; Recuperamos el segmento del PSP

    Mov DS, BX
        ; Obtenemos el segmento de entorno
    Mov ES, DS:[SEG_BLOQUE_ENTORNO] 

    Mov AH, 49h ; y liberamos la memoria que ocupa
    Int 21h
    Jc Fallo1 ; En caso de fallo no continuar

        ; A continuaci¢n liberamos el bloque
        ; de memoria que est  ocupando la
        ; parte residente.
    Mov ES, BX
    Mov AH, 49h
    Int 21h
    Jc Fallo2

        ; Indicar que todo fue correcto y
        ; se complet¢ la desinstalaci¢n
    Mov DX, Offset Msg3
    Jmp Imprimir

Fallo1:

        ; Indicamos mediante un mensaje el error
        ; que se ha producido
    Mov DX, Offset Msg5
    Jmp Imprimir

Fallo2:

    Mov DX, Offset Msg6
    Jmp Imprimir

NoSePuedeDesinstalar:

        ; Descartamos el valor que hab¡amos almacenado
        ; antes en la pila
    Pop DX  

    Mov DX, Offset Msg4
    Jmp Imprimir

NoInstalado:

        ; Si el programa no est  instalado no
        ; es posible desinstalar
    Mov DX, Offset Msg2
    Jmp Imprimir

    ;-------------------------------------------
    ; A parti de este punto nos encontramos con
    ; el proceso que se ejecutar  en caso de que
    ; no se haya intentado la desinstalaci¢n, y
    ; por lo tanto lo que se quiere es instalar
    ; el programa.
    ;-------------------------------------------
NoHayOpciones:

    Mov AH, ID_PROGRAMA ; Comprobamos si ya 
    Int 2Fh             ; est  instalado
    Cmp AX, CONFIRMACION

        ; En caso afirmativo no permitimos
        ; la reinstalaci¢n
    Je YaInstalado

        ; Si no est  instalado procedemos con el
        ; proceso de instalaci¢n

        ; Guardar la direcci¢n de la pila de
        ; la parte que quedar  residente
    Mov Word Ptr [PilaResidente], Offset EtiquetaPila
    Mov Word Ptr [PilaResidente+2], Seg EtiquetaPila

    Mov AH, 34h ; Obtenemos la direcci¢n del InDos
    Int 21h

    Mov Word Ptr [InDos], BX ; y la guardamos
    Mov Word Ptr [InDos+2], ES

        ; A continuaci¢n obtenemos el contenido
        ; actual de los vectores de interrupci¢n
        ; y los modificamos, haciendo que apunten
        ; a nuestros gestores.

    Mov CX, 6  ; Modificar seis vectores
    Mov SI, Offset INT09    ; Direcci¢n del primer bloque

BucleInt:

        ; Cargamos en AL el n£mero del vector
    Mov AL, [SI].BlqInt.Numero
    Mov AH, 35h
    Int 21h ; y obtenemos el contenido actual

        ; Salvamos la direcci¢n
    Mov Word Ptr [SI].BlqInt.AnteriorGestor[0], BX
    Mov Word Ptr [SI].BlqInt.AnteriorGestor[2], ES

        ; Obtener la direcci¢n del nuevo gestor
    Mov DX, Word Ptr [SI].BlqInt.NuevoGestor[0]
    Mov AH, 25h
    Int 21h ; y escribirla en el vector

    Add SI, 9   ; Saltar al siguiente bloque
    Loop BucleInt

        ; Mostramos el mensaje indicando
        ; que la instalaci¢n se ha completado
    Mov DX, Offset MsgInstalado
    Mov AH, 9
    Int 21h

        ; Calcular el tama¤o a dejar residente
    Mov DX, Offset Instalar
    Mov CL, 4
    Shr DX, CL
    Inc DX
    Add DX, 16

    Mov AX, 3100h ; Salir y quedar residente

    Int 21h

YaInstalado:  ; Si el programa ya est  instalado

    Mov DX, Offset Msg ; indicarlo con un mensaje

Imprimir:

    Mov AX, Seg Msg ; Obtener la direcci¢n del mensaje
    Mov DS, AX
    Mov AH, 9
    Int 21h ; y mostrarlo

    Mov AH, 4Ch ; Devolver el control al DOS
    Int 21h

Instalar EndP

    ; Mensajes de indicaci¢n y error

Msg  Db "El programa ya est  instalado$"
Msg2 Db "El programa no est  instalado$"
Msg3 Db "El programa ha sido desinstalado$"
Msg4 Db "No es posible desinstalar el programa$"
Msg5 Db "Fallo en liberaci¢n del bloque de entorno$"
Msg6 Db "Fallo en liberaci¢n del bloque principal$"
MsgInstalado Db "TBLASCII 1.0  ¸ 1996-2002 Francisco Charte"
             Db 13, 10
             Db "Activaci¢n con ALT-T", 13, 10
             Db "<ESC> cierra la tabla", 13, 10
             Db "<INSERT> insertar car cter", 13, 10
             Db "Desinstalaci¢n con la opci¢n /D"
             Db 13, 10, "$"
    End
