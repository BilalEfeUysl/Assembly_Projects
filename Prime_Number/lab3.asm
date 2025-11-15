SSEG 	SEGMENT PARA STACK 'STACK'
	DW 64 DUP (?)
SSEG 	ENDS

DSEG	SEGMENT PARA PUBLIC 'DATA' 

    ; Diger modullerin erismesi icin
    PUBLIC N_TO_PROCESS
    PUBLIC FACTORS
    PUBLIC FACT_COUNT
    PUBLIC MAX_FACTOR_VAL
    PUBLIC MSG_SPACE
    PUBLIC HATA

    CR	        EQU 13  ; Enter (Carriage Return)
    LF	        EQU 10  ; New Line (Line Feed)

    NUMBER_LIST     DW 8 DUP(?)     ; Kullanicidan alinacak 8 sayilik dizi
    NUMBER_COUNT    DW 8            ; Alinacak sayi adedi
    N_TO_PROCESS    DW ?            ; Islem yapilan anlik sayi (FACTOR/ISPRIME icin)
    
    FACTORS         DW 100 DUP(?)   ; Sayinin carpanlarinin tutulacagi dizi
    FACT_COUNT      DW ?            ; Bulunan carpan sayisi
    IS_PRIME_FLAG   DB ?            ; Sayi asal mi? (1=Evet, 0=Hayir)
    MAX_FACTOR_VAL  DW ?            ; En buyuk carpan degeri
    
    ; --- Ekrana basilacak mesajlar ---
    MSG_PROMPT      DB 'Lutfen 8 adet 16-bit sayi giriniz (2, 162...):', CR, LF, 0
    MSG_READ_DONE   DB CR, LF, 'Sayilar okundu: ', 0
    MSG_NEW_LINE    DB CR, LF, 0
    MSG_PROCESSING  DB 'Islem yapilan sayi: ', 0
    MSG_IS_PRIME    DB ' - Asal mi: ', 0
    MSG_YES         DB 'Evet', 0
    MSG_NO          DB 'Hayir', 0
    MSG_FACTORS     DB ' - Carpanlar: ', 0
    MSG_MAX_FACTOR  DB ' - En Buyuk Carpan: ', 0
    MSG_SPACE       DB ' ', 0

    HATA	        DB CR, LF, 'Dikkat! Gecersiz sayi...', 0
DSEG 	ENDS 

CSEG 	SEGMENT PARA 'CODE'
	ASSUME CS:CSEG, DS:DSEG, SS:SSEG

    ; Macro dosyalari dahil ediliyor
    INCLUDE rdar.mac
    INCLUDE prar.mac

    ; Harici (diger .asm dosyalardaki) procedur'ler
    EXTRN ISPRIME:FAR
    EXTRN FACTOR:FAR
    EXTRN MAXFACT:FAR

ANA 	PROC FAR

        ; --- DS (Data Segment) ayarlamasi ---
        PUSH DS
        XOR AX,AX
        PUSH AX
        MOV AX, DSEG 
        MOV DS, AX
        ; ------------------------------------

        ; 'Lutfen 8 adet sayi giriniz...' mesaji
        MOV AX, OFFSET MSG_PROMPT
        CALL PUT_STR

        ; --- 8 Sayiyi Oku ---
        MOV CX, [NUMBER_COUNT]      ; CX = 8 (Dongu sayaci)
        MOV BX, OFFSET NUMBER_LIST  ; BX = Dizinin adresi
        READARRAY                   ; rdar.mac makrosunu cagir
        
        ; 'Sayilar okundu: ' mesaji
        MOV AX, OFFSET MSG_READ_DONE
        CALL PUT_STR
        
        ; --- Okunan Diziyi Ekrana Bas ---
        MOV CX, [NUMBER_COUNT]      ; CX = 8
        MOV BX, OFFSET NUMBER_LIST  ; BX = Dizinin adresi
        PRINTARRAY                  ; prar.mac makrosunu cagir

        ; --- Ana Dongu Icin Hazirlik ---
        MOV CX, [NUMBER_COUNT]  ; CX = 8 (Ana dongu sayaci)
        MOV BX, OFFSET NUMBER_LIST ; BX = Dizi adresi
        MOV SI, 0               ; SI = Dizi indeksi

