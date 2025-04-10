----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.10.2023 12:57:44
-- Design Name: 
-- Module Name: major_modules_testbench - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- Comprehensive testbench for S-DES encryption system components
-- Tests both key generation (key_sdes) and encryption (encryption_sdes) modules
-- Allows observation of intermediate values (P10 permutation, subkeys, FK outputs)
-- 
-- Dependencies: 
-- Requires encryption_sdes and key_sdes components
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- Provides visibility into internal operations of the S-DES algorithm
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Note: NUMERIC_STD not currently used but available if needed
-- use IEEE.NUMERIC_STD.ALL;

entity major_modules_testbench is
-- Testbench entity has no ports
end major_modules_testbench;

architecture Behavioral of major_modules_testbench is

-- Component declaration for S-DES encryption module
component encryption_sdes is
    Port (
        text_input: in std_logic_vector(7 downto 0);   -- 8-bit plaintext input
        cypher_text: out std_logic_vector(7 downto 0); -- 8-bit ciphertext output
        fk1_value: out std_logic_vector(3 downto 0);   -- First Fk function output (debug)
        fk2_value: out std_logic_vector(3 downto 0);   -- Second Fk function output (debug)
        key: in std_logic_vector(9 downto 0)          -- 10-bit encryption key
    );
end component;

-- Component declaration for S-DES key generation module
component key_sdes is
    Port ( 
        key : in STD_LOGIC_vector(9 downto 0);     -- 10-bit input key
        key1: out std_logic_vector(7 downto 0);    -- First round subkey
        key2: out std_logic_vector(7 downto 0);    -- Second round subkey
        p10_value: out std_logic_vector(9 downto 0) -- P10 permutation output (debug)
    );
end component;

-- Test signals
signal input_text: std_logic_vector(7 downto 0) := (others => '0');  -- Plaintext input
signal Key: std_logic_vector(9 downto 0) := (others => '0');         -- Encryption key
signal p10_value: std_logic_vector(9 downto 0);                      -- P10 permutation output
signal key1, key2: std_logic_vector(7 downto 0);                     -- Generated subkeys
signal fk1, fk2: std_logic_vector(3 downto 0);                       -- Fk function outputs
signal output_text: std_logic_vector(7 downto 0);                     -- Final ciphertext

begin
    -- Instantiate key generation module
    -- Maps testbench signals to key_sdes ports
    tb: key_sdes port map(
        key => key,           -- Connect test key
        key1 => key1,         -- Receive first subkey
        key2 => key2,         -- Receive second subkey
        p10_value => p10_value -- Get P10 permutation output
    );
    
    -- Instantiate encryption module
    -- Maps testbench signals to encryption_sdes ports
    tb1: encryption_sdes port map(
        text_input => input_text,  -- Connect plaintext input
        cypher_text => output_text, -- Get ciphertext output
        fk1_value => fk1,         -- Monitor first Fk output
        fk2_value => fk2,         -- Monitor second Fk output
        key => key                -- Connect encryption key
    );
                             
    -- Test stimulus process
    process
    begin
        -- Set test values (could be extended with multiple test cases)
        key <= "0010010111";      -- 10-bit test key
        input_text <= "10100101"; -- 8-bit test plaintext
        
        -- Note: In a more complete testbench, you might:
        -- 1. Add multiple test cases with different keys/plaintexts
        -- 2. Include timing delays between test cases
        -- 3. Add assertions to verify expected outputs
        -- 4. Include reporting of test results
        
        wait; -- Infinite wait (testbench runs once with these values)
    end process;

end Behavioral;