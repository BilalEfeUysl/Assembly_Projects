;  MEAN SQUARED ERROR (MSE) HESAPLAMA

STK SEGMENT PARA STACK 'STACK'
        DW 30 DUP(?)
STK ENDS

DSG SEGMENT PARA 'DATA'
        SUM     DD    0         
        MSE     Dw    0        
        ;VAR     DB    FBH    Normalde FBH ın başına 0 koymadığımız için hata veriyordu fakat zaten bu değeri hiçbir yerde kullanmadığımızdan kaldırdım 15.        
        D1      DW    10,  1, -3,  7,  0
        D2      DW    5,  5,  8, -6,  9
        N       DW    5
DSG ENDS

CSG SEGMENT PARA 'CODE'
        ASSUME CS:CSG, DS:DSG, SS:STK   ;DATA SEGMENTI VE STACK SEGMENTI DOĞRU TANIMLAYARAK HATAYI DÜZELTTİM 1.
START PROC FAR ;ilk tanımladdığımız prosedüre far eklememiz lazım 2.                         

        PUSH  DS
        XOR   AX, AX
        PUSH  AX
        MOV   AX, DSG ;Stack segment yerine Data segmenti ayarlamamız gerkiyordu 5.                 
        MOV   DS, AX ;DS'nin içine AX değerini atmamıştık onu ekledim 3.

        XOR   AX, AX
        MOV   WORD PTR  [SUM],   AX      ;word ptr ekleyerek ax'in doğru şekilde atanmasını sağladım bunu aşağılarda da düzelttim.         
        MOV   WORD PTR  [SUM+2], AX

        LEA   SI, D1
        LEA   DI, D2
        MOV   CX, N           

    CALC_LOOP:
        MOV   AX, [SI]
        MOV   BX, [DI]

        SUB   AX, BX          
        JGE   NONNEG  ; Burada iki değer de negatif olabilir bu yüzden sadece işaret bitine 
                        ;bakmak yeterli olmayabilir AX'ın negatif olup olmadığına bakıyoruz  14.  

        NEG   AX      ; NOT işlemi complament alıyordu ama bizim istediğimiz negatif sayıyı pozitif yapmaktı bu yüzden NEG yaptım 6.        
    NONNEG:
        IMUL  AX    ; Biz AX 'in karesini almak istiyoruz fakat burada AX ile BX çarpılıyordu bu yüzden BX'i AX ile değiştiriyoruz 7.                    

        ADD   WORD PTR  [SUM],   AX
        ADC   WORD PTR  [SUM+2], DX  ; SUM'ın ilk iki byte'ını toplarken bir carry gelebilir o yüzden bunu da kontrol ederek eğer carry flag set ise
                                        ; SUM+2'ye 1 eklememiz gerekiyor bu yüzden ADD'yi ADC ile değiştirdim 8.       

        ADD   SI, 2  ; Dizinin bir sonraki elemanına geçerken her bir eleman word olarak tanımlandığı için 1 byte yerine 2 byte ilerlememiz gerekiyor 9.                   
        ADD   DI, 2     ; yukarıdakiyle aynı sebepten dolayı 1 yerine 2 byte ilerliyoruz 10.              
        LOOP  CALC_LOOP

        MOV   AX, WORD PTR [SUM]         ;AX ile DX'in yerlerini değiştirmemiz gerekiyor çünkü high kısmı DX'te low kısmı AX'te tutmamız gerekiyor 11.        
        MOV   DX, WORD PTR [SUM+2]
        MOV   CX, N   ; Bölme işlemi için bölen değeri CX'e yüklememiz gerekiyor çünkü DIV komutu böleni CX'ten alır 12.
        DIV   CX         ; CL kalsa yine çalışabilirdi fakat yine de CX olarak kullanmak istedim 13.                
        MOV   [MSE], AX

    RETF    ; FAR olarak tanımladığımız için bunun RET değil RETF olması gerekiyordu 4. 
START ENDP
CSG ENDS
END START
