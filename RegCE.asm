; Proyecto en TASM 8086


.MODEL SMALL
.STACK 100h


DATA_SEG    SEGMENT ; Inicia el segmento de datos, para almacenar mensajes estaticos y variables relacionadas a las operaciones
    ;Variables de mensajes
    MENU db 10,13,10, "Digite:", 0ah,"", 0ah, "1. Ingresar calificaciones (15 estudiantes -Nombre Apellido1 Apellido2 Nota-)", 0ah, "2. Mostrar estadisticas.", 0ah, "3. Buscar estudiante por posicion (indice)", 0ah, "4. Ordenar calificaciones (ascendente/descendente).", 0ah, "5. Salir", 0ah, "$"
    WELC_MSG db 0ah, 0dh, "***************  Bienvenido a RegistroCE  ***************", 0ah,"",0ah, "$"
    EXIT_MSG db 0ah, 0dh, "", 0ah,"*************  Gracias por usar RegistroCE  *************",0ah, "$" 
    
    MSG1    DB  10,13,10,'Digite 1 para ingresar a su estudiante o digite 9 para salir al menu principal $' 
    MSG2    DB  10,13,10,'El promedio de notas de los estudiantes ingresados es: $'
    MSG3    DB  13,10,'La nota maxima es: $'
    MSG4    DB  13,10,'La nota minima: $'
    MSG5    DB  13,10,'La cantidad de estudiantes aprobados es: $'
    MSG6    DB  13,10,'    Porcentaje(%) $'
    MSG7    DB  13,10,'La cantidad de estudiantes reprobados es: $'
    MSG8    DB  13,10,'    Porcentaje(%) $'
    MSG9    DB  10,13,10,'Digite numero de estudiante a mostrar $'
    MSG10   DB  10,13,10, "Como desea ordenar las calificaciones:", 0ah,"", 0ah, "1. Orden Descendente.", 0ah, "2. Orden Ascendente.", 0ah, "$"
    MSG11   DB  10,13,10, "LLEGO aqui", 0ah, "$"
    MSG12   DB  10,13,10, "Su estudiante se registro correctamente", 0ah, "$"
    MSG13   DB  "0", 0ah, "$"
    MSG14   DB  10,13,10, "Estudiantes ingresados: $"
    MSG15   DB  13,10,'Estudiante encontrado: ', '$'
    MAX_ESTUDIANTES db 10,13,'Maximo de estudiantes alcanzado (15). $'
    PROMPT_NOMBRE DB 13,10,'Ingrese nombre completo: $'
    PROMPT_NOTA DB 13,10,'Nota: $'
    ERROR_NOTA db 10,13,'Error: Ingrese una nota valida (0-100):  $'
    ERROR_OP db 10,13,'Error: Ingrese un indice valido dentro del rango permitido: $'
    CONFIRM_1 DB 13,10,'Ingresado -> ', '$'
    SPC DB ' ', '$'
    BLANK_SPACE DB ''
    LABEL_NOTA DB 13,10,'Nota: ', '$'
    CRLF DB 13,10,'$'
    
    K DB 0        ;VARIABLE PARA GUARDAR ESTUDIANTES
    CONT_EST DB 0   ;Cuantos estudiantes est?n registrados
    SUMA_NOTAS DW 0  ; VAriable para guardar el total de la suma de todas las notas registradas
    PROM_NOTAS DW 0  ; variable para guardar el resultado del promedio
    RESIDUO    DB 0  ;residuo del pro medio
    BUFFER_PROM DB "00.0$"   ; Formato predefinido
    
    NOTA DW 0 ;NOTA DE ENTERO
    MUL_FAC    DB  10
    APROBADOS  DB 0
    PRC_AP     DW 0      ;
    INDICADOR  DB 0    ;Sirve como flag para saber si hubo punto decimal: 0=parte entera, 1=decimal
    ORDEN_OPCION DB 0
    INDICE_OPCION DB 0 ;
    
    
    ESTUDIANTES_R DB 15 DUP(43 DUP(0)) ;Arreglo de todos los estudiantes, sin nota
    NOTAS_ARR DB 15 DUP (2 DUP(0)); Arreglo de las notas de los estudiantes
    NOTASF_ARR DB 15 DUP (3 DUP (0))
    NAME_BUF DB 42,0,42 DUP(0) 
    NOTA_FLOTANTE DB 5,0,5 DUP(0)
 
    
DATA_SEG    ENDS

CODE_SEG    SEGMENT
   ASSUME CS: CODE_SEG, DS:DATA_SEG
    START:  MOV     AX, DATA_SEG
            MOV     DS, AX

    INITIAL_MSG:
            MOV     AH, 09
            MOV     DX, OFFSET WELC_MSG 
            INT     21H
            
    MENU_LOOP:
            LEA DX, MENU       ; carga la direccion del mensaje MENU en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS

            MOV AH, 01H        ; lee un caracter del teclado
            INT 21H            ; llama a la interrupcion 21H de DOS

            SUB AL, 30H        ; convierte el caracter ingresado por el usuario ASCII a su equivalente num?rico
            
            CMP AL, 1          ; compara el valor ingresado con 1
            JE ITS_ENTER_GRADES    ; salta a ENTER_GRADES si es igual a 1
            CMP AL, 2          ; compara el valor ingresado con 2
            JE ITS_STATISTICS   ; salta a ITS_STATISTICS si es igual a 2
            CMP AL, 3          ; compara el valor ingresado con 3
            JE ITS_INDEX_SEARCH  ; salta a ITS_INDEX_SEARCH si es igual a 3
            CMP AL, 4          ; compara el valor ingresado con 4
            JE ITS_SORT_CAL    ; salta a ITS_SORT_CAL si es igual a 4
            CMP AL, 5          ; compara el valor ingresado con 5
            JMP EXIT_PROGRAM   ; salta a EXIT_PROGRAM si es igual a 5
    
    ;Para evitar el excedente de bytes
