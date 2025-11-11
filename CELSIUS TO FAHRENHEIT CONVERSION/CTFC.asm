myss SEGMENT PARA STACK 'STACK'
        DB      30 DUP(?)
myss    ENDS
myds SEGMENT PARA 'DATA'
        average     DD 0
        aboveAvg    DW 0
        celcius     DW 0, 11, -273, 72, 100, 27, -33
        fahrenheit  DW 7 DUP(?)
        N           DW 7 
myds ENDS

mycs SEGMENT PARA 'CODE'
        ASSUME CS:mycs, DS:myds, SS:myss

START PROC FAR

        PUSH DS
        XOR AX, AX
        PUSH AX
        MOV AX, myds
        MOV DS, AX

        LEA SI, celcius
        LEA DI, fahrenheit
        MOV CX, N
        MOV WORD PTR [average], 0
        MOV WORD PTR [average+2], 0
CONVERT_LOOP:
        MOV AX, [SI]
        MOV BX, 18
        IMUL BX
        MOV BX, 10
        IDIV BX
        ADD AX, 32
        MOV [DI], AX

        CWD
        ADD WORD PTR [average], AX
        ADC WORD PTR [average+2], DX

        ADD SI, 2
        ADD DI, 2

        LOOP CONVERT_LOOP

        MOV AX, WORD PTR [average]
        MOV DX, WORD PTR [average+2]

        MOV CX, N
        IDIV CX
        MOV WORD PTR [average], AX
        XOR BX, BX

        LEA SI, fahrenheit
COMPARE_LOOP:
        MOV AX, [SI]
        CMP AX, WORD PTR [average]
        JLE NOT_ABOVE
        INC BX
NOT_ABOVE:
        ADD SI, 2
        LOOP COMPARE_LOOP
        MOV [aboveAvg], BX

        RETF
START ENDP
mycs ENDS
END START               
         
