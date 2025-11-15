DSEG SEGMENT PARA PUBLIC 'DATA'
    ; Lab3.asm'deki global degiskenler
    EXTRN N_TO_PROCESS:WORD ; Islenecek sayi
    EXTRN FACTORS:WORD      ; Carpanlarin yazilacagi dizi
    EXTRN FACT_COUNT:WORD   ; Bulunan carpan sayisi
DSEG ENDS
    
CSEG SEGMENT PARA 'CODE'

    ASSUME CS:CSEG, DS:DSEG
    
    PUBLIC FACTOR ; Bu proceduru public yap

FACTOR PROC FAR
    
    ; --- Register'lari koru ---
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AX, [N_TO_PROCESS] ; Islenecek sayiyi AX'e al

    MOV [FACT_COUNT], 0    ; Carpan sayaci sifirla
    MOV BX, 0              ; Carpan dizi indeksi (BX) sifirla
    
    MOV CX, 2              ; Ilk bolen (CX) = 2

FACTORIZE_LOOP:
    CMP AX, 1              ; Sayi (AX) 1'e dustu mu?
    JBE FACTORIZE_FIN      ; Evetse carpanlara ayirma bitti, cik

    ; --- AX'i CX'e bolmeyi test et ---
    PUSH AX                ; AX'i koru
    MOV DX, 0              ; Bolme icin DX'i sifirla
    DIV CX                 ; AX = AX / CX (Kalan DX'te)
    POP AX                 ; Orijinal AX'i geri al (bolunmezse lazim)
    
    CMP DX, 0              ; Kalan (DX) 0 mi? (Tam bolundu mu?)
    JNE CHECK_NEXT_DIVISOR ; Hayirsa, sonraki boleni dene
    
    ; --- Tam bolundu ---
    MOV [FACTORS+BX], CX   ; Boleni (CX) carpanlar dizisine ekle
    ADD BX, 2              ; Dizi indeksini 2 arttir (WORD)
    INC [FACT_COUNT]       ; Carpan sayacini arttir
    
    ; Sayiyi bolenle guncelle (orijinal AX'i bol)
    MOV DX, 0
    DIV CX                 ; AX = AX / CX 
    
    JMP FACTORIZE_LOOP     ; Ayni bolenle (CX) tekrar dene (Ornek: 12/2=6, 6/2=3)

CHECK_NEXT_DIVISOR:
    INC CX                 ; Boleni 1 arttir (2, 3, 4, 5...)
    JMP FACTORIZE_LOOP     ; Donguye don

FACTORIZE_FIN:
    ; --- Register'lari geri yukle ---
    POP DX
    POP CX
    POP BX
    POP AX
    RETF
FACTOR ENDP

CSEG ENDS
END