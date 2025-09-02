; Proyecto en TASM 8086
.MODEL SMALL
.STACK 100h

DATA_SEG    SEGMENT
    ; Variables de mensajes
    MENU db 10,13,10, "Digite:", 0ah,"", 0ah, "1. Ingresar calificaciones (15 estudiantes -Nombre Apellido1 Apellido2 Nota-)", 0ah, "2. Mostrar estadisticas.", 0ah, "3. Buscar estudiante por posicion (indice)", 0ah, "4. Ordenar calificaciones (ascendente/descendente).", 0ah, "5. Salir", 0ah, "$"
    WELC_MSG db 0ah, 0dh, "***************  Bienvenido a RegistroCE  ***************", 0ah,"",0ah, "$"
    EXIT_MSG db 0ah, 0dh, "", 0ah,"*************  Gracias por usar RegistroCE  *************",0ah, "$" 
    
    MSG1    DB  10,13,10,'Por favor ingrese su estudiante o digite 9 para salir al menu principal $' 
    MSG2    DB  10,13,10,'El promedio de notas de los estudiantes ingresados es: $'
    MSG3    DB  13,10,'La nota maxima de los estudiantes ingresados es: $'
    MSG4    DB  13,10,'La nota minima de los estudiantes ingresados es: $'
    MSG5    DB  13,10,'La cantidad de estudiantes aprobados es: $'
    MSG6    DB  13,10,'    Porcentaje(%) $'
    MSG7    DB  13,10,'La cantidad de estudiantes reprobados es: $'
    MSG8    DB  13,10,'    Porcentaje(%) $'
    MSG9    DB  10,13,10,'Digite numero de estudiante a mostrar $'
    MSG10   DB  10,13,10, "Como desea ordenar las calificaciones:", 0ah,"", 0ah, "1. Orden Ascendente.", 0ah, "2. Orden Descendente.", 0ah, "$"
    
    ; Nuevas variables para manejo de estudiantes
    ESTUDIANTES db 15 dup(20 dup(' '), 20 dup(' '), 20 dup(' '), 0) ; Array de estudiantes
    CONTADOR_ESTUDIANTES db 0
    NOTA_BUFFER db 5, 0, 5 dup('$')  ; Buffer para entrada de nota
    NUMERO db 0
    
    ; Mensajes adicionales
    PROMPT_NOMBRE db 10,13,'Nombre: $'
    PROMPT_APELLIDO1 db 10,13,'Primer Apellido: $'
    PROMPT_APELLIDO2 db 10,13,'Segundo Apellido: $'
    PROMPT_NOTA db 10,13,'Nota (0-100): $'
    ERROR_NOTA db 10,13,'Error: Ingrese una nota valida (0-100): $'
    ERROR_ENTRADA_VACIA db 10,13,'Error: No puede dejar espacios vacios. $'
    MAX_ESTUDIANTES db 10,13,'Maximo de estudiantes alcanzado (15). $'
    
    ; Buffers para entrada de texto
    NOMBRE_BUFFER db 21, 0, 21 dup('$')
    APELLIDO1_BUFFER db 21, 0, 21 dup('$')
    APELLIDO2_BUFFER db 21, 0, 21 dup('$')
    
DATA_SEG    ENDS

CODE_SEG    SEGMENT
    ASSUME CS: CODE_SEG, DS:DATA_SEG
    
START:
    MOV AX, DATA_SEG
    MOV DS, AX

INITIAL_MSG:
    MOV AH, 09
    MOV DX, OFFSET WELC_MSG 
    INT 21H
            
MENU_LOOP:
    LEA DX, MENU
    MOV AH, 09H
    INT 21H

    MOV AH, 01H
    INT 21H
    SUB AL, 30H
            
    CMP AL, 1
    JE ITS_ENTER_GRADES
    CMP AL, 2
    JE ITS_STATISTICS
    CMP AL, 3
    JE ITS_INDEX_SEARCH
    CMP AL, 4
    JE ITS_SORT_CAL
    CMP AL, 5
    JMP EXIT_PROGRAM
    
ITS_ENTER_GRADES:
    JMP ENTER_GRADES
ITS_STATISTICS:
    JMP STATISTICS
ITS_INDEX_SEARCH:
    JMP INDEX_SEARCH
ITS_SORT_CAL:
    JMP SORT_CAL
            
ENTER_GRADES:
    ; Verificar si ya hay 15 estudiantes
    MOV AL, CONTADOR_ESTUDIANTES
    CMP AL, 15
    JAE MAXIMO_ALCANZADO
    
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    ; Pedir nombre
    LEA DX, PROMPT_NOMBRE
    MOV AH, 09H
    INT 21H
    CALL LEER_TEXTO
    JC ENTER_GRADES  ; Si hay error, volver a empezar
    
    ; Copiar nombre a buffer temporal
    MOV SI, OFFSET NOMBRE_BUFFER + 2
    MOV DI, OFFSET NOMBRE_BUFFER
    CALL COPIAR_TEXTO_TEMPORAL
    
    ; Pedir primer apellido
    LEA DX, PROMPT_APELLIDO1
    MOV AH, 09H
    INT 21H
    CALL LEER_TEXTO
    JC ENTER_GRADES
    
    ; Copiar primer apellido a buffer temporal
    MOV SI, OFFSET APELLIDO1_BUFFER + 2
    MOV DI, OFFSET APELLIDO1_BUFFER
    CALL COPIAR_TEXTO_TEMPORAL
    
    ; Pedir segundo apellido
    LEA DX, PROMPT_APELLIDO2
    MOV AH, 09H
    INT 21H
    CALL LEER_TEXTO
    JC ENTER_GRADES
    
    ; Copiar segundo apellido a buffer temporal
    MOV SI, OFFSET APELLIDO2_BUFFER + 2
    MOV DI, OFFSET APELLIDO2_BUFFER
    CALL COPIAR_TEXTO_TEMPORAL
    
    ; Pedir y validar nota
