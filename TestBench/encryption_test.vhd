----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.10.2023 04:48:06
-- Design Name: 
-- Module Name: encryption_test - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Testbench for S-DES encryption and decryption modules
-- Verifies the complete encryption/decryption cycle by:
-- 1. Encrypting a sample plaintext
-- 2. Decrypting the resulting ciphertext
-- 3. Comparing original plaintext with decrypted output
-- 
-- Dependencies: 
-- Requires encryption_sdes and decrypter_sdes components
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Note: This testbench currently only tests one fixed input case
-- Could be enhanced with multiple test cases and automatic verification
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Note: NUMERIC_STD not currently used but could be helpful for more complex testing
-- use IEEE.NUMERIC_STD.ALL;

entity encryption_test is
-- Testbench entity has no ports
end encryption_test;

architecture Behavioral of encryption_test is

-- Component declaration for S-DES encryption module
component encryption_sdes is
    Port (
        text_input: in std_logic_vector(7 downto 0);   -- 8-bit plaintext input
        cypher_text: out std_logic_vector(7 downto 0); -- 8-bit ciphertext output
        key: in std_logic_vector(9 downto 0)          -- 10-bit encryption key
    );
end component;

-- Component declaration for S-DES decryption module
component decrypter_sdes is
    Port (
        text_input: in std_logic_vector(7 downto 0);   -- 8-bit ciphertext input
        decypher_text: out std_logic_vector(7 downto 0); -- 8-bit decrypted output
        key: in std_logic_vector(9 downto 0)          -- 10-bit decryption key
    );
end component;

-- Test signals
signal input_text: std_logic_vector(7 downto 0);    -- Original plaintext
signal key: std_logic_vector(9 downto 0);           -- Encryption/decryption key
signal cypher_text: std_logic_vector(7 downto 0);   -- Encrypted output
signal decypher_text: std_logic_vector(7 downto 0); -- Decrypted output

begin
    -- Instantiate the encryption module
    -- Maps testbench signals to encryption module ports
    tb: encryption_sdes port map(
        text_input => input_text,    -- Connect plaintext input
        cypher_text => cypher_text,  -- Connect ciphertext output
        key => key                   -- Connect encryption key
    );
    
    -- Instantiate the decryption module
    -- Maps ciphertext output from encryption to decryption input
    tb1: decrypter_sdes port map(
        text_input => cypher_text,    -- Feed ciphertext to decryptor
        decypher_text => decypher_text, -- Get decrypted plaintext
        key => key                    -- Use same key for decryption
    );

    -- Test process
    process
    begin
        -- Set test case values:
        key <= "0010010111";      -- 10-bit test key
        input_text <= "10100101"; -- 8-bit test plaintext
        
        -- Note: In a more complete testbench, we would:
        -- 1. Add multiple test cases
        -- 2. Include wait statements to observe timing
        -- 3. Add assertions to verify decrypted text matches original
        -- 4. Potentially add clock for more realistic simulation
        
        wait; -- Infinite wait (testbench runs once)
    end process;

end Behavioral;