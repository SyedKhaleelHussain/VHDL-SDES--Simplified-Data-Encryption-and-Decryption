# VHDL Based Implementation of SDES – Simplified Data Encryption and Decryption

This repository contains a complete VHDL implementation of the **Simplified Data Encryption Standard (SDES)**, a lightweight encryption algorithm often used for educational purposes in cryptography and digital design.

##  Project Description

- **Language:** VHDL  
- **Tool:** Xilinx Vivado  
- **Type:** Behavioral Modeling  
- **Modules Implemented:**  
  - Key Generation (Key Scheduling)
  - SDES Encryption Unit
  - SDES Decryption Unit
- **Simulation:** Performed using Vivado Simulator with functional testbenches

This project showcases how a symmetric encryption algorithm can be realized in hardware using combinational and sequential logic in VHDL.

##  Objective

To design and simulate a hardware-level encryption and decryption system using SDES. This project demonstrates:
- Bit-level data manipulation
- Use of S-boxes and permutation functions
- Finite-state based functional decomposition

##  Functional Modules

| Module          | Description                                     |
|-----------------|-------------------------------------------------|
| `key_sdes.vhd`  | Generates two 8-bit subkeys from 10-bit main key|
| `encrypter_sdes.vhd` | Encrypts an 8-bit plaintext using SDES    |
| `decrypter_sdes.vhd` | Decrypts an 8-bit ciphertext               |
| `testbench.vhd` | Simulates the encryption-decryption loop       |

##  Tools & Technologies

-  **Vivado Design Suite** by Xilinx
-  **VHDL (IEEE 1164, NUMERIC_STD libraries)**
-  Behavioral simulation for verification







##  Project Flow
DES Encryption Process Timeline
Start
Key Generation
Beginning of the DES process
Creation of Key1 and Key2
Round 1
Initial Permutation
First round of encryption
Initial rearrangement of plaintext
Round 2
Inverse IP
Second round of encryption
Final rearrangement to produce ciphertext
End
Completion of the DES process![image](https://github.com/user-attachments/assets/bd4231f0-1c10-4b10-9737-835ad4d0b298)



##  How to Run

1. Clone the repo:
    ```bash
    git clone https://github.com/your-username/sdes-vhdl.git
    ```
2. Open Vivado and create a new project.
3. Add the `.vhd` source files under the `src/` folder.
4. Add `testbench.vhd` under simulation sources.
5. Run simulation to verify correctness.

## ?? License

This project is open source and available under the MIT License.
