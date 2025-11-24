mycs SEGMENT PARA 'CODE'
    ASSUME CS:mycs
    
    PUBLIC BINARY_SEARCH

BINARY_SEARCH PROC FAR

    PUSH    SI
    PUSH    DI
    PUSH    BP
    PUSH    AX          
    PUSH    BX
    PUSH    CX
    PUSH    DX
    
    MOV     BP, SP          
    MOV     SI, [BP+20]         ; Dizi Adresi
    MOV     BX, [BP+22]         ; HIGH İNDEKS
    MOV     AX, [BP+24]         ; LOW İNDEKS
    MOV     CX, [BP+18]         ; KEY
    MOV     DX, [BP+26]         ; SONUÇ 
    
    CMP     AX, BX
    JG      NOT_FOUND_LABEL     ; Low > High ise  çık.
    
    PUSH    AX
    ADD     AX, BX
    SHR     AX, 1       
    MOV     DI,AX               ; mid
    POP     AX
    
    PUSH    SI
    PUSH    DI
    PUSH    DX
    
    SHL     DI, 1
    ADD     SI, DI
    MOV     DX,[SI]             ; Dizi[mid]
    
    CMP     CX, DX              ; Key vs Dizi[mid]
    JE      FOUND_LABEL         ; Eşitse bulduk
    
    JL      LEFT_LABEL         ; Key < Dizi[mid]
    
    ; --- SAĞA GİT (Low = Mid + 1) ---
    POP     DX
    POP     DI
    POP     SI  
    INC     DI
    MOV     AX, DI              ; Yeni Low
    JMP     BINARY_SEARCH_CONTINUE

LEFT_LABEL:
    ; --- SOLA GİT (High = Mid - 1) ---
    POP     DX
    POP     DI
    POP     SI  
    DEC     DI
    MOV     BX,DI               ; Yeni High

BINARY_SEARCH_CONTINUE:
    PUSH    DX
    PUSH    AX
    PUSH    BX
    PUSH    SI
    PUSH    CX
    CALL    FAR PTR BINARY_SEARCH 
    POP     DX                  ; Sonucu al
    MOV     WORD PTR [BP+26], DX
    JMP     END_BINARY_SEARCH

FOUND_LABEL:
    POP     DX
    POP     DI
    POP     SI
    MOV     WORD PTR [BP+26], DI ; İndeksi yaz
    JMP     END_BINARY_SEARCH           

NOT_FOUND_LABEL:     
    MOV     WORD PTR [BP+26], -1 ; -1 yaz

END_BINARY_SEARCH:
    POP     DX
    POP     CX
    POP     BX
    POP     AX
    POP     BP
    POP     DI
    POP     SI

    RETF    8
BINARY_SEARCH ENDP

mycs    ENDS
        END