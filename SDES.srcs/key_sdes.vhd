----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.10.2023 23:40:54
-- Design Name: 
-- Module Name: key_sdes - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity key_sdes is
    Port ( key : in STD_LOGIC_vector(9 downto 0);
           key1: out std_logic_vector(7 downto 0);
           key2: out std_logic_vector(7 downto 0);
           p10_value:out std_logic_vector(9 downto 0));
end key_sdes;

architecture Behavioral of Key_sdes is

--signal
signal ls_1_1:std_logic_vector(4 downto 0);
signal ls_1_2: std_logic_vector(4 downto 0);
signal ls_2_1:std_logic_vector(4 downto 0);
signal ls_2_2: std_logic_vector(4 downto 0);
signal p10:std_logic_vector(9 downto 0);


function left_shift_1(ls_in:std_logic_vector(4 downto 0))
return std_logic_vector is
variable ls_out:unsigned(4 downto 0);
begin
ls_out:=unsigned(ls_in) rol 1;
return std_logic_vector(ls_out);
end;

function left_shift_2(ls_in:std_logic_vector(4 downto 0))
return std_logic_vector is
variable ls_out:unsigned(4 downto 0);
begin
ls_out:=unsigned(ls_in) rol 2;
return std_logic_vector(ls_out);
end;

function p8_block(p8_in:std_logic_vector(9 downto 0))
return std_logic_vector is
variable p8_out:std_logic_vector(7 downto 0);
begin
p8_out(7):=p8_in(4);
p8_out(6):=p8_in(7);
p8_out(5):=p8_in(3);
p8_out(4):=p8_in(6);
p8_out(3):=p8_in(2);
p8_out(2):=p8_in(5);
p8_out(1):=p8_in(0);
p8_out(0):=p8_in(1);
return std_logic_vector(p8_out);
end;

--main block
begin



                       p10(9)<=key(7);
                       p10(8)<=key(5);
                       p10(7)<=key(8);
                       p10(6)<=key(3);
                       p10(5)<=key(6);
                       p10(4)<=key(0);
                       p10(3)<=key(9);
                       p10(2)<=key(1);
                       p10(1)<=key(2);
                       p10(0)<=key(4);
                       
p10_value<=p10;                       
ls_1_1<=left_shift_1(p10(9 downto 5));
ls_1_2<=left_shift_1(p10(4 downto 0));


key1<=p8_block(ls_1_1 & ls_1_2);

ls_2_1<=left_shift_2(ls_1_1);
ls_2_2<=left_shift_2(ls_1_2);

key2<=p8_block(ls_2_1 & ls_2_2);

end Behavioral;



