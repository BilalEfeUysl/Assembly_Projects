mycs SEGMENT PARA 'CODE'
    ASSUME CS:mycs

    PUBLIC IS_SORTED

IS_SORTED PROC FAR

    PUSH    SI
    PUSH    BP   ;Değerleri koruma
    PUSH    AX
    
    MOV     BP, SP   
    MOV     SI, [BP+12]    ;stackten dizi adresini al
    MOV     BX, [BP+10]    ;stackten eleman sayısını al
    DEC     BX
    MOV     CX, 0

CHECK_LOOP:
    CMP     CX, BX          ;tüm elemanlar gezildi mi kontrolü                     
    JAE      SORTED_LABEL
    MOV     AX, [SI]        ; 1. elemanı al
    MOV     DX, [SI+2]      ; 2. elemanı al
    CMP     AX, DX          ; karşılaştır
    JA      NOT_SORTED_LABEL
    ADD     SI, 2           ; sonraki elemana geç   
    INC     CX
    JMP     CHECK_LOOP

SORTED_LABEL:               ;sıralıysa 1 döndür
    MOV     AX, 1
    MOV     [BP+14], AX
    JMP     END_IS_SORTED 
NOT_SORTED_LABEL:
    XOR    AX, AX        ;sıralı değilse 0 döndür       
    MOV     [BP+14], AX 
END_IS_SORTED:

    POP     AX
    POP     BP
    POP     SI
    RETF    4      



IS_SORTED ENDP

mycs    ENDS
        END