PEDIR_NOTA:
    LEA DX, PROMPT_NOTA
    MOV AH, 09H
    INT 21H
    
    CALL LEER_NOTA
    JNC NOTA_VALIDA
    
    LEA DX, ERROR_NOTA
    MOV AH, 09H
    INT 21H
    JMP PEDIR_NOTA

NOTA_VALIDA:
    ; Guardar estudiante en el array
    CALL GUARDAR_ESTUDIANTE
    
    ; Incrementar contador
    INC CONTADOR_ESTUDIANTES
    
    ; Preguntar si desea continuar
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H
    
    MOV AH, 01H
    INT 21H
    CMP AL, '9'
    JNE ENTER_GRADES  ; Si no es 9, continuar
    
    JMP MENU_LOOP

MAXIMO_ALCANZADO:
    LEA DX, MAX_ESTUDIANTES
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP

; Rutina para leer texto y validar que no est? vac?o
LEER_TEXTO PROC
    MOV DX, OFFSET NOMBRE_BUFFER
    MOV AH, 0Ah
    INT 21h
    
    ; Verificar que no est? vac?o
    MOV SI, OFFSET NOMBRE_BUFFER + 1
    MOV CL, [SI]
    CMP CL, 0
    JNE TEXTO_VALIDO
    
    ; Mostrar error si est? vac?o
    LEA DX, ERROR_ENTRADA_VACIA
    MOV AH, 09H
    INT 21H
    STC  ; Establecer carry flag para indicar error
    RET

TEXTO_VALIDO:
    CLC  ; Limpiar carry flag para indicar ?xito
    RET
LEER_TEXTO ENDP

; Rutina para copiar texto a buffer temporal
COPIAR_TEXTO_TEMPORAL PROC
    MOV CX, 20
COPIAR_LOOP:
    MOV AL, [SI]
    MOV [DI], AL
    INC SI
    INC DI
    LOOP COPIAR_LOOP
    RET
COPIAR_TEXTO_TEMPORAL ENDP

; Rutina para leer y validar nota
LEER_NOTA PROC
    MOV DX, OFFSET NOTA_BUFFER
    MOV AH, 0Ah
    INT 21h
    
    ; Convertir ASCII a n?mero
    MOV SI, OFFSET NOTA_BUFFER + 2
    XOR AX, AX
    XOR CX, CX
    MOV BX, 10

CONVERTIR_LOOP:
    MOV CL, [SI]
    CMP CL, 0Dh
    JE FIN_CONVERSION
    CMP CL, '0'
    JL ERROR_CONVERSION
    CMP CL, '9'
    JG ERROR_CONVERSION
    
    SUB CL, '0'
    MUL BX
    JC ERROR_CONVERSION
    ADD AL, CL
    ADC AH, 0
    JC ERROR_CONVERSION
    
    INC SI
    JMP CONVERTIR_LOOP

FIN_CONVERSION:
    CMP AX, 0
    JL ERROR_CONVERSION
    CMP AX, 100
    JG ERROR_CONVERSION
    
    MOV [NUMERO], AL
    CLC
    RET

ERROR_CONVERSION:
    STC
    RET
LEER_NOTA ENDP

; Rutina para guardar estudiante en el array
GUARDAR_ESTUDIANTE PROC
    ; Calcular posici?n en el array
    MOV AL, CONTADOR_ESTUDIANTES
    MOV BL, 61  ; 20 (nombre) + 20 (apellido1) + 20 (apellido2) + 1 (nota) = 61 bytes por estudiante
    MUL BL
    LEA SI, ESTUDIANTES
    ADD SI, AX
    
    ; Copiar nombre
    MOV DI, SI
    MOV CX, 20
    LEA SI, NOMBRE_BUFFER
REP MOVSB
    
    ; Copiar primer apellido
    MOV CX, 20
    LEA SI, APELLIDO1_BUFFER
REP MOVSB
    
    ; Copiar segundo apellido
    MOV CX, 20
    LEA SI, APELLIDO2_BUFFER
REP MOVSB
    
    ; Copiar nota
    MOV AL, [NUMERO]
    MOV [SI], AL
    
    RET
GUARDAR_ESTUDIANTE ENDP

STATISTICS:
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP
            
INDEX_SEARCH:
    LEA DX, MSG9
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP
    
SORT_CAL:
    LEA DX, MSG10
    MOV AH, 09H
    INT 21H
    JMP MENU_LOOP
    
EXIT_PROGRAM:
    LEA DX, EXIT_MSG
    MOV AH, 09h
    INT 21h
    MOV AH, 4CH
    MOV AL, 0
    INT 21H

CODE_SEG    ENDS
    END START
