.386
.model flat, c
.code

PUBLIC matmul_asm

matmul_asm PROC NEAR
    
    push ebp        ; Eski EBP sakla
    mov ebp, esp    
    
    ; i, j, k için yer aç
    sub esp, 12     

    ; Tüm registerlarýn eski deðerini koruma
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

    ; [EBP + 28] : B_cols  
    ; [EBP + 24] : A_cols  
    ; [EBP + 20] : A_rows  
    ; [EBP + 16] : C Adresi   
    ; [EBP + 12] : B Adresi 
    ; [EBP + 8]  : A Adresi 
    ; [EBP + 4]  : Geri Dönüþ Adresi
    ; [EBP]      : Eski EBP Deðeri
    ; [EBP - 4]  : i sayacý 
    ; [EBP - 8]  : j sayacý 
    ; [EBP - 12] : k sayacý 
    

    
    mov DWORD PTR [ebp-4], 0     ; i = 0

L_I_LOOP:
    mov eax, [ebp-4]             ; i'yi yükle
    cmp eax, [ebp+20]            ; i < A_rows ?
    jge L_I_END

    
    mov DWORD PTR [ebp-8], 0     ; j = 0

L_J_LOOP:
    mov eax, [ebp-8]             ; j'yi yükle
    cmp eax, [ebp+28]            ; j < B_cols ?
    jge L_J_END

    
    mov DWORD PTR [ebp-12], 0    ; k = 0
    xor edi, edi                 ; sum = 0 

L_K_LOOP:
    mov eax, [ebp-12]            ; k'yi yükle
    cmp eax, [ebp+24]            ; k < A_cols ?
    jge L_K_END

    ; A matrisinden eleman okuma 
    
    mov eax, [ebp-4]             ; EAX = i
    
    imul DWORD PTR [ebp+24]      ; EAX = i * A_cols

    ; k ekle
    add eax, [ebp-12]            ; EAX = (i * A_cols) + k

    ; 4 ile çarpma iþlemi
    shl eax, 1                   ; EAX = Ýndis * 2 (Byte ofset)
    shl eax, 1                   ; EAX = (Ýndis * 2) * 4 (Byte ofset)

    ; Base adresi ekle iþlemi
    add eax, [ebp+8]             ; EAX = A matrisinin o elemanýnýn RAM adresi

    ; Deðeri okuma iþlemi
    mov ecx, [eax]               ; ECX = A[i][k] deðerini sakla

    ; B matrisinden eleman okuma (B[k][j]) 

    ; k * B_cols
    mov eax, [ebp-12]            ; EAX = k
    imul DWORD PTR [ebp+28]      ; EAX = k * B_cols 

    ; j ekle
    add eax, [ebp-8]             ; EAX = (k * B_cols) + j

    ; 4 ile çarpma iþlemi
    shl eax, 1                   ; EAX = Ýndis * 2 (Byte ofset)
    shl eax, 1                   ; EAX = (Ýndis * 2) * 4 (Byte ofset)

    ; Base adresi ekle
    add eax, [ebp+12]           

    ; Deðeri oku 
    mov ebx, [eax]               ; EBX = B[k][j]

    ; sum += A_val * B_val
    
    mov eax, ecx                 ; EAX = A'nýn deðeri
    imul ebx                     ; EAX = EAX * EBX (Sonuç EDX:EAX'te)
    
    add edi, eax                 ; sum (EDI) += Çarpým sonucu

    ; k arttýr ve döngüye dön
    inc DWORD PTR [ebp-12]
    jmp L_K_LOOP

L_K_END:
    
    ; SONUCU YAZMA: C[i][j] = sum
    ; Adres = C_base + (i * B_cols + j) * 4
        
    mov eax, [ebp-4]             ; EAX = i
    imul DWORD PTR [ebp+28]      ; EAX = i * B_cols
    add eax, [ebp-8]             ; EAX = (i * B_cols) + j

    ; 4 ile çarpma iþlemi
    shl eax, 1                   ; EAX = Ýndis * 2 (Byte ofset)
    shl eax, 1                   ; EAX = (Ýndis * 2) * 4 (Byte ofset)
    add eax, [ebp+16]            ; EAX = C matrisinin hedef adresi

    mov [eax], edi               ; C[i][j] = sum

    ; j arttýr ve döngüye dön
    inc DWORD PTR [ebp-8]
    jmp L_J_LOOP

L_J_END:
    ; i arttýr ve döngüye dön
    inc DWORD PTR [ebp-4]
    jmp L_I_LOOP

L_I_END:

    ; eski deðerleri geri almak için pop yapýyoruz
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    mov esp, ebp
    pop ebp

    ret
matmul_asm ENDP

END

