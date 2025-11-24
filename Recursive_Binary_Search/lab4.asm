myss SEGMENT PARA STACK 'STACK'
    Dw 256 DUP(0)
myss ENDS

myds SEGMENT PARA 'DATA'
    NUMBER_COUNT    DW  10
    
    NUMBER_LIST     DW  10 DUP(?) 
    
    KEY             DW  ?
    RESULT_INDEX    DW  ?
    FLAG            DW  ?

    CR              EQU 13
    LF              EQU 10
    
    MSG_GIRIS       DB CR, LF, 'Lutfen 10 adet SIRALI sayi giriniz:', 0
    MSG_SAYI_ISTE   DB CR, LF, 'Sayi giriniz: ', 0
    MSG_KEY_ISTE    DB CR, LF, 'Aranacak degeri giriniz (Cikis icin q): ', 0
    
    MSG_SIRALI      DB CR, LF, 'IS_SORTED: Dizi sirali. Arama basliyor...', 0
    MSG_HATA_SIRA   DB CR, LF, 'HATA: Girdiginiz dizi sirali degil! Program sonlaniyor.', 0
    
    MSG_BULUNDU     DB CR, LF, 'BINARY_SEARCH: Sayi bulundu! Indeks: ', 0
    MSG_BULUNAMADI  DB CR, LF, 'BINARY_SEARCH: Sayi bulunamadi (-1).', 0
    MSG_HATA_GIRIS  DB CR, LF, 'Hatali giris! Sayi giriniz.', 0

myds ENDS

mycs SEGMENT PARA 'CODE'
    ASSUME CS:mycs, DS:myds, SS:myss
    
    EXTRN IS_SORTED:FAR
    EXTRN BINARY_SEARCH:FAR

MAIN PROC FAR
    PUSH DS
    XOR AX, AX
    PUSH AX
    MOV AX, myds
    MOV DS, AX

    MOV AX, OFFSET MSG_GIRIS
    CALL PUT_STR
    
    MOV CX, NUMBER_COUNT        ; 10 adet sayı
    LEA SI, NUMBER_LIST         ; Dizi adresi SI'da
    
