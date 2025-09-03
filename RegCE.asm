; Proyecto en TASM 8086
.MODEL SMALL
.STACK 100h

DATA_SEG    SEGMENT
    ; Variables de mensajes
    MENU db 10,13,10, "Digite:", 0ah,"", 0ah, "1. Ingresar calificaciones (15 estudiantes -Nombre Apellido1 Apellido2 Nota-)", 0ah, "2. Mostrar estadisticas.", 0ah, "3. Buscar estudiante por posicion (indice)", 0ah, "4. Ordenar calificaciones (ascendente/descendente).", 0ah, "5. Salir", 0ah, "$"
    WELC_MSG db 0ah, 0dh, "***************  Bienvenido a RegistroCE  ***************", 0ah,"",0ah, "$"
    EXIT_MSG db 0ah, 0dh, "", 0ah,"*************  Gracias por usar RegistroCE  *************",0ah, "$" 
    
    MSG1    DB  10,13,10,'Digite 1 para ingresar su estudiante o digite 9 para salir al menu principal $' 
    MSG2    DB  10,13,10,'El promedio de notas de los estudiantes ingresados es: $'
    MSG3    DB  13,10,'La nota maxima de los estudiantes ingresados es: $'
    MSG4    DB  13,10,'La nota minima de los estudiantes ingresados es: $'
    MSG5    DB  13,10,'La cantidad de estudiantes aprobados es: $'
    MSG6    DB  13,10,'    Porcentaje(%) $'
    MSG7    DB  13,10,'La cantidad de estudiantes reprobados es: $'
    MSG8    DB  13,10,'    Porcentaje(%) $'
    MSG9    DB  10,13,10,'Digite numero de estudiante a mostrar $'
    MSG10   DB  10,13,10, "Como desea ordenar las calificaciones:", 0ah,"", 0ah, "1. Orden Ascendente.", 0ah, "2. Orden Descendente.", 0ah, "$"
    
    MSG11    DB  13,10,'    DEBUGGG $'
    MSG12    DB  13,10,'    DEBUGGG2 $'
    
    ; Nuevas variables para manejo de estudiantes
    ESTUDIANTES db 15 dup(20 dup(' '), 20 dup(' '), 20 dup(' '), 0) ; Array de estudiantes
    CONTADOR_ESTUDIANTES db 0
    NOTA_BUFFER db 9, 0, 9 dup('$')  ; Buffer para entrada de nota
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
        LEA DX, MENU       ; carga la direcci?n del mensaje MENU en DX
        MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
        INT 21H            ; llama a la interrupcion 21H de DOS

        MOV AH, 01H        ; lee un caracter del teclado
        INT 21H            ; llama a la interrupcion 21H de DOS

        SUB AL, 30H        ; convierte el caracter ingresado por el usuario ASCII a su equivalente num?rico
            
        CMP AL, 1          ; compara el valor ingresado con 1
        JE INGRSCAL    ; salta a INGRESAR_NOTA si es igual a 1
        CMP AL, 2          ; compara el valor ingresado con 2
        JE LL_ESTADISTICAS   ; salta a LL_ESTADISTICAS si es igual a 2
        CMP AL, 3          ; compara el valor ingresado con 3
        JE LL_INDICES  ; salta a LL_INDICES si es igual a 3
        CMP AL, 4          ; compara el valor ingresado con 4
        JE LL_ORD_NOTAS    ; salta a LL_ORD_NOTAS si es igual a 4
        CMP AL, 5          ; compara el valor ingresado con 5
        JMP EXIT_PROGRAM   ; salta a EXIT_PROGRAM si es igual a 5
    
INGRSCAL:
    JMP INGRESAR_NOTA
LL_ESTADISTICAS:
    JMP ESTADISTICAS
LL_INDICES:
    JMP BUSCAR_INDICE
LL_ORD_NOTAS:
    JMP ORDENAR_NOTAS

