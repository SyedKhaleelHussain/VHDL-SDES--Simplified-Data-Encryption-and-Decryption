----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.10.2023 02:57:58
-- Design Name: 
-- Module Name: decrypter_sdes - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Simplified Data Encryption Standard (S-DES) decryption module
-- Implements the S-DES decryption algorithm with 8-bit ciphertext input and 8-bit plaintext output
-- Uses the same 10-bit key as encryption but applies subkeys in reverse order
-- 
-- Dependencies: 
-- Requires key_sdes component for key generation
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity decrypter_sdes is
Port (
    text_input: in std_logic_vector(7 downto 0);   -- 8-bit ciphertext input
    decypher_text: out std_logic_vector(7 downto 0); -- 8-bit decrypted plaintext output
    key: in std_logic_vector(9 downto 0)           -- 10-bit decryption key (same as encryption key)
);
end decrypter_sdes;

architecture Behavioral of decrypter_sdes is

-- Component declaration for key generation (same as encryption)
component key_sdes is
    Port ( 
        key : in STD_LOGIC_vector(9 downto 0);  -- 10-bit input key
        key1: out std_logic_vector(7 downto 0); -- First 8-bit subkey
        key2: out std_logic_vector(7 downto 0)  -- Second 8-bit subkey
    );
end component;

-- Internal signals
signal IP: std_logic_vector(7 downto 0);         -- Initial Permutation output
signal xor1: std_logic_vector(7 downto 0);       -- Result of first XOR operation
signal xor2: std_logic_vector(7 downto 0);       -- Result of second XOR operation
signal key1, key2: std_logic_vector(7 downto 0); -- Subkeys from key schedule
signal s0: std_logic_vector(1 downto 0);         -- S0 box output
signal s1: std_logic_vector(1 downto 0);         -- S1 box output
signal s0_1: std_logic_vector(1 downto 0);       -- S0 box output (second round)
signal s1_1: std_logic_vector(1 downto 0);       -- S1 box output (second round)
signal fk1: std_logic_vector(3 downto 0);        -- FK1 function output
signal fk2: std_logic_vector(3 downto 0);        -- FK2 function output
signal switch: std_logic_vector(7 downto 0);     -- Swapped halves between rounds
signal output_fk2: std_logic_vector(7 downto 0); -- Output after second round

-- Expansion/Permutation (E/P) function (same as encryption)
function E_P(in_1: std_logic_vector(3 downto 0))
return std_logic_vector is
variable output: unsigned(7 downto 0);
begin
    -- E/P mapping (4-bit input to 8-bit output)
    output(7) := in_1(0);
    output(6) := in_1(3);
    output(5) := in_1(2);
    output(4) := in_1(1);
    output(3) := in_1(2);
    output(2) := in_1(1);
    output(1) := in_1(0);
    output(0) := in_1(3);
    return std_logic_vector(output);
end;

-- Inverse Initial Permutation function (same as encryption)
function IP_inverse(input1: std_logic_vector(7 downto 0))
return std_logic_vector is
variable output: std_logic_vector(7 downto 0);
begin
    -- IP^-1 mapping
    output(7) := input1(4);
    output(6) := input1(7);
    output(5) := input1(5);
    output(4) := input1(3);
    output(3) := input1(1);
    output(2) := input1(6);
    output(1) := input1(0);
    output(0) := input1(2);
    return std_logic_vector(output);
end;

-- S0 substitution box function (same as encryption)
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
    -- S0 box definition
    matrix_values(0,0) := "01";
    matrix_values(0,1) := "00";
    matrix_values(0,2) := "11";
    matrix_values(0,3) := "10";

    matrix_values(1,0) := "11";
    matrix_values(1,1) := "10";
    matrix_values(1,2) := "01";
    matrix_values(1,3) := "00";

    matrix_values(2,0) := "00";
    matrix_values(2,1) := "10";
    matrix_values(2,2) := "01";
    matrix_values(2,3) := "11";

    matrix_values(3,0) := "11";
    matrix_values(3,1) := "01";
    matrix_values(3,2) := "11";
    matrix_values(3,3) := "10";

    -- Determine row (bits 0 and 3)
    row := input1(0) & input1(3);
    row1 := to_integer(unsigned(row));
    -- Determine column (bits 1 and 2)
    coloumn := input1(2) & input1(1);
    coloumn1 := to_integer(unsigned(coloumn));
    -- Get value from S-box
    output := unsigned(matrix_values(row1,coloumn1));

    return std_logic_vector(output);
