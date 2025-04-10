
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.10.2023 02:57:58
-- Design Name: 
-- Module Name: encryption_sdes - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Simplified Data Encryption Standard (S-DES) Encryption Module
-- Implements the full S-DES encryption algorithm with:
-- - Initial Permutation (IP)
-- - Two rounds of FK function with key mixing
-- - Switch function between rounds
-- - Inverse Initial Permutation (IP-1)
-- Provides debug outputs for intermediate values (fk1 and fk2)
-- 
-- Dependencies: 
-- Requires key_sdes component for key generation
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Follows the standard S-DES algorithm with 8-bit blocks and 10-bit key
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;  -- For arithmetic operations

entity encryption_sdes is
Port (
    text_input: in std_logic_vector(7 downto 0);   -- 8-bit plaintext input
    cypher_text: out std_logic_vector(7 downto 0); -- 8-bit ciphertext output
    fk1_value: out std_logic_vector(3 downto 0);   -- Debug output for first round FK
    fk2_value: out std_logic_vector(3 downto 0);   -- Debug output for second round FK
    key: in std_logic_vector(9 downto 0)           -- 10-bit encryption key
);
end encryption_sdes;

architecture Behavioral of encryption_sdes is

-- Key generation component declaration
component key_sdes is
    Port ( 
        key : in STD_LOGIC_vector(9 downto 0);  -- Input key
        key1: out std_logic_vector(7 downto 0); -- First round key
        key2: out std_logic_vector(7 downto 0)  -- Second round key
    );
end component;

-- Internal signals
signal IP: std_logic_vector(7 downto 0);         -- After Initial Permutation
signal xor1: std_logic_vector(7 downto 0);       -- First round XOR result
signal xor2: std_logic_vector(7 downto 0);       -- Second round XOR result
signal key1, key2: std_logic_vector(7 downto 0); -- Round keys from key schedule
signal s0, s1: std_logic_vector(1 downto 0);     -- S-box outputs (first round)
signal s0_1, s1_1: std_logic_vector(1 downto 0); -- S-box outputs (second round)
signal fk1, fk2: std_logic_vector(3 downto 0);   -- FK function outputs
signal switch: std_logic_vector(7 downto 0);     -- After switching halves
signal output_fk2: std_logic_vector(7 downto 0); -- Final output before IP-1

------------------------------------------------------------------------------
-- Expansion/Permutation (E/P) Function
-- Expands 4-bit input to 8-bit output according to S-DES specification
------------------------------------------------------------------------------
function E_P(in_1: std_logic_vector(3 downto 0))
return std_logic_vector is
variable output: unsigned(7 downto 0);
begin
    -- E/P mapping (bits numbered from left to right 7 downto 0)
    output(7) := in_1(0);  -- Bit 0 maps to position 7
    output(6) := in_1(3);  -- Bit 3 maps to position 6
    output(5) := in_1(2);  -- Bit 2 maps to position 5
    output(4) := in_1(1);  -- Bit 1 maps to position 4
    output(3) := in_1(2);  -- Bit 2 maps to position 3 (duplicate)
    output(2) := in_1(1);  -- Bit 1 maps to position 2 (duplicate)
    output(1) := in_1(0);  -- Bit 0 maps to position 1 (duplicate)
    output(0) := in_1(3);  -- Bit 3 maps to position 0 (duplicate)
    return std_logic_vector(output);
end function;

------------------------------------------------------------------------------
-- Inverse Initial Permutation (IP-1) Function
-- Final permutation to produce ciphertext
------------------------------------------------------------------------------
function IP_inverse(input1: std_logic_vector(7 downto 0))
return std_logic_vector is
variable output: std_logic_vector(7 downto 0);
begin
    -- IP-1 mapping (bits numbered from left to right 7 downto 0)
    output(7) := input1(4);  -- Bit 4 maps to position 7
    output(6) := input1(7);  -- Bit 7 maps to position 6
    output(5) := input1(5);  -- Bit 5 maps to position 5
    output(4) := input1(3);  -- Bit 3 maps to position 4
    output(3) := input1(1);  -- Bit 1 maps to position 3
    output(2) := input1(6);  -- Bit 6 maps to position 2
    output(1) := input1(0);  -- Bit 0 maps to position 1
    output(0) := input1(2);  -- Bit 2 maps to position 0
    return output;
end function;

------------------------------------------------------------------------------
-- S0 Substitution Box Function
-- Nonlinear substitution for first 4 bits of XOR result
------------------------------------------------------------------------------
function s0_block(input1: std_logic_vector(3 downto 0))
return std_logic_vector is
variable output: unsigned(1 downto 0);
variable row: unsigned(1 downto 0);
variable row1: integer;
variable coloumn: unsigned(1 downto 0);
variable coloumn1: integer;
type matrix is ARRAY (0 to 3, 0 to 3) of std_logic_vector (1 downto 0);
variable matrix_values: matrix;
begin
    -- S0 box definition (standard S-DES values)
    matrix_values(0,0) := "01"; matrix_values(0,1) := "00"; 
    matrix_values(0,2) := "11"; matrix_values(0,3) := "10";

    matrix_values(1,0) := "11"; matrix_values(1,1) := "10"; 
    matrix_values(1,2) := "01"; matrix_values(1,3) := "00";

    matrix_values(2,0) := "00"; matrix_values(2,1) := "10"; 
    matrix_values(2,2) := "01"; matrix_values(2,3) := "11";

    matrix_values(3,0) := "11"; matrix_values(3,1) := "01"; 
    matrix_values(3,2) := "11"; matrix_values(3,3) := "10";

    -- Determine row from bits 0 and 3
    row := input1(0) & input1(3);
    row1 := to_integer(unsigned(row));
    -- Determine column from bits 1 and 2
    coloumn := input1(2) & input1(1);
    coloumn1 := to_integer(unsigned(coloumn));
    -- Get substitution value
    output := unsigned(matrix_values(row1,coloumn1));
    return std_logic_vector(output);
