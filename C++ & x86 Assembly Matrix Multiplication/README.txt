# C++ & Assembly (x86) Matrix Multiplication

This project implements matrix multiplication (C = A * B) using a hybrid approach with C++ and x86 Assembly (MASM). The primary goal is to demonstrate the integration of a high-level language with low-level assembly code, illustrating Stack-based parameter passing, register preservation conventions, and low-level memory addressing.

## Overview

* Hybrid Architecture: Seamless compilation and linking of C++ and Assembly modules.
* Low-Level Memory Management: Accessing 2D matrices stored as 1D arrays using manual pointer arithmetic.
* Stack Frame Management: Handling function parameters and local variables manually via the Stack Pointer (ESP) and Base Pointer (EBP).
* Defensive Programming: Preserves all critical registers (EAX, EBX, ECX, EDX, ESI, EDI) to ensure stability.
* 8086 Architecture Compatibility: Utilizes basic SHL and ADD instructions for address calculation instead of modern addressing modes.

## Technical Details

### Matrix Multiplication Algorithm
The project implements the classic O(N^3) algorithm:
C[i,j] = Sum(A[i,k] * B[k,j])

Since matrices are stored as flat 1D arrays in memory, elements are accessed using the following offset formula:
Address = BaseAddress + (Row * ColCount + Col) * 4 bytes

### Stack Frame Layout (Memory Map)
When the matmul_asm function is called, the Stack is organized as follows:

HIGH MEMORY
[EBP + 28] : B_cols (int)      -> 6th Parameter
[EBP + 24] : A_cols (int)      -> 5th Parameter
[EBP + 20] : A_rows (int)      -> 4th Parameter
[EBP + 16] : C Address (ptr)   -> 3rd Parameter (Result)
[EBP + 12] : B Address (ptr)   -> 2nd Parameter
[EBP + 8]  : A Address (ptr)   -> 1st Parameter
[EBP + 4]  : Return Address
[EBP]      : Saved EBP
------------------------------------
[EBP - 4]  : i counter (local var)
[EBP - 8]  : j counter (local var)
[EBP - 12] : k counter (local var)
LOW MEMORY

## Setup & Execution

1. Prerequisites:
   - Visual Studio 2022.
   - "Desktop development with C++" workload installed.

2. Configuration:
   - Enable MASM: Right-click Project -> Build Dependencies -> Build Customizations -> Check 'masm'.
   - Architecture: Set the build target to x86 (Debug or Release) in the top toolbar.

3. Run:
   - Press F5 or click Local Windows Debugger.

## License

This project is open-source and available for educational purposes.
