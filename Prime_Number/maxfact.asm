DSEG SEGMENT PARA PUBLIC 'DATA'
    ; Lab3.asm'deki global degiskenler
    EXTRN FACTORS:WORD         ; Carpanlar dizisi
    EXTRN MAX_FACTOR_VAL:WORD  ; Sonucun yazilacagi yer
DSEG ENDS
    
CSEG SEGMENT PARA 'CODE'

    ASSUME CS:CSEG, DS:DSEG
    
    PUBLIC MAXFACT ; Bu proceduru public yap

MAXFACT PROC FAR
    ; Girdi: CX = Carpan sayisi
    ;        DS:OFFSET FACTORS = Carpan dizisi (sirali oldugu varsayiliyor)
    ; Cikti: MAX_FACTOR_VAL = En buyuk carpan
    
    ; --- Register'lari koru ---
    PUSH AX
    PUSH CX
    PUSH SI
    
    CMP CX, 0            ; Carpan sayisi 0 mi?
    JE MAX_FACTOR_FINISH ; Evetse (hic carpan yoksa) cik
 
    ; FACTOR proceduru carpanlari kucukten buyuge dogru
    ; (2, 2, 3...) buldugu icin, en buyuk carpan dizinin
    ; en son elemanidir.
 
    DEC CX               ; Son elemanin indeksi = (Sayi - 1)
    
    MOV SI, CX           ; SI = (Sayi - 1)
    ADD SI, SI           ; SI = SI * 2 (WORD dizi oldugu icin indeksi 2 ile carp)

    ; Son elemani (en buyuk carpani) al
    MOV AX, [FACTORS+SI]
    ; Sonucu global degiskene yaz
    MOV [MAX_FACTOR_VAL], AX

MAX_FACTOR_FINISH:
    ; --- Register'lari geri yukle ---
    POP SI
    POP CX
    POP AX
    RETF
MAXFACT ENDP

CSEG ENDS
END