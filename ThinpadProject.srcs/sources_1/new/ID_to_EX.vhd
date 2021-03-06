----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/11/12 00:33:04
-- Design Name: 
-- Module Name: ID_to_EX - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use WORK.INCLUDE.ALL;

-- ID_to_EX Module in CPU

entity ID_to_EX is
    Port ( rst :            in STD_LOGIC;                                       -- Reset
           clk :            in STD_LOGIC;                                       -- Clock
           op_i :           in STD_LOGIC_VECTOR(OP_LEN-1 downto 0);             -- input custom op type from ID
           funct_i :        in STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0);          -- input custom funct type from ID
           operand_1_i :    in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input operand 1 data from ID
           operand_2_i :    in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input operand 2 read data from ID
           reg_wt_en_i :    in STD_LOGIC;                                       -- input register write enable from ID
           reg_wt_addr_i :  in STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);       -- input register write address from ID
           op_o :           out STD_LOGIC_VECTOR(OP_LEN-1 downto 0);            -- output custom op type to EX
           funct_o :        out STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0);         -- output custom funct type to EX
           operand_1_o :    out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output operand 1 read data to EX
           operand_2_o :    out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output operand 2 read data to EX
           reg_wt_en_o :    out STD_LOGIC;                                      -- output register write enable to EX
           reg_wt_addr_o :  out STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0));     -- output register write address to EX
end ID_to_EX;

architecture Behavioral of ID_to_EX is
begin

    process (clk'event)
    begin
        if rising_edge(clk) then
            if rst = RST_ENABLE then 
                op_o <= OP_TYPE_NOP;
                funct_o <= FUNCT_TYPE_NOP;
                operand_1_o <= REG_ZERO_DATA;
                operand_2_o <= REG_ZERO_DATA;
                reg_wt_en_o <= REG_WT_DISABLE;
                reg_wt_addr_o <= REG_ZERO_ADDR;
            else
                op_o <= op_i;
                funct_o <= funct_i;
                operand_1_o <= operand_1_i;
                operand_2_o <= operand_2_i;
                reg_wt_en_o <= reg_wt_en_i;
                reg_wt_addr_o <= reg_wt_addr_i;
            end if;
        end if;
    end process;

end Behavioral;
