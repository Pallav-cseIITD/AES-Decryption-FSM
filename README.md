# AES-Decryption-FSM
1\. Overview

This project implements the full Advanced Encryption Standard (AES) decryption process on an FPGA using a Basys3 board. The system integrates previously designed compute and memory units with a Finite State Machine (FSM) to perform decryption operations and display the plaintext on a seven-segment display.

2\. Problem Description

The project aims to decrypt 128-bit ciphertext using a 128-bit key and display the resulting plaintext. The decryption process follows the AES algorithm, which involves multiple rounds of transformations. The inputs and outputs are managed as follows:

Inputs:

1.  Ciphertext stored in a COE file in block RAM.
2.  Round keys stored in ROM, also provided via the COE file.

Outputs:

1.  Plaintext displayed on the Basys3 seven-segment display.
2.  A default value ("-") shown for unsupported characters.

3\. Solution Approach

The implementation is structured into key components to ensure clarity and modularity.

4\. Key Components

1\. Memory Units:

-   Read-Only Memory (ROM): Stores the ciphertext and keys.
-   Read-Write Memory (RAM): Holds intermediate decryption results.
-   Registers: Temporarily store intermediate values between clock cycles.

2\. Compute Units:

-   InvMixColumns: Reverses the MixColumns operation using Galois Field arithmetic.
-   InvShiftRows: Shifts rows to their original positions.
-   InvSubBytes: Substitutes bytes using the inverse S-box.
-   AddRoundKey: XORs the state with the round key in reverse order.

3\. Control FSM:

The FSM coordinates the decryption process by:

-   Controlling memory read/write operations.
-   Ensuring the correct sequence of AES transformations.
-   Managing intermediate data flow between compute units.

4\. Display Logic:

-   Converts final plaintext values to ASCII.
-   Cycles the display of four characters at a time on the seven-segment display.
-   Displays a default "-" for characters outside the 0-F range.

5\. Process Flow

1.  Initialization:
    -   Load ciphertext and keys into memory.
    -   Initialize FSM to start decryption.
2.  Decryption Rounds (10 Rounds):
    -   Perform the following for each round:
        -   AddRoundKey
        -   InvShiftRows
        -   InvSubBytes
        -   InvMixColumns (skipped in the final round)
    -   Update intermediate results in RAM or registers.
3.  Final Processing:
    -   Convert the final state to plaintext.
    -   Format plaintext for the seven-segment display.
4.  Output Display:
    -   Scroll the plaintext cyclically on the Basys3 display.
    -   Show "-" for unsupported characters.

6\. Example

Input:

A COE file with the following format:

memory_initialization_radix=16;

memory_initialization_vector=

C0DEFEEDBADC0FFEE...

Output:

Plaintext displayed cyclically as:

H E L L

O W O

R L D

7\. Tools and Resources

1.  Vivado IDE: For design, simulation, and implementation.
2.  Basys3 Board: For displaying the plaintext.
3.  VHDL Modules: Used to implement compute units and FSM logic.
4.  ASCII Table: For converting decrypted values to readable text.

This comprehensive design ensures robust decryption and effective visualization of the output plaintext, leveraging modular hardware components.