MAIN_LOOP:  ; Bu dongu 8 sayi icin tek tek doner
        PUSH BX                 ; BX'i koru (PRINTARRAY bozabilir)
        
        MOV AX, OFFSET MSG_NEW_LINE ; Yeni satira gec
        CALL PUT_STR
        
        MOV AX, WORD PTR [BX+SI]    ; Islenecek sayiyi al
        
        ; --- 'Islem yapilan sayi: X' bas ---
        PUSH AX                 ; Sayiyi (AX) koru
        MOV AX, OFFSET MSG_PROCESSING ; Mesaji bas
        CALL PUT_STR
        POP AX                  ; Sayiyi geri al
        CALL PUTN               ; Sayiyi bas
        ; -----------------------------------

        ; --- Asallik Kontrolu ---
        MOV AX, WORD PTR [BX+SI] ; Sayiyi tekrar AX'e al
        CALL ISPRIME             ; ISPRIME procedurunu cagir
                                 ; Sonuc AL'ye gelir (1=Asal, 0=Degil)
        MOV [IS_PRIME_FLAG], AL  ; Sonucu kaydet
        
        MOV AX, OFFSET MSG_IS_PRIME ; ' - Asal mi: ' bas
        CALL PUT_STR
        
        CMP BYTE PTR [IS_PRIME_FLAG], 1 ; Asal mi?
        JE IS_PRIME_CASE         ; Evet ise IS_PRIME_CASE'e atla
        
        ; --- SAYI ASAL DEGILSE ---
        MOV AX, OFFSET MSG_NO    ; 'Hayir' bas
        CALL PUT_STR

        MOV AX, WORD PTR [BX+SI]   ; Sayiyi al
        MOV [N_TO_PROCESS], AX     ; FACTOR'un kullanmasi icin global degiskene yaz
        
        CALL FACTOR                ; FACTOR procedurunu cagir (Carpanlari bulur)

        MOV AX, OFFSET MSG_FACTORS ; ' - Carpanlar: ' bas
        CALL PUT_STR
        
        push CX                    ; Ana dongu sayaci CX'i koru
        MOV CX, [FACT_COUNT]       ; Carpan sayisini CX'e al
        MOV BX, OFFSET FACTORS     ; Carpan dizisinin adresini BX'e al
        PRINTARRAY                 ; Carpanlari bas
        POP CX                     ; Ana dongu sayacini geri al

        JMP PRINT_MAX_FACTOR_RESULT ; En buyuk carpani basma isine git

IS_PRIME_CASE:
        ; --- SAYI ASAL ISE ---
        MOV AX, OFFSET MSG_YES   ; 'Evet' bas
        CALL PUT_STR

        ; Asal sayinin en buyuk carpani kendisidir
        MOV AX, WORD PTR [BX+SI]
        MOV [MAX_FACTOR_VAL], AX

        MOV AX, OFFSET MSG_FACTORS ; ' - Carpanlar: ' bas
        CALL PUT_STR
        MOV AX, WORD PTR [BX+SI]   ; Sayinin kendisini
        CALL PUTN                  ; bas
            
        JMP PRINT_MAX_FACTOR_RESULT ; Direkt sonucu basma kismina git

PRINT_MAX_FACTOR_RESULT:
        ; Bu etiket hem asal hem asal olmayan durum icin ortak
        
        CMP BYTE PTR [IS_PRIME_FLAG], 1 ; Sayi asal miydi?
        JE PRINT_FINAL_VALUE     ; Asalsa MAXFACT'i cagirmaya gerek yok, atla
        
        ; --- Asal degilse en buyuk carpani bul ---
        PUSH CX                  ; Ana dongu sayacini koru
        
        MOV CX, [FACT_COUNT]     ; Carpan sayisini al
        CALL MAXFACT             ; MAXFACT cagir (En buyugu bulur)
        
        POP CX                   ; Ana dongu sayacini geri al

PRINT_FINAL_VALUE:
        ; --- ' - En Buyuk Carpan: X' bas ---
        MOV AX, OFFSET MSG_MAX_FACTOR
        CALL PUT_STR
        MOV AX, [MAX_FACTOR_VAL] ; Bulunan/ayarlanan en buyuk carpani al
        CALL PUTN                ; Ekrana bas
        ; -----------------------------------

        ADD SI, 2                ; Dizideki sonraki sayiya gec (indeks arttir)
        POP BX                   ; Dongu basinda korunan BX'i geri al
        
        DEC CX                   ; Ana dongu sayacini azalt
        JZ  MAIN_LOOP_EXIT       ; Sayac 0 olduysa (8 sayi bittiyse) cik
        JMP MAIN_LOOP            ; Bitmediyse basa don
        