;//////////////////////////////////////////////////////////////// REGISTAR CALIFICACION ////////////////////////////////////////////////////////////     
    MAXIMO_ALCANZADO:
        LEA DX, MAX_ESTUDIANTES
        MOV AH, 09H
        INT 21H
        JMP MENU_LOOP

    INGRESAR_NOTA:
        ; Verificar si ya hay 15 estudiantes
        MOV AL, CONTADOR_ESTUDIANTES ;Trae al registro AL el valor de contador estudiantes
        CMP AL, 15 ;Se compara si es numero de estudiantes guardados es igual al maximo
        JAE MAXIMO_ALCANZADO ;Si se cumple, salta a MAXIMO_ALCANZADO
        
        LEA DX, MSG1       ; carga la direcci?n del mensaje 1 en DX
        MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
        INT 21H            ; llama a la interrupcion 21H de DOS
            
        MOV AH, 01H        ; lee un caracter del teclado
        INT 21H            ; llama a la interrupcion 21H de DOS
        SUB AL, 30H        ; convierte el caracter ingresado por el usuario ASCII a su equivalente num?rico
            
        CMP AL, 1          ; compara el valor ingresado con 1
        JE REGISTRO    ; salta a REGISTER si es igual a 1
        CMP AL, 9          ; compara el valor ingresado con 2
        JE MENU_LOOP   ; salta al menu si es 9        
        
    REGISTRO:    ; Pedir nombre 
        LEA DX, PROMPT_NOMBRE
        MOV AH, 09H
        INT 21H
        CALL LEER_TEXTO
        JC INGRESAR_NOTA  ; Si hay error, volver a empezar
        
        ; Copiar nombre a buffer temporal
        MOV SI, OFFSET NOMBRE_BUFFER + 2
        MOV DI, OFFSET NOMBRE_BUFFER
        CALL COPIAR_TEXTO_TEMPORAL
        
        ; Pedir primer apellido
        LEA DX, PROMPT_APELLIDO1
        MOV AH, 09H
        INT 21H
        CALL LEER_TEXTO
        JC INGRESAR_NOTA
        
        ; Copiar primer apellido a buffer temporal
        MOV SI, OFFSET APELLIDO1_BUFFER + 2
        MOV DI, OFFSET APELLIDO1_BUFFER
        CALL COPIAR_TEXTO_TEMPORAL
        
        ; Pedir segundo apellido
        LEA DX, PROMPT_APELLIDO2
        MOV AH, 09H
        INT 21H
        CALL LEER_TEXTO
        JC INGRESAR_NOTA
        
        ; Copiar segundo apellido a buffer temporal
        MOV SI, OFFSET APELLIDO2_BUFFER + 2
        MOV DI, OFFSET APELLIDO2_BUFFER
        CALL COPIAR_TEXTO_TEMPORAL
        
        JMP PEDIR_NOTA
        
        ; Pedir y validar nota
    PEDIR_NOTA:
        LEA DX, PROMPT_NOTA
        MOV AH, 09H
        INT 21H
        
        CALL LEER_NOTA
        LEA DX, MSG12       ; carga la direcci?n del mensaje MENU en DX
        MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
        INT 21H            ; llama a la interrupcion 21H de DOS
        JNC NOTA_VALIDA
        
        LEA DX, ERROR_NOTA
        MOV AH, 09H
        INT 21H
        
        JMP PEDIR_NOTA
       

    NOTA_VALIDA:
        LEA DX, MSG11       ; carga la direcci?n del mensaje MENU en DX
        MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
        INT 21H            ; llama a la interrupcion 21H de DOS
        
        CALL GUARDAR_ESTUDIANTE ; Guardar estudiante en el array
        
        LEA DX, MSG12       ; carga la direcci?n del mensaje MENU en DX
        MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
        INT 21H            ; llama a la interrupcion 21H de DOS
       
        INC CONTADOR_ESTUDIANTES ; Incrementar contador
        
        JMP LIMP_PANTALLA
        
    LIMP_PANTALLA:
 
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
        
        MOV SP, 100h    ; resetea el puntero de pila al inicio
        
        JMP INGRESAR_NOTA            ; Retornar al bucle de ingresar nota   

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

;//////////////////////////////////////////////////////////////// MOSTRAR ESTADISTICAS ////////////////////////////////////////////////////////////////    
    ESTADISTICAS:
            LEA DX, MSG2       ; carga la direcci?n del mensaje 2:promedio en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            CALL PROMEDIO
            
            LEA DX, MSG3       ; carga la direcci?n del mensaje 3: nota max en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            CALL NOTAMAX
            
            LEA DX, MSG4       ; carga la direcci?n del mensaje 4: nota min en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, MSG5       ; carga la direcci?n del mensaje 5: aprobados en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, MSG6       ; carga la direcci?n del mensaje 6: % en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, MSG7       ; carga la direcci?n del mensaje 7: reprobados en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            LEA DX, MSG8       ; carga la direcci?n del mensaje 8: % en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            JMP MENU_LOOP          ;ESTO POR AHORA QUE NO HAY NADA QUITAR DESPUES
    
    ;//////////// SUBRUTINA PARA CALCULAR EL PROMEDIO ////////////////////

    PROMEDIO PROC
            
            LEA DX, MSG6       ; carga la direcci?n del mensaje 6: % en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
    
    
    
            RET
    PROMEDIO ENDP
    
    
    NOTAMAX PROC
            
            LEA DX, MSG6       ; carga la direcci?n del mensaje 6: % en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
    
    
    
            RET
    NOTAMAX ENDP
            
    
;//////////////////////////////////////////////////////////////// BUSCAR ESTUDIANTE POR POSICION //////////////////////////////////////////////////////   
    BUSCAR_INDICE:
            LEA DX, MSG9       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            JMP MENU_LOOP          ;ESTO POR AHORA QUE NO HAY NADA QUITAR DESPUES
    
;//////////////////////////////////////////////////////////////// ORDENAR CALIFICACIONES //////////////////////////////////////////////////////////////  
    ORDENAR_NOTAS:
            LEA DX, MSG10       ; carga la direcci?n del mensaje 1 en DX
            MOV AH, 09H        ; prepara AH para la funci?n de servicio de DOS para imprimir una cadena de caracteres
            INT 21H            ; llama a la interrupcion 21H de DOS
            
            MOV AH, 01h
            INT 21h ; AL = '1' o '2'
            SUB AL, 30h ; a valor num?rico 1/2
            
            JMP MENU_LOOP          ;ESTO POR AHORA QUE NO HAY NADA QUITAR DESPUES
        
    EXIT_PROGRAM:
        LEA DX, EXIT_MSG
        MOV AH, 09h
        INT 21h
        MOV AH, 4CH
        MOV AL, 0
        INT 21H

CODE_SEG    ENDS
    END START