end function;

------------------------------------------------------------------------------
-- S1 Substitution Box Function
-- Nonlinear substitution for last 4 bits of XOR result
------------------------------------------------------------------------------
function s1_block(input1: std_logic_vector(3 downto 0))
return std_logic_vector is
variable output: unsigned(1 downto 0);
variable row: unsigned(1 downto 0);
variable row1: integer;
variable coloumn: unsigned(1 downto 0);
variable coloumn1: integer;
type matrix is ARRAY (0 to 3, 0 to 3) of std_logic_vector (1 downto 0);
variable matrix_values: matrix;
begin
    -- S1 box definition (standard S-DES values)
    matrix_values(0,0) := "00"; matrix_values(0,1) := "01"; 
    matrix_values(0,2) := "10"; matrix_values(0,3) := "11";

    matrix_values(1,0) := "10"; matrix_values(1,1) := "00"; 
    matrix_values(1,2) := "01"; matrix_values(1,3) := "11";

    matrix_values(2,0) := "11"; matrix_values(2,1) := "00"; 
    matrix_values(2,2) := "01"; matrix_values(2,3) := "00";

    matrix_values(3,0) := "10"; matrix_values(3,1) := "01"; 
    matrix_values(3,2) := "00"; matrix_values(3,3) := "11";

    -- Determine row from bits 0 and 3
    row(0) := input1(0);
    row(1) := input1(3);
    row1 := to_integer(unsigned(row));
    -- Determine column from bits 1 and 2
    coloumn := input1(1) & input1(2);
    coloumn1 := to_integer(unsigned(coloumn));
    -- Get substitution value
    output := unsigned(matrix_values(row1,coloumn1));
    return std_logic_vector(output);
end function;

------------------------------------------------------------------------------
-- P4 Permutation Function
-- Permutes the concatenated S-box outputs
------------------------------------------------------------------------------
function p4(input1: std_logic_vector(3 downto 0))
return std_logic_vector is
variable p4_out: std_logic_vector(3 downto 0);
begin
    -- P4 permutation mapping
    p4_out(3) := input1(2);  -- Bit 2 -> position 3
    p4_out(2) := input1(0);  -- Bit 0 -> position 2
    p4_out(1) := input1(1);  -- Bit 1 -> position 1
    p4_out(0) := input1(3);  -- Bit 3 -> position 0
    return p4_out;
end function;

------------------------------------------------------------------------------
-- Initial Permutation (IP) Function
-- First permutation of plaintext
------------------------------------------------------------------------------
function IP_1(text_input: std_logic_vector(7 downto 0))
return std_logic_vector is
variable IP: std_logic_vector(7 downto 0);
begin
    -- IP mapping (bits numbered from left to right 7 downto 0)
    IP(7) := text_input(6);  -- Bit 6 -> position 7
    IP(6) := text_input(2);  -- Bit 2 -> position 6
    IP(5) := text_input(5);  -- Bit 5 -> position 5
    IP(4) := text_input(7);  -- Bit 7 -> position 4
    IP(3) := text_input(4);  -- Bit 4 -> position 3
    IP(2) := text_input(0);  -- Bit 0 -> position 2
    IP(1) := text_input(3);  -- Bit 3 -> position 1
    IP(0) := text_input(1);  -- Bit 1 -> position 0
    return IP;
end function;

------------------------------------------------------------------------------
-- Main Encryption Process
------------------------------------------------------------------------------
begin
    -- Instantiate key generator to produce round keys
    tb: key_sdes port map(
        key => key,   -- Input 10-bit key
        key1 => key1, -- Output first round key
        key2 => key2  -- Output second round key
    );

    -- Apply Initial Permutation to plaintext
    IP <= IP_1(text_input);

    -- First Round FK Function:
    -- 1. Expand/permute right half (IP(3 downto 0))
    -- 2. XOR with first round key (key1)
    xor1 <= E_P(IP(3 downto 0)) xor key1;
    
    -- Apply S-boxes to left and right halves of XOR result
    s0 <= s0_block(xor1(7 downto 4));  -- First 4 bits through S0
    s1 <= s1_block(xor1(3 downto 0));  -- Last 4 bits through S1
    
    -- Apply P4 permutation to S-box outputs and XOR with left half
    fk1 <= IP(7 downto 4) xor p4(s0 & s1);
    fk1_value <= fk1;  -- Output first round FK for debugging

    -- Switch left and right halves for second round
    switch <= IP(3 downto 0) & fk1;

    -- Second Round FK Function:
    -- 1. Expand/permute new right half (switch(3 downto 0))
    -- 2. XOR with second round key (key2)
    xor2 <= E_P(switch(3 downto 0)) xor key2;
    
    -- Apply S-boxes again
    s0_1 <= s0_block(xor2(7 downto 4));  -- First 4 bits through S0
    s1_1 <= s1_block(xor2(3 downto 0));  -- Last 4 bits through S1
    
    -- Apply P4 permutation to S-box outputs and XOR with left half
    fk2 <= switch(7 downto 4) xor p4(s0_1 & s1_1);
    output_fk2 <= fk2 & switch(3 downto 0);  -- Combine results
    fk2_value <= fk2;  -- Output second round FK for debugging

    -- Apply Inverse Initial Permutation to get final ciphertext
    cypher_text <= IP_inverse(output_fk2);

end Behavioral;