MAIN_LOOP_EXIT:
        RETF                     ; Programi bitir
ANA 	ENDP

; ----- G/C (I/O) PROCEDURLERI -----

GETC	PROC NEAR ; Klavyeden tek karakter oku (AX'e)
        MOV AH, 1h
        INT 21H
        RET 
GETC	ENDP 

PUTC	PROC NEAR ; AX'teki karakteri ekrana bas
        PUSH AX
        PUSH DX
        MOV DL, AL
        MOV AH,2
        INT 21H
        POP DX
        POP AX
        RET 
PUTC 	ENDP 

GETN 	PROC NEAR ; Klavyeden 16-bit'lik sayi oku (AX'e)
        PUSH BX
        PUSH CX
        PUSH DX
GETN_START:
        MOV DX, 1   ; Negatif sayi kontrolu icin (su an kullanilmiyor)
        XOR BX, BX  ; Basamak degeri (BL)
        XOR CX,CX   ; Toplam sayi (CX)
NEW:
        CALL GETC   ; Karakter al
        CMP AL,CR   ; Enter mi?
        JE FIN_READ ; Evetse okumayi bitir

CTRL_NUM:   ; Girilen karakter rakam mi?
        CMP AL, '0'
        JB error    ; '0'dan kucukse hata
        CMP AL, '9'
        JA error    ; '9'dan buyukse hata
        
        SUB AL,'0'  ; ASCII -> Sayi (ornegin '5' -> 5)
        MOV BL, AL  ; BL = Guncel basamak
        
        MOV AX, 10  ; Eski toplami 10 ile carp
        PUSH DX
        MUL CX
        POP DX
        MOV CX, AX  ; CX = CX * 10
        ADD CX, BX  ; CX = (CX * 10) + Guncel Basamak
        JMP NEW 
ERROR:
        MOV AX, OFFSET HATA ; Hata mesaji bas
        CALL PUT_STR
        JMP GETN_START      ; Sayi okumaya bastan basla
FIN_READ:
        MOV AX, CX  ; Okunan sayiyi (CX) donus degeri icin AX'e tasi
FIN_GETN:
        POP DX
        POP CX
        POP BX 
        RET 
GETN 	ENDP 

PUTN 	PROC NEAR ; AX'teki 16-bit'lik sayiyi ekrana bas
        PUSH CX
        PUSH DX 	
        XOR DX,	DX 	
        PUSH DX		; Stack'e '0' (isaret) koy (dongu sonu icin)
        MOV CX, 10	; Bolen = 10
CALC_DIGITS: ; Sayiyi 10'a bolerek basamaklari bul
        DIV CX  	; AX = AX / 10, Kalan DX'te
        ADD DX, '0'	; Kalani ASCII'ye cevir (ornegin 3 -> '3')
        PUSH DX		; Basamagi stack'e at
        XOR DX,DX	; DX'i temizle (sonraki bolme icin)
        CMP AX, 0	; AX (bolum) 0 mi?
        JNE CALC_DIGITS	; Degilse basa don
DISP_LOOP: ; Stack'ten basamaklari cekip ekrana bas (Ters sira)
        POP AX		; Stack'ten basamagi al
        CMP AX, 0 	; '0' (isaret) mi geldi?
        JE END_DISP_LOOP ; Evetse bitir
        CALL PUTC 	; Degilse karakteri bas
        JMP DISP_LOOP                           
END_DISP_LOOP:
        POP DX 
        POP CX
        RET
PUTN 	ENDP 

PUT_STR	PROC NEAR ; AX'te adresi olan string'i (0 ile biten) ekrana bas
	PUSH BX 
        MOV BX,	AX			; Adresi BX'e al
        MOV AL, BYTE PTR [BX]	; Ilk karakteri al
PUT_LOOP:   
        CMP AL,0		; Karakter 0 (NULL) mi?
        JE  PUT_FIN 	; Evetse bitir
        CALL PUTC 		; Degilse karakteri bas
        INC BX 			; Adresi bir arttir
        MOV AL, BYTE PTR [BX] ; Sonraki karakteri al
        JMP PUT_LOOP		; Basa don
PUT_FIN:
	POP BX
	RET 
PUT_STR	ENDP

CSEG 	ENDS 
	END ANA