ITS_ENTER_GRADES:
    JMP ENTER_GRADES       ; salta a ingresar calificaciones
ITS_STATISTICS:
    JMP STATISTICS      ; salta a estadisticas
ITS_INDEX_SEARCH:
    JMP INDEX_SEARCH     ; salta a buscar por indice
ITS_SORT_CAL:
    JMP SORT_CAL       ; salta a ordnar calificaciones
    
            
    ;//////////////////////////////////////////////////////////////// INGRESAR CALIFICACION ////////////////////////////////////////////////////////////           
    MAXIMO_ALCANZADO:
            LEA DX, MAX_ESTUDIANTES
            MOV AH, 09H
            INT 21H
            JMP MENU_LOOP
    
    ENTER_GRADES:
            MOV AL, CONT_EST    ; Mueve a Al la cantidad de estudiantes
            CMP AL, 15
            JAE MAXIMO_ALCANZADO
            
            LEA DX, MSG1       ; carga la direccion del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
                
            MOV AH, 01H        ; lee un caracter del teclado
            INT 21H            ; llama a la interrupcion 21H de DOS
            SUB AL, 30H        ; convierte el caracter ingresado por el usuario ASCII a su equivalente num?rico
                
            CMP AL, 1          ; compara el valor ingresado con 1
            JE REGISTRO    ; salta a REGISTER si es igual a 1
            CMP AL, 9          ; compara el valor ingresado con 2
            JE MENU_LOOP   ; salta al menu si es 9     
    
    REGISTRO:     
         ; ===== Nombre =====
            LEA DX, PROMPT_NOMBRE    ;carga la direccion del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, NAME_BUF
            MOV AH, 0Ah ; leer cadena (buffer estilo 0Ah)
            INT 21h
            
            ;  Eco de lo ingresado (convierte buffers 0Ah a '$' y los imprime)
            LEA DX, CONFIRM_1
            MOV AH, 09h
            INT 21h
            
            ; Imprime: Nombre Apellido1 Apellido2
            LEA DX, NAME_BUF           ;Pasa a DX el contenido de NAME_BUF
            CALL PrintInputBuffer      ; Imprime el nombre
            LEA DX, SPC
            MOV AH, 09h
            INT 21h
            
            JMP ESCRIBIR_NOTA         ; Llamar a funcion que pide la nota

    ; ////////////////// Pedir la nota ////////////////       
    ESCRIBIR_NOTA:
            
            ; ===== Nota (texto) =====
            LEA DX, PROMPT_NOTA
            MOV AH, 09h
            INT 21h
            
            CALL LEER_CONVRT_NOTA ; Convertir el decimal en entero
            MOV NOTA, AX          ; El resultado moverlo a NOTA
            JMP GUARDAR_DATOS     ; Ir a guardar el nombre y las notas
            
   ; Leer cadena del usuario
   LEER_CONVRT_NOTA PROC
            PUSH DX
            PUSH SI
            
            LEA DX, NOTA_FLOTANTE
            MOV AH, 0Ah
            INT 21h
            
            ; Convertir a numero normalizado
            LEA SI, NOTA_FLOTANTE + 2  ; Saltar bytes de control
            CALL CONVERTIR_NOTA
            
            POP SI
            POP DX
            RET     ; Retorna al flujo de escribir nota
    LEER_CONVRT_NOTA ENDP   


   CONVERTIR_NOTA PROC
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        
        MOV AX, 0              ; Resultado final
        MOV CX, 10             ; Base 10
        MOV DH, 0              
        MOV BH, 0              ; Contador de digitos

    CONVERT_LOOP:
        MOV DL, [SI]           ; Leer caracter
        CMP DL, 0Dh            ; Ve el enter
        JE FIN_CONVERSION
        CMP DL, '$'            ; Verifica si es el fin de la cadena
        JE FIN_CONVERSION
        CMP DL, 0              ; Verifica si es el fin de la cadena
        JE FIN_CONVERSION
        
        ; Verificar si es punto decimal
        CMP DL, '.'
        JE PUNTO_DECIMAL
        
        ; Verificar que es digito (0-9)
        CMP DL, '0'
        JB NOTA_INVALIDA
        CMP DL, '9'
        JA NOTA_INVALIDA
        
        ; Convertir ASCII a numero
        SUB DL, '0'            ; DL = numero (0-9)
        
        ; Acumular en resultado
        MOV BL, DL             ; Mueve a BL lo guardado en BL
        MOV BH, 0
        MUL CL                 ; AX = AX * 10
        ADD AX, BX             ; AX = AX + digito
        
        ; Verificar maximo 3 d?gitos antes del punto
        CMP CH, 0              ; Si aun esta en parte entera
        JNE CHECK_DECIMAL_DIGITS
        CMP AX, 1000
        JAE NOTA_INVALIDA
        JMP SIGUIENTE

    CHECK_DECIMAL_DIGITS:
        ; Maximo 1 digito decimal
        CMP BH, 1              ; BH = contador de decimales
        JAE NOTA_INVALIDA      ; Maximo 1 digito decimal

    PUNTO_DECIMAL:
        MOV CH, 1              ; DH Marcar que estamos en decimales
        JMP SIGUIENTE

    SIGUIENTE:
        INC SI                 ; Siguiente caracter
        INC BH                 ; Incrementar contador de digitos decimales
        JMP CONVERT_LOOP

    FIN_CONVERSION:
        ; Si no tenia decimales, multiplicar por 10
        CMP CH, 0              ; Tuvo punto decimal
        JNE FINALIZAR          ; Si si, ya esta normalizado
        
        ; Si no tenia decimales, multiplicar por 10
        MUL CL                 ; AX = AX * 10

    FINALIZAR:
        CMP AX, 1000           ; Verifica si el numero es mayor a 100
        JA NOTA_INVALIDA
        CMP AX, 0
        JB NOTA_INVALIDA    ; Verifica si es menor a 0
        
        POP SI
        POP DX
        POP CX
        POP BX
        RET                ; Retorna a LEER_CONVRT_NOTA
    CONVERTIR_NOTA ENDP

    NOTA_INVALIDA:
            LEA DX, ERROR_NOTA
            MOV AH, 09h
            INT 21h
            
            LEA DI, NOTA_FLOTANTE    ; DI apunta al buffer
            MOV byte ptr [DI], 6     ; Tamano maximo (6)
            MOV byte ptr [DI+1], 0   ; Caracteres usados (0)
            ADD DI, 2                ; Apuntar al area de datos
            
            ; Limpiar los 6 bytes de datos (llenar con 0's)
            MOV CX, 6           ; 6 bytes a limpiar
            MOV AL, 0           ; Valor para limpiar (0)
            REP STOSB           ; Llenar con ceros
            
            JMP ESCRIBIR_NOTA
  
      GUARDAR_DATOS:
            
            INC CONT_EST ; Incrementar contador de cuantos estudiantes se han guardado
            
            ; K = CONT_EST -1
            MOV AL, CONT_EST ;Movemos a AL el valor del contador
            SUB AL, 1        ;Le restamos 1
            MOV K, AL        ;Guardamos este valor en K
            
            ; ESTRUCTURA: [(indice de estudiante, nombre estudiante), (indice de estudiante, nombre estudiante), ...]
            
            ; //////// Guardar CONT_EST en el primer byte de cada estudiante, ya que es su indice ///////
            ; Calcular posicion en el array: DI = ESTUDIANTES_R + (43 * K)
            MOV AX, 43            ; Bytes por estudiante
            MOV BL, K             ; indice del estudiante
            MUL BL                ; AX = 43 * K
            LEA DI, ESTUDIANTES_R ; DI apunta al inicio del array
            ADD DI, AX            ; DI apunta al estudiante K
            
            ; Guardar indice en el PRIMER byte del estudiante
            MOV AL, BYTE PTR CONT_EST    ; AL = indice (1-15)
            MOV [DI], AL          ; Va a la direccion que tiene guardada DI y guardar el primer byte (posicion 1)
            
            
            ; //////// Guardar el buffer con el nombre que es de tamano 42, pero empezaria en el byte 1
            ;calculo seria: (43*K) + 1
            ADD DI, 1            ;Sumamos 1 para que apunte al nombre del estudiante K
            LEA SI, NAME_BUF + 2 ; Saltar bytes de control del buffer
            MOV CL, NAME_BUF + 1 ; Numero de caracteres leidos
            MOV CH, 0
            
            CMP CX, 0           ; Verificar si hay caracteres
            JE FIN_NOMBRE       ; Si no hay caracteres, saltar
            
        COPIAR_NOMBRE:
            MOV AL, [SI]
            MOV [DI], AL
            INC SI
            INC DI
            LOOP COPIAR_NOMBRE

        FIN_NOMBRE:
            ; DI ahora apunta despu?s del ultimo caracter copiado
            ; Puedes agregar un terminador si lo necesitas
            MOV byte ptr [DI], '$'
                        
            ; Guardar nota e indice en el array de notas
            ; Calcular posicion en el array: DI = ESTUDIANTES_R + (3 * K)
            MOV AX, 3             ; Bytes por estudiante
            MOV BL, K             ; indice del estudiante
            MUL BL                ; AX = 3 * K
            LEA DI, NOTAS_ARR     ; DI apunta al inicio del array
            ADD DI, AX            ; DI apunta al estudiante K
            
            ; Guardar indice en el PRIMER byte del estudiante
            MOV AL, BYTE PTR CONT_EST    ; AL = ?ndice (1-15)
            MOV [DI], AL          ; Va a la direccion que tiene guardada DI y guardar el primer byte (posicion 1)
            
            
            MOV AX, [NOTA] ; AL = valor de la nota (como byte)
            MOV [DI + 1], AX  ; Guardar en la posicion K del array  
            
            JMP LIMPIAR_NOMBRE_BUF
            
     
        LIMPIAR_NOMBRE_BUF:
            LEA DI, NAME_BUF    ; DI apunta al buffer
            MOV byte ptr [DI], 42    ; Tamano maximo (42)
            MOV byte ptr [DI+1], 0   ; Caracteres usados (0)
            ADD DI, 2           ; Apuntar al area de datos
            
            ; Limpiar los 42 bytes de datos (llenar con 0's)
            MOV CX, 42          ; 42 bytes a limpiar
            MOV AL, 0           ; Valor para limpiar (0)
            REP STOSB           ; Llenar con ceros
            
            ;Limpiar tambien el buffer donde se ingresa la nota
            LEA DI, NOTA_FLOTANTE    ; DI apunta al buffer
            MOV byte ptr [DI], 6    ; Tama?o m?ximo (6)
            MOV byte ptr [DI+1], 0   ; Caracteres usados (0)
            ADD DI, 2           ; Apuntar al area de datos
            
            ; Limpiar los 6 bytes de datos (llenar con 0's)
            MOV CX, 6          ; 6 bytes a limpiar
            MOV AL, 0           ; Valor para limpiar (0)
            REP STOSB           ; Llenar con ceros
            
            
            LEA DX, MSG12       ; carga la direccion del mensaje 12 en DX
            MOV AH, 09H        ; prepara AH para la funcion de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            JMP ENTER_GRADES
            
;//////////////////////////////////////////////////////////////// MOSTRAR ESTADISTICAS ////////////////////////////////////////////////////////////////    
    STATISTICS:
            LEA DX, MSG2       ; carga la direccion del mensaje 2 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            JMP PROMEDIO       ; llama a PROMEDIO para conseguir el promedio
            
            ; ///// PROMEIO ////////
        PROMEDIO: 
            ; Hacer la suma de todas las notas            
            MOV CL, CONT_EST      ; CL = numero de estudiantes
            MOV CH, 0             ; CH = 0 entonces CX = CONT_EST
            CMP CX, 0             ; Verificar si hay estudiantes
            JE PROM_ZERO          ; Si no hay, salta a prom cero
            LEA DI, NOTAS_ARR     ; Primer nota del estudiante
            MOV SUMA_NOTAS, 0

        SUMA:
            MOV AX, [DI + 1]     ; Leer nota del estudiante actual 
            ADD SUMA_NOTAS, AX    ; Sumar
            MOV BX, SUMA_NOTAS    ; Debug
            ADD DI, 3            ; Siguiente estudiante
            LOOP SUMA
           
            
            MOV AX, SUMA_NOTAS    ; Pasamos a ax el valor de la suma para poder hacer la division
            MOV BL, CONT_EST      ; Pasamos a bl la cantidad de estudiantes  
            MOV DX, 0             ; Limpiar DX para no danar la division 
            MOV BH, 0             ;Limpiar BH para no danar division
            DIV BX                ; Dividimos SUMA_NOTAS / CONT_EST
              
            MOV PROM_NOTAS, AX    ; Mueve a AX el valor que hay en PROM_NOTAS
            CALL MOSTRAR_PROMEDIO ;Imprime el promedio 

            JMP NOTAS_MAX_MIN
            
        PROM_ZERO:
            LEA DX, MSG13       ; carga la direccion del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            JMP MENU_LOOP
            
        MOSTRAR_PROMEDIO PROC

            PUSH AX
            PUSH BX
            PUSH DX
            
            MOV AX, PROM_NOTAS  ; AX = 666 (66.6)
            
            ; Separar parte entera y decimal
            MOV BL, 10
            DIV BL                  ; AL = 66 (parte entera), AH = 6 (decimal)
            
            ; Mostrar parte entera
            PUSH AX                 ; Guardar AX (AH tiene el decimal)
            MOV AH, 0              ; AL = parte entera
            CALL MOSTRAR_NUM_N       ; Mostrar esa parte entera
            
            ; Mostrar punto decimal
            MOV DL, '.'
            MOV AH, 02h
            INT 21h
            
            ; Mostrar parte decimal
            POP AX                 ; Recuperar AX
            MOV AL, AH             ; AL = parte decimal (6)
            CALL MOSTRAR_NUM_N       ; Mostrar parte decimal si existe           
            
            POP DX
            POP BX
            POP AX
            RET
     MOSTRAR_PROMEDIO ENDP
            
            ;NOTAS MAXIMAS Y MINIMAS
    NOTAS_MAX_MIN:
            LEA DX, MSG3       ; carga la direccion del mensaje 3 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            
            CALL BUBBLE_SORT_NOTAS     ; llama al bubble sort para que ordene las notas de forma descendente
            LEA DI, NOTAS_ARR          ; DI apunta al array
            MOV AX, [DI + 1]
            ;MOV NOTA_MAX, AL
            CALL MOSTRAR_NOTA
            
            LEA DX, MSG4       ; carga la direccion del mensaje 4 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            MOV AL, CONT_EST       ; numero de estudiantes
            DEC AL                 ; AL = ultimo indice
            MOV BL, AL
            MOV BH, 0              ; BX = ultimo indice
            
            MOV AX, 3              ; Cada elemento ocupa 3 bytes
            MUL BX                 ; AX = 3 * ultimo_undice
            MOV BX, AX             ; BX = offset del ultimo elemento
            
            MOV AX, [DI + BX + 1]  ;  Nota del ultimo elemento
            ;MOV NOTA_MIN, AL
            CALL MOSTRAR_NOTA
            
            JMP ESTS_APROBADOS
     
    ESTS_APROBADOS:
           ; Hacer la comparacion de nota >= 70           
            MOV CL, CONT_EST      ; CL = numero de estudiantes
            MOV CH, 0             ; CH = 0 entonces CX = CONT_EST
            LEA DI, NOTAS_ARR     ; Primer nota del estudiante
            MOV APROBADOS, 0
            MOV BL, 0

        COMPARACION:
            MOV AX, [DI + 1]     ; Leer nota del estudiante actual
            CMP AX, 700
            JB  APR_REP          ;Como el array esta ordenado, a la hora de verificar una nota <70, podemos sacar todos los calculos
            INC APROBADOS
            ADD DI, 3            ; Siguiente estudiante
            LOOP COMPARACION  
     
        APR_REP: 
            LEA DX, MSG5       ; carga la direccion del mensaje 5 en DX
            MOV AH, 09H        ; prepara AH para la funcion de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS 
          
            MOV AL, APROBADOS  ;Mover APROBADOS a AL para usarlo en MOSTRAR_NUM
            CALL MOSTRAR_NUM_N
            
            MOV AL, APROBADOS   ;mueve a AL APROBADOS
            CALL CALCULAR_PORCENTAJE
            
            LEA DX, MSG6       ; carga la direccion del mensaje 6 en DX
            MOV AH, 09H        ; prepara AH para la funcion de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS 
            
            CALL MOSTRAR_PORCENTAJE
            
            ;CARGA ESTUDIANTES REPROBADOS
            LEA DX, MSG7       ; carga la direccion del mensaje 7 en DX
            MOV AH, 09H        ; prepara AH para la funcion de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS 
            
            MOV AL, CONT_EST   ; Movemos a AL la cantidad totales de estudiantes
            SUB AL, APROBADOS  ; HACEMOS REP = CONT_EST - APROBADOS
            CALL MOSTRAR_NUM_N
            
            LEA DX, MSG8       ; carga la direccion del mensaje 8 en DX
            MOV AH, 09H        ; prepara AH para la funcion de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS 
            
            MOV BX, 1000       ;Movemos 1000 a BX
            SUB BX, PRC_AP     ; Hacemos BX = 1000 - PRC_AP
            MOV PRC_AP, BX     ; Este valor seria el de los reprobados
            
            CALL MOSTRAR_PORCENTAJE   ;Lo mostramos en pantalla
            
            
            JMP MENU_LOOP
            
    
    ; CALCULAR EL PORCENTAJE
    CALCULAR_PORCENTAJE PROC
            PUSH AX
            PUSH BX
            PUSH DX
            
            MOV AH, 0              ; AX = APROBADOS
            MOV BX, 1000           ; 1000 para un decimal
            MUL BX                 ; DX:AX = APROBADOS * 1000
            
            ; Dividir por CONT_EST
            MOV BL, CONT_EST
            MOV BH, 0              ; BX = CONT_EST
            DIV BX                 ; AX = resultado, DX = residuo
            
            MOV PRC_AP, AX ; Guardar porcentaje * 10
         
            POP DX
            POP BX
            POP AX
            RET
    CALCULAR_PORCENTAJE ENDP        
    
    
    MOSTRAR_PORCENTAJE PROC
            PUSH AX
            PUSH BX
            PUSH DX
            
            MOV AX, PRC_AP  ; AX = 666 (66.6%)
            
            ; Separar parte entera y decimal
            MOV BL, 10
            DIV BL                  ; AL = 66 (parte entera), AH = 6 (decimal)
            
            ; Mostrar parte entera
            PUSH AX                 ; Guardar AX (AH tiene el decimal)
            MOV AH, 0              ; AL = parte entera
            CALL MOSTRAR_NUM_N       ; Mostrar esa parte entera
            
            ; Mostrar punto decimal
            MOV DL, '.'
            MOV AH, 02h
            INT 21h
            
            ; Mostrar parte decimal
            POP AX                 ; Recuperar AX
            MOV AL, AH             ; AL = parte decimal (6)
            CALL MOSTRAR_NUM_N       ; Mostrar parte decimal si existe
            
            ; Mostrar simbolo de porcentaje
            MOV DL, '%'
            MOV AH, 02h
            INT 21h
            
            POP DX
            POP BX
            POP AX
            RET
    MOSTRAR_PORCENTAJE ENDP
    
    
            
            ; ///////// SUBRUTINA PARA HACER BUBBLE SORT /////////        
    BUBBLE_SORT_NOTAS PROC
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DX
            PUSH SI
            PUSH DI
            
            MOV CL, CONT_EST           ; comparaciones conforme al numero de est ingresados
            MOV CH, 0
            LEA SI, NOTAS_ARR          ; SI apunta al array
        
        OUTER_LOOP:
            MOV DX, CX                 ; Contador interno
            LEA SI, NOTAS_ARR          ; Reiniciar puntero
            MOV DI, 0                  ; Flag de cambios
        
        INNER_LOOP:
            ; Comparar directamente en memoria
            MOV AX, [SI + 1]           ; Nota actual
            CMP AX, [SI + 4]           ; Comparar con nota siguiente 
            JAE NO_SWAP                ; Si actual >= siguiente, no swap
            
            ; Swap de indices
            MOV AL, [SI]
            XCHG AL, [SI + 3]
            MOV [SI], AL
            
            ; Swap de notas
            MOV AX, [SI + 1]
            XCHG AX, [SI + 4]
            MOV [SI + 1], AX
            
            MOV DI, 1                  ; Hubo cambio
        
        NO_SWAP:
            ADD SI, 3                  ; Siguiente elemento (+3 bytes)
            DEC DX
            JNZ INNER_LOOP
            
            CMP DI, 0                  ; ?Hubo cambios?
            JE SORT_DONE               ; Si no, terminar
            
            LOOP OUTER_LOOP
        
        SORT_DONE:
            POP DI
            POP SI
            POP DX
            POP CX
            POP BX
            POP AX
            RET
        BUBBLE_SORT_NOTAS ENDP
  
        
    MOSTRAR_NOTA PROC
            PUSH AX
            PUSH BX
            PUSH DX
            
            ; Separar parte entera y decimal
            MOV BL, 10
            DIV BL                  ; AL = 66 (parte entera), AH = 6 (decimal)
            
            ; Mostrar parte entera
            PUSH AX                 ; Guardar AX (AH tiene el decimal)
            MOV AH, 0              ; AL = parte entera
            CALL MOSTRAR_NUM_N       ; Mostrar esa parte entera
            
            ; Mostrar punto decimal
            MOV DL, '.'
            MOV AH, 02h
            INT 21h
            
            ; Mostrar parte decimal
            POP AX                 ; Recuperar AX
            MOV AL, AH             ; AL = parte decimal (6)
            CALL MOSTRAR_NUM_N       ; Mostrar parte decimal si existe
            
            
            POP DX
            POP BX
            POP AX
            RET
    MOSTRAR_NOTA ENDP

 ; ////// SUBRUTINA PARA MOSTRAR NUMEROS        
 MOSTRAR_NUM_N PROC
            ; AL = numero (0-100)
            PUSH AX
            PUSH BX
            PUSH DX
            
            MOV AH, 0
            CMP AL, 10
            JB UN_DIGITO          ; Si < 10, mostrar un d?gito
            CMP AL, 100
            JE CIEN               ; Si = 100, mostrar "100"
            
            ; Mostrar dos d?gitos (10-99)
            MOV BL, 10
            DIV BL               ; AL = decenas, AH = unidades
            ADD AX, 3030h        ; Convertir ambos a ASCII
            MOV DX, AX           ; DL = decenas, DH = unidades
            MOV AH, 02h
            INT 21h              ; Mostrar decenas
            MOV DL, DH
            INT 21h              ; Mostrar unidades
            JMP FIN_MOSTRAR
            
        UN_DIGITO:
            ADD AL, '0'          ; Convertir a ASCII
            MOV DL, AL
            MOV AH, 02h
            INT 21h
            JMP FIN_MOSTRAR
            
        CIEN:
            MOV DL, '1'
            MOV AH, 02h
            INT 21h
            MOV DL, '0'
            INT 21h
            MOV DL, '0'
            INT 21h

        FIN_MOSTRAR:
            POP DX
            POP BX
            POP AX
            RET
            MOSTRAR_NUM_N ENDP 

        
    
;//////////////////////////////////////////////////////////////// BUSCAR ESTUDIANTE POR POSICION //////////////////////////////////////////////////////   
    INDEX_SEARCH:
            LEA DX, MSG14          ; carga la direccion del mensaje 9 en DX
            MOV AH, 09H           ; prepara AH para la funcion de servicio de DOS para imprimir una cadena de caracteres
            INT 21H               ; llama a la interrupcion 21H de DOS
            MOV INDICE_OPCION, 0  ; Hacer la opcion 0
            
            MOV AL, CONT_EST
            CALL MOSTRAR_NUM_N
            
            LEA DX, MSG9          ; carga la direccion del mensaje 9 en DX
            MOV AH, 09H           ; prepara AH para la funcion de servicio de DOS para imprimir una cadena de caracteres
            INT 21H               ; llama a la interrupcion 21H de DOS
            
            JMP LEER_OP
        
        LEER_OP:               
            MOV     AH, 01h              ; Funcion para leer un car?cter del teclado
            INT     21h                  ; Llama a la interrupcion 21H de DOS para leer el car?cter
            CMP     AL, 13               ; Verifica si es el car?cter de retorno (ASCII 13)
            JZ      VALIDAR_OP           ; Si es retorno, salta a validar op
            CMP     AL, '0'              ; Compara con el caracter '0'
            JL      OP_INVALIDA          ; Salta a INVALID_INPUT si es menor que '0'
            CMP     AL, '9'              ; Compara con el caracter '9'
            JG      OP_INVALIDA          ; Salta a INVALID_INPUT si es mayor que '9'

            ; Convertir y acumular
            SUB AL, 48                   ; ASCII a numero
            MOV BL, AL
            MOV BH, 0                    ; BX = nuevo d?gito
            
            MOV AL, [INDICE_OPCION]      ; Cargar el VALOR de OPCION
            MOV AH, 0
            MUL MUL_FAC                  ; AX = OP_actual * 10
            ADD AX, BX                   ; AX = (OP_actual * 10) + nuevo_digito
            MOV [INDICE_OPCION], AL      ; Guardar el nuevo valor
            JMP LEER_OP                  ;Para seguir leyendo digitos
            
        OP_INVALIDA:
            LEA DX, ERROR_OP             ; Lee el mensaje de opcion invalida
            MOV AH, 09h
            INT 21h
            
            JMP INDEX_SEARCH
     
        VALIDAR_OP:
            MOV     AL, CONT_EST
            CMP     INDICE_OPCION, AL
            JA      OP_INVALIDA
            CMP     INDICE_OPCION, 1
            JL      OP_INVALIDA
            
            JMP BUSCAR_EN_ARR
            
     BUSCAR_EN_ARR:
            LEA DX, CRLF       ; carga la direccion del mensaje CRLF en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            MOV AL, INDICE_OPCION
            CALL MOSTRAR_NUM_N ; Muestra el numero de indice
            
            LEA DX, SPC       ; carga la direccion del mensaje SPC en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            CALL MOSTRAR_EST
            
            CALL BUSCAR_NOTA
            
            JMP MENU_LOOP
    
    MOSTRAR_EST PROC
            PUSH AX
            PUSH BX
            PUSH DI
            PUSH SI
            
            MOV BL, INDICE_OPCION        ; indice del estudiante
            DEC BL                       ; convertir a base 0 
            MOV BH, 0 
            MOV AX, 43
            MUL BX                       ; AX = 43 * (indice -1)
            LEA DI, ESTUDIANTES_R
            ADD DI, AX
            ADD DI, 1                    ; DI --> Nombre
            
            ; mostrar nombre
            MOV DX, DI 
            MOV AH, 09h
            INT 21h
            
            POP AX
            POP BX
            POP DI
            POP SI
            RET
    MOSTRAR_EST ENDP
    
    BUSCAR_NOTA PROC
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DI
            PUSH SI
            
            ; Hacer la comparacion del indice con el indice que esta asociado a cada nota           
            MOV CL, CONT_EST      ; CL = numero de estudiantes
            MOV CH, 0             ; CH = 0 entonces CX = CONT_EST
            LEA DI, NOTAS_ARR     ; Primer nota del estudiante
            MOV BL, 0

        COMPARACION_INDICE:
            MOV AX, [DI]     ; Leer nota del estudiante actual
            CMP AL, INDICE_OPCION
            JE  NOTA_ENC          ;Compara si el indice es el que estamos buscando
            ADD DI, 3            ; Si no es, pasa a la siguiente nota
            LOOP COMPARACION_INDICE
            
        NOTA_ENC:
            LEA DX, SPC       ; carga la direccion del mensaje SPC en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            MOV AX, [DI +1]
            CALL MOSTRAR_NOTA
            
            POP AX
            POP BX
            POP CX
            POP DI
            POP SI
            RET
    BUSCAR_NOTA ENDP


    
;//////////////////////////////////////////////////////////////// ORDENAR CALIFICACIONES //////////////////////////////////////////////////////////////  
    SORT_CAL:
            LEA DX, MSG10       ; carga la direccion del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funcion de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            MOV AH, 01h
            INT 21h ; AL = '1' o '2'
            SUB AL, 30h ; a valor numerico 1/2
            MOV ORDEN_OPCION, AL ; Para guardar la opcion 
            
            ; LLamar a bubble sort antes de imprimir 
            
            CALL BUBBLE_SORT_NOTAS
            
            ; Borrar la pantalla
            MOV AH, 06h    ; Funcion 06h borrar pantalla
            MOV AL, 0      ; Valor a escribir en la pantalla, 0 para borrar
            MOV BH, 07h    ; Pagina de visualizacion, 07h para la pagina predeterminada
            MOV CX, 0      ; Col/Row desde donde borrar: 0
            MOV DX, 184Fh  ; Col/Row hasta donde borrar, 184Fh para borrar toda la pantalla
            INT 10h        ; interrupcion de video BIOS
            
            ; Mover el puntero a la parte superior izquierda de la pantalla
            MOV AH, 02h    ; Funcion 02h, establece la posicion del cursor
            MOV BH, 0      ; Pagina de visualizacion, 0 para la pagina predeterminada
            MOV DH, 0      ; Fila establecida en 0
            MOV DL, 0      ; Columna establecida en 0
            INT 10h        ; interrupcion de video BIOS
            
            ; Mostrar la lista ordenada
            CALL MOSTRAR_ESTUDIANTES_Y_NOTAS
            
            JMP MENU_LOOP          ;Saltar al menu principal


;////////////////////////////////////////////////////////////////       SUBRUTINAS DE MOSTRAR NOMBRES Y LAS NOTAS //////////////////////////////////////////////////////////

      MOSTRAR_ESTUDIANTES_Y_NOTAS PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI
        
        MOV CL, CONT_EST    ; cantidad de estudiantes (byte)
        MOV CH, 0
        CMP CX, 0
        
        
        ;---- Selecci?n de orden ----
        ; AL = 1 (asc) o 2 (desc), ya listo en SORT_CAL
        MOV AL, ORDEN_OPCION
        CMP AL, 1
        JE ASCENDENTE
        CMP AL, 2
        JE DESCENDENTE
        
    ASCENDENTE:
        LEA SI ,NOTAS_ARR    ; SI apunta al inicio 
        JMP IMPRIMIR_LISTA
        
    DESCENDENTE: 
        ; calcular posicion del ultimo estudiante
        MOV BL, CONT_EST
        DEC BL               ; ultimo ?ndice
        MOV AX, 3 
        MUL BL               ; AX = 2 * (CONT_EST-1)
        LEA SI, NOTAS_ARR
        ADD SI, AX           ; SI apunta al ultimo par 
        JMP IMPRIMIR_LISTA_DESC 
        
    ;---- Recorrido ASC ----
    IMPRIMIR_LISTA:
        MOV CL, CONT_EST
        MOV CH, 0
    IMPRIMIR_ASC_LOOP:
        MOV BL, [SI]        ; ?ndice del estudiante
        DEC BL              ; convertir a base 0 
        MOV BH, 0 
        MOV AX, 43
        MUL BX              ; AX = 43 * (indice -1)
        LEA DI, ESTUDIANTES_R
        ADD DI, AX
        ADD DI, 1           ; DI --> Nombre
        
        ; mostrar nombre
        MOV DX, DI 
        MOV AH, 09h
        INT 21h
        
        ; Mostrar -> Nota:
        LEA DX, SPC
        MOV AH, 09h
        INT 21h
        
        ; Mostrar nota (segundo byte de NOTAS_ARR)
        MOV AX, [SI+1]
        CALL MOSTRAR_NOTA
        
        ; CRLF
        LEA DX, CRLF
        MOV AH, 09h
        INT 21h
        
        ADD SI, 3            ; siguiente par de notas 
        LOOP IMPRIMIR_ASC_LOOP
        JMP FIN_MOSTRAR_ESTUD_NOTAS
        
        
    ;---- Recorrido DESC ----
    IMPRIMIR_LISTA_DESC:
        MOV CL, CONT_EST
        MOV CH, 0
    IMPRIMIR_DESC_LOOP:
        MOV BL, [SI]    ; Indice del estudiante
        DEC BL 
        MOV BH, 0
        MOV AX, 43
        MUL BX
        LEA DI, ESTUDIANTES_R
        ADD DI, AX
        ADD DI, 1
        
        MOV DX, DI
        MOV AH, 09h
        INT 21h
        
        LEA DX, SPC
        MOV AH, 09h
        INT 21h
        
        MOV AX, [SI+1]
        CALL MOSTRAR_NOTA
        
        LEA DX, CRLF
        MOV AH, 09h
        INT 21h
        
        SUB SI, 3       ; retrocede en NOTAS_ARR
        LOOP IMPRIMIR_DESC_LOOP
        
        
        
    FIN_MOSTRAR_ESTUD_NOTAS:
        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
    MOSTRAR_ESTUDIANTES_Y_NOTAS ENDP           
            
;////////////////////////////////////////////////////////////////       SUBRUTINAS DE SOPORTE //////////////////////////////////////////////////////////


      

; Convierte un buffer leido con INT 21h/0Ah a cadena '$' y lo imprime con AH=09h.
; Entrada: DX = direccion del buffer (est?ndar 0Ah: [max][len][data..][0Dh])
      PrintInputBuffer PROC
            PUSH AX
            PUSH BX
            PUSH CX
            PUSH DX
            PUSH SI
            PUSH DI


            MOV BX, DX ; BX = base del buffer
            MOV AL, [BX+1] ; AL = longitud real digitada
            XOR AH, AH
            MOV CX, AX ; CX = longitud


            LEA SI, [BX+2] ; SI = inicio de los datos
            MOV DI, SI
            ADD DI, CX ; DI = posicion despu?s del ultimo caracter


            MOV BYTE PTR [DI], '$' ; sobrescribe el 0Dh con '$'


            MOV DX, SI ; DX -> datos ya terminados con '$'
            MOV AH, 09h
            INT 21h


            POP DI
            POP SI
            POP DX
            POP CX
            POP BX
            POP AX
            RET
      PrintInputBuffer ENDP       


;////////////////////////////////////////////////////////////////       SALIR       ///////////////////////////////////////////////////////////////////
    EXIT_PROGRAM:
            ; Muestra el mensaje de salida
            LEA     DX, EXIT_MSG   ; Carga la direccion del mensaje de salida en DX
            MOV     AH, 09h        ; prepara AH para la funcion de servicio de DOS para imprimir una cadena de caracteres
            INT     21h            ; Llama a la interrupcion 21H de DOS para imprimir el mensaje en pantalla
            
            MOV AX, 4C00h
            INT     21H

CODE_SEG    ENDS
    END START