INPUT_LOOP:
    MOV AX, OFFSET MSG_SAYI_ISTE
    CALL PUT_STR                ; "Sayi giriniz:" yazdırma
    
    PUSH CX                     ; DÖNGÜ SAYACINI KAYDET
    CALL GETN                   ; Sayıyı al (AX'e gelir)
    POP  CX                     ; DÖNGÜ SAYACINI GERİ AL
    
    MOV [SI], AX                ; Diziye yaz
    ADD SI, 2                   ; Sonraki elemana geç
    LOOP INPUT_LOOP             ; 10 kere dön

    ; ----------------------------------------------------------------
    ;                 IS_SORTED KONTROLÜ
    ; ----------------------------------------------------------------
    XOR AX, AX
    PUSH AX                     ; Flag için boşluk
    LEA SI, NUMBER_LIST
    PUSH SI                     ; Dizi Adresi
    MOV AX, NUMBER_COUNT
    PUSH AX                     ; Eleman Sayısı
    
    CALL IS_SORTED              
    POP FLAG                    ; Sonucu çek (0 veya 1)
    
    CMP FLAG, 0
    JE SIRASIZ_DURUM            ; 0 ise hata ver ve çık

    MOV AX, OFFSET MSG_SIRALI
    CALL PUT_STR

    ; ----------------------------------------------------------------
    ;                 KEY ARAMA DÖNGÜSÜ
    ; ----------------------------------------------------------------
KEY_LOOP:
    MOV AX, OFFSET MSG_KEY_ISTE
    CALL PUT_STR                ; "Aranacak deger (q)..."

    CALL GETN                   ; Kullanıcıdan KEY al
    JC CIKIS_YAP                ; Eğer 'q' basıldıysa (Carry Flag=1) çık.
    
    MOV KEY, AX                 ; Alınan sayıyı KEY'e at
    
    ; --- BINARY SEARCH ÇAĞRISI ---
    XOR AX, AX
    PUSH AX                      ; 1. Result (Boşluk)
    PUSH AX                      ; 2. Low (0)
    MOV AX, NUMBER_COUNT
    DEC AX
    PUSH AX                      ; 3. High (Count-1 = 9)
    LEA SI, NUMBER_LIST
    PUSH SI                      ; 4. Array Adresi
    MOV AX, KEY
    PUSH AX                      ; 5. Key
    
    CALL FAR PTR BINARY_SEARCH
    POP RESULT_INDEX            ;indeksi stackten alma
    
    ; --- SONUCU YAZDIR ---
    CMP RESULT_INDEX, -1
    JE BULUNAMADI
    
    MOV AX, OFFSET MSG_BULUNDU
    CALL PUT_STR
    MOV AX, RESULT_INDEX        
    CALL PUTN                   ; İndeksi ekrana yaz
    JMP KEY_LOOP                ; Tekrar KEY iste

BULUNAMADI:
    MOV AX, OFFSET MSG_BULUNAMADI
    CALL PUT_STR
    JMP KEY_LOOP                ; Tekrar KEY iste

SIRASIZ_DURUM:
    MOV AX, OFFSET MSG_HATA_SIRA
    CALL PUT_STR
    JMP CIKIS_YAP

CIKIS_YAP:
    RETF                        

MAIN ENDP


GETC PROC NEAR
    MOV AH, 1h
    INT 21H
    RET 
GETC ENDP 

PUTC PROC NEAR
    PUSH AX
    PUSH DX
    MOV DL, AL
    MOV AH, 2
    INT 21H
    POP DX
    POP AX
    RET 
PUTC ENDP 

PUT_STR PROC NEAR
    PUSH BX 
    MOV BX, AX
    MOV AL, BYTE PTR [BX]
PUT_LOOP:   
    CMP AL, 0       
    JE  PUT_FIN
    CALL PUTC
    INC BX
    MOV AL, BYTE PTR [BX]
    JMP PUT_LOOP
PUT_FIN:
    POP BX
    RET 
PUT_STR ENDP

PUTN PROC NEAR
    PUSH CX
    PUSH DX     
    XOR DX, DX
    PUSH DX         
    MOV CX, 10
    CMP AX, 0
    JGE CALC_DIGITS 
    NEG AX
    PUSH AX
    MOV AL, '-'
    CALL PUTC
    POP AX
CALC_DIGITS:
    DIV CX          
    ADD DX, '0'
    PUSH DX
    XOR DX, DX
    CMP AX, 0
    JNE CALC_DIGITS 
DISP_LOOP:
    POP AX
    CMP AX, 0
    JE END_DISP_LOOP 
    CALL PUTC
    JMP DISP_LOOP
END_DISP_LOOP:
    POP DX 
    POP CX
    RET
PUTN ENDP 


GETN PROC NEAR
    PUSH BX
    PUSH CX
    PUSH DX
GETN_START:
    MOV DX, 1       
    XOR BX, BX 
    XOR CX, CX      
NEW:
    CALL GETC       


    CMP AL, 'q'
    JE QUIT_PRESSED
    CMP AL, 'Q'
    JE QUIT_PRESSED

    CMP AL, 13      
    JE FIN_READ
    CMP AL, '-'
    JNE CTRL_NUM
NEGATIVE:
    MOV DX, -1
    JMP NEW
CTRL_NUM:
    CMP AL, '0'
    JB ERROR_INPUT
    CMP AL, '9'
    JA ERROR_INPUT
    
    SUB AL, '0'
    MOV BL, AL
    MOV AX, 10
    PUSH DX         
    MUL CX
    POP DX
    MOV CX, AX
    ADD CX, BX
    JMP NEW

ERROR_INPUT:
    MOV AX, OFFSET MSG_HATA_GIRIS
    CALL PUT_STR
    JMP GETN_START 

QUIT_PRESSED:
    STC             
    JMP FIN_GETN_EXIT

FIN_READ:
    MOV AX, CX
    CMP DX, 1
    JE NO_NEG
    NEG AX
NO_NEG:
    CLC             

FIN_GETN_EXIT:
    POP DX
    POP CX         
    POP BX         
    RET 
GETN ENDP 

mycs ENDS
    END MAIN