end;

-- S1 substitution box function (same as encryption)
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
    -- S1 box definition
    matrix_values(0,0) := "00";
    matrix_values(0,1) := "01";
    matrix_values(0,2) := "10";
    matrix_values(0,3) := "11";

    matrix_values(1,0) := "10";
    matrix_values(1,1) := "00";
    matrix_values(1,2) := "01";
    matrix_values(1,3) := "11";

    matrix_values(2,0) := "11";
    matrix_values(2,1) := "00";
    matrix_values(2,2) := "01";
    matrix_values(2,3) := "00";

    matrix_values(3,0) := "10";
    matrix_values(3,1) := "01";
    matrix_values(3,2) := "00";
    matrix_values(3,3) := "11";

    -- Determine row (bits 0 and 3)
    row(0) := input1(0);
    row(1) := input1(3);
    row1 := to_integer(unsigned(row));
    -- Determine column (bits 1 and 2)
    coloumn := input1(1) & input1(2);
    coloumn1 := to_integer(unsigned(coloumn));
    -- Get value from S-box
    output := unsigned(matrix_values(row1,coloumn1));

    return std_logic_vector(output);
end;

-- P4 permutation function (same as encryption)
function p4(input1: std_logic_vector(3 downto 0))
return std_logic_vector is
variable p4_out: std_logic_vector(3 downto 0);
begin
    -- P4 permutation mapping
    p4_out(3) := input1(2);
    p4_out(2) := input1(0);
    p4_out(1) := input1(1);
    p4_out(0) := input1(3);
    return std_logic_vector(p4_out);
end;

-- Initial Permutation (IP) function (same as encryption)
function IP_1(text_input: std_logic_vector(7 downto 0))
return std_logic_vector is
variable IP: std_logic_vector(7 downto 0);
begin
    -- IP mapping
    IP(7) := text_input(6);
    IP(6) := text_input(2);
    IP(5) := text_input(5);
    IP(4) := text_input(7);
    IP(3) := text_input(4);
    IP(2) := text_input(0);
    IP(1) := text_input(3);
    IP(0) := text_input(1);
    return std_logic_vector(IP);
end;

-- Main architecture begins
begin
    -- Key generation component instantiation (same as encryption)
    tb: key_sdes port map(
        key => key,     -- Connect 10-bit input key
        key1 => key1,   -- Receive first subkey
        key2 => key2    -- Receive second subkey
    );

    -- Initial Permutation of ciphertext (same as encryption IP)
    IP <= IP_1(text_input);

    -- First Round (using key2 first - reverse order from encryption):
    -- 1. Apply E/P to right half (bits 3-0)
    -- 2. XOR with key2 (instead of key1 in encryption)
    xor1 <= E_P(IP(3 downto 0)) xor key2;
    
    -- Apply S-boxes to left and right halves of XOR result
    s0 <= s0_block(xor1(7 downto 4));  -- S0 box for bits 7-4
    s1 <= s1_block(xor1(3 downto 0));  -- S1 box for bits 3-0
    
    -- Apply P4 permutation to S-box outputs and XOR with left half
    fk1 <= IP(7 downto 4) xor p4(s0 & s1);

    -- Swap halves for next round
    switch <= IP(3 downto 0) & fk1;

    -- Second Round (using key1 - reverse order from encryption):
    -- 1. Apply E/P to new right half (bits 3-0 of switched output)
    -- 2. XOR with key1 (instead of key2 in encryption)
    xor2 <= E_P(switch(3 downto 0)) xor key1;
    
    -- Apply S-boxes again
    s0_1 <= s0_block(xor2(7 downto 4));  -- S0 box for bits 7-4
    s1_1 <= s1_block(xor2(3 downto 0));  -- S1 box for bits 3-0
    
    -- Apply P4 permutation to S-box outputs and XOR with left half
    fk2 <= switch(7 downto 4) xor p4(s0_1 & s1_1);
    
    -- Combine results
    output_fk2 <= fk2 & switch(3 downto 0);

    -- Apply inverse initial permutation to get final plaintext
    decypher_text <= IP_inverse(output_fk2);

end Behavioral;