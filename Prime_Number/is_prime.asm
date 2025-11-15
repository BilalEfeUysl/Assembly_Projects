CSEG SEGMENT PARA 'CODE'
    ASSUME CS:CSEG

    PUBLIC ISPRIME ; Bu proceduru public yap

ISPRIME PROC FAR
    ; Girdi: AX = Kontrol edilecek sayi
    ; Cikti: AX = 1 (Asal) veya 0 (Asal Degil)
    
    ; --- Register'lari koru ---
    PUSH CX
    PUSH DX
    PUSH BX

    ; --- Ozel Durumlar ---
    CMP AX, 1
    JBE SET_NOT_PRIME  ; 1 veya daha kucukse asal degil

    CMP AX, 2
    JE SET_IS_PRIME    ; 2 ise asal

    ; Cift sayi mi? (2 disindaki cift sayilar asal degildir)
    TEST AX, 1         ; Son biti kontrol et (1 ise tek, 0 ise cift)
    JZ SET_NOT_PRIME   ; Ciftse (JZ=Jump if Zero) asal degil

    ; --- Asal sayi testi (Tek sayilarla bolme) ---
    MOV CX, 3          ; Ilk bolen (CX) = 3
    
PRIME_LOOP:
    ; --- AX'i CX'e bolmeyi test et ---
    MOV DX, 0          ; Bolme icin DX'i sifirla
    PUSH AX            ; AX'i (sayiyi) koru
    DIV CX             ; AX = AX / CX (Kalan DX'te)
    POP AX             ; Orijinal AX'i geri al
    
    CMP DX, 0          ; Kalan 0 mi? (Tam bolundu mu?)
    JE SET_NOT_PRIME   ; Evetse asal degil, cik
    
    ; --- Optimizasyon: Bolen > Karekok(Sayi) ise dur ---
    PUSH AX            ; Sayiyi (BX'e atmak icin) koru
    MOV AX, CX         ; Boleni (CX) al
    MUL CX             ; AX = CX * CX (Bolenin karesi)
    POP BX             ; Sayiyi BX'e al
    
    CMP AX, BX         ; Bolenin Karesi > Sayi mi?
    JA SET_IS_PRIME    ; Evetse, daha fazla bolmeye gerek yok, asaldir
    
    MOV AX,BX          ; AX'i (orijinal sayi) geri yukle (DIV bozdugu icin)

    ADD CX, 2          ; Sonraki tek sayi boleni dene (3, 5, 7...)
    JMP PRIME_LOOP
    
SET_NOT_PRIME:
    MOV AX, 0          ; Sonuc = 0 (Asal Degil)
    JMP PRIME_FINISH

SET_IS_PRIME:
    MOV AX, 1          ; Sonuc = 1 (Asal)

PRIME_FINISH:
    ; --- Register'lari geri yukle ---
    POP BX
    POP DX
    POP CX
    RETF               ; Cik
ISPRIME ENDP

CSEG ENDS
END