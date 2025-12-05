# C++ & x86 Assembly Matrix Multiplication

This project implements matrix multiplication $(C = A \times B)$ using a hybrid approach with **C++** and **x86 Assembly (MASM)**. The primary goal is to demonstrate the integration of a high-level language with low-level assembly code, illustrating **Stack-based parameter passing**, register preservation conventions, and low-level memory addressing.

## 🚀 Features

* **Hybrid Architecture:** Seamless compilation and linking of C++ and Assembly modules.
* **Low-Level Memory Management:** Accessing 2D matrices stored as 1D arrays using manual pointer arithmetic.
* **Stack Frame Management:** Handling function parameters and local variables manually via the Stack Pointer (ESP) and Base Pointer (EBP).
* **Defensive Programming:** Preserves all `Callee-saved` and `Caller-saved` registers (EAX, EBX, ECX, EDX, ESI, EDI) to ensure stability compliant with strict assignment requirements.
* **8086 Architecture Compatibility:** Utilizes basic `SHL` and `ADD` instructions for address calculation instead of modern "Scaled Index" addressing modes, mimicking legacy 8086 limitations.

## 🛠️ Technologies Used

* **Languages:** C++ (Driver code, verification), Assembly x86 (MASM)
* **IDE:** Visual Studio 2022
* **Architecture:** x86 (32-bit)

## ⚙️ Setup & Execution

Follow these steps to run the project on your local machine:

1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/yourusername/project-name.git](https://github.com/yourusername/project-name.git)
    ```

2.  **Open in Visual Studio:**
    Open the `HW1.sln` file using Visual Studio 2022.

3.  **Enable MASM:**
    * Right-click on the project in Solution Explorer -> **Build Dependencies** -> **Build Customizations...** -> Check the **masm** box.

4.  **Set Architecture (Crucial!):**
    * Since the Assembly code utilizes 32-bit registers (EAX, EBX, etc.), ensure the build target is set to **x86** (not x64) in the Visual Studio toolbar.

5.  **Build and Run:**
    Click the `Local Windows Debugger` button to compile and execute the program.

## 🧠 Technical Details

### Matrix Multiplication Algorithm
The project implements the classic $O(N^3)$ algorithm:
$$C[i,j] = \sum_{k=0}^{n-1} A[i,k] \times B[k,j]$$

Since matrices are stored as flat 1D arrays in memory, elements are accessed using the following offset formula:
`Address = BaseAddress + (Row * ColCount + Col) * 4` (4 bytes for `int`)

### Stack Frame Layout
When the `matmul_asm` function is called by C++, the Stack is organized as follows:

```text
HIGH MEMORY
[EBP + 28] : B_cols (int)      -> 6th Param
[EBP + 24] : A_cols (int)      -> 5th Param
[EBP + 20] : A_rows (int)      -> 4th Param
[EBP + 16] : C Address (ptr)   -> 3rd Param (Result Matrix)
[EBP + 12] : B Address (ptr)   -> 2nd Param
[EBP + 8]  : A Address (ptr)   -> 1st Param
[EBP + 4]  : Return Address
[EBP]      : Saved EBP
------------------------------------
[EBP - 4]  : i counter (local var)
[EBP - 8]  : j counter (local var)
[EBP - 12] : k counter (local var)
LOW MEMORY


