----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/11/12 00:33:04
-- Design Name: 
-- Module Name: MIPS_CPU - Behavioral
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

entity MIPS_CPU is
    Port ( rst :            in STD_LOGIC;                                   -- Reset
           clk :            in STD_LOGIC;                                   -- Clock
           inst_i :         in STD_LOGIC_VECTOR(INST_LEN-1 downto 0);       -- input instruction from ROM
           rom_en_o :       out STD_LOGIC;                                  -- output enable to ROM
           rom_addr_o :     out STD_LOGIC_VECTOR(INST_LEN-1 downto 0));     -- output instruction address to ROM
end MIPS_CPU;

architecture Behavioral of MIPS_CPU is

component PC
    Port ( rst :    in STD_LOGIC;                                       -- Reset
           clk :    in STD_LOGIC;                                       -- Clock
           pc_o :   out STD_LOGIC_VECTOR(INST_ADDR_LEN-1 downto 0);     -- output program counter (instruction address) to ROM
           en_o :   out STD_LOGIC);                                     -- output enable signal to ROM
end component;

component IF_to_ID is
    Port ( rst :    in STD_LOGIC;                                       -- Reset
           clk :    in STD_LOGIC;                                       -- Clock
           pc_i :   in STD_LOGIC_VECTOR(INST_ADDR_LEN-1 downto 0);      -- input program counter (instruction address) from ROM
           inst_i : in STD_LOGIC_VECTOR(INST_LEN-1 downto 0);           -- input instruction from ROM
           pc_o :   out STD_LOGIC_VECTOR(INST_ADDR_LEN-1 downto 0);     -- output program counter (instruction address) to ID
           inst_o : out STD_LOGIC_VECTOR(INST_LEN-1 downto 0));         -- output instruction to ID
end component;

component ID is
    Port ( rst :                in STD_LOGIC;                                       -- Reset
           pc_i :               in STD_LOGIC_VECTOR(INST_ADDR_LEN-1 downto 0);      -- input program counter (instruction address) from IF_to_ID
           inst_i :             in STD_LOGIC_VECTOR(INST_LEN-1 downto 0);           -- input instruction from IF_to_ID
           reg_rd_data_1_i :    in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input register 1 read data from REGISTERS
           reg_rd_data_2_i :    in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input register 2 read data from REGISTERS
           ex_reg_wt_en_i :     in STD_LOGIC;                                       -- input EX register write enable from EX (push forward data to solve data conflict)
           ex_reg_wt_addr_i :   in STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);       -- input EX register write address from EX (push forward data to solve data conflict)
           ex_reg_wt_data_i :   in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input EX register write data from EX (push forward data to solve data conflict)
           mem_reg_wt_en_i :    in STD_LOGIC;                                       -- input MEM register write enable from MEM (push forward data to solve data conflict)
           mem_reg_wt_addr_i :  in STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);       -- input MEM register write address from MEM (push forward data to solve data conflict)
           mem_reg_wt_data_i :  in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input MEM register write data from MEM (push forward data to solve data conflict)
           op_o :               out STD_LOGIC_VECTOR(OP_LEN-1 downto 0);            -- output custom op type to ID_to_EX
           funct_o :            out STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0);         -- output custom funct type to ID_to_EX
           reg_rd_en_1_o :      out STD_LOGIC;                                      -- output register 1 read enable to REGISTERS
           reg_rd_en_2_o :      out STD_LOGIC;                                      -- output register 2 read enable to REGISTERS
           reg_rd_addr_1_o :    out STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);      -- output register 1 read address to REGISTERS
           reg_rd_addr_2_o :    out STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);      -- output register 2 read address to REGISTERS
           operand_1_o :        out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output operand 1 to ID_to_EX
           operand_2_o :        out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output operand 2 to ID_to_EX
           reg_wt_en_o :        out STD_LOGIC;                                      -- output register write enable to ID_to_EX
           reg_wt_addr_o :      out STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0));     -- output register write address to ID_to_EX
end component;

component ID_to_EX is
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
end component;

component EX is
    Port ( rst :            in STD_LOGIC;                                       -- Reset
           op_i :           in STD_LOGIC_VECTOR(OP_LEN-1 downto 0);             -- input custom op type from ID/EX
           funct_i :        in STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0);          -- input custom op type from ID/EX
           operand_1_i :    in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input operand 1 from ID/EX
           operand_2_i :    in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input operand 2 from ID/EX
           reg_wt_en_i :    in STD_LOGIC;                                       -- input register write enable from ID/EX
           reg_wt_addr_i :  in STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);       -- input register write address from ID/EX
           hi_i :           in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input LO data from HI_LO
           lo_i :           in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input HI data from HI_LO
           mem_hilo_en_i :  in STD_LOGIC;                                       -- input HI_LO write enable from MEM
           mem_hi_i :       in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input LO data from MEM
           mem_lo_i :       in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input HI data from MEM
           wb_hilo_en_i:    in STD_LOGIC;                                       -- input HI_LO write enable from MEM/WB
           wb_hi_i :        in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input LO data from MEM/WB
           wb_lo_i :        in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input HI data from MEM/WB
           reg_wt_en_o :    out STD_LOGIC;                                      -- output register write enable to EX/MEM
           reg_wt_addr_o :  out STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);      -- output register write address to EX/MEM
           reg_wt_data_o :  out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output register write data to EX/MEM
           hilo_en_o :      out STD_LOGIC;                                      -- output HI_LO write enable to EX/MEM
           hi_o :           out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output HI data to EX/MEM
           lo_o :           out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0));     -- output LO data to EX/MEM
end component;

component EX_to_MEM is
    Port ( rst :                in STD_LOGIC;                                       -- Reset
           clk :                in STD_LOGIC;                                       -- Clock
           reg_wt_en_i :        in STD_LOGIC;                                       -- input register write enable from EX
           reg_wt_addr_i :      in STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);       -- input register write address from EX
           reg_wt_data_i :      in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input register write data from EX
           hilo_en_i :          in STD_LOGIC;                                       -- input HILO write enable from EX
           hi_i :               in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input HI data from EX
           lo_i :               in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input LO data from EX
           reg_wt_en_o :        out STD_LOGIC;                                      -- output register write enable to MEM
           reg_wt_addr_o :      out STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);      -- output register write address to MEM
           reg_wt_data_o :      out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output register write data to MEM
           hilo_en_o :          out STD_LOGIC;                                      -- output HILO write enable to MEM
           hi_o :               out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output HI data to MEM
           lo_o :               out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0));     -- output LO data to MEM
end component;

component MEM is
    Port ( rst :                in STD_LOGIC;                                       -- Reset
           reg_wt_en_i :        in STD_LOGIC;                                       -- input register write enable from EX/MEM
           reg_wt_addr_i :      in STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);       -- input register write address from EX/MEM
           reg_wt_data_i :      in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input register write data from EX/MEM
           hilo_en_i :          in STD_LOGIC;                                       -- input HILO enable from EX/MEM
           hi_i :               in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input HI data from EX/MEM
           lo_i :               in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input LO data from EX/MEM
           reg_wt_en_o :        out STD_LOGIC;                                      -- output register write enable to MEM/WB
           reg_wt_addr_o :      out STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);      -- output register write address to MEM/WB
           reg_wt_data_o :      out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output register write data to MEM/WB
           hilo_en_o :          out STD_LOGIC;                                      -- output HILO write enable to MEM/WB
           hi_o :               out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output HI data to MEM/WB
           lo_o :               out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0));     -- output lo data to MEM/WB
end component;

component MEM_to_WB is
    Port ( rst :                in STD_LOGIC;                                       -- Reset
           clk :                in STD_LOGIC;                                       -- Clock
           reg_wt_en_i :        in STD_LOGIC;                                       -- input register write enable from MEM
           reg_wt_addr_i :      in STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);       -- input register write address from MEM
           reg_wt_data_i :      in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input register write data from MEM
           hilo_en_i :          in STD_LOGIC;                                       -- input HILO enable from MEM
           hi_i :               in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input HI data from MEM
           lo_i :               in STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);       -- input LO data from MEM
           reg_wt_en_o :        out STD_LOGIC;                                      -- output register write enable to REGISTERS
           reg_wt_addr_o :      out STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);      -- output register write address to REGISTERS
           reg_wt_data_o :      out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output register write data to REGISTERS
           hilo_en_o :          out STD_LOGIC;                                      -- output HILO write enable to HILO and EX
           hi_o :               out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);      -- output HI data to HILO and EX
           lo_o :               out STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0));     -- output lo data to HILO and EX
end component;

component REGISTERS is
    Port ( rst :                in STD_LOGIC;                                          -- Reset
           clk :                in STD_LOGIC;                                          -- Clock
           reg_rd_en_1_i :      in STD_LOGIC;                                          -- input register 1 read enable from ID
           reg_rd_en_2_i :      in STD_LOGIC;                                          -- input register 2 read enable from ID
           reg_rd_addr_1_i :    in STD_LOGIC_VECTOR (REG_ADDR_LEN-1 downto 0);         -- input register 1 read address from ID
           reg_rd_addr_2_i :    in STD_LOGIC_VECTOR (REG_ADDR_LEN-1 downto 0);         -- input register 2 read address from ID
           reg_wt_en_i :        in STD_LOGIC;                                          -- input register write enable from MEM_to_WEB
           reg_wt_addr_i :      in STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);          -- input register write address from MEM_to_WEB
           reg_wt_data_i :      in STD_LOGIC_VECTOR (REG_DATA_LEN-1 downto 0);         -- input register write address from MEM_to_WEB
           reg_rd_data_1_o :    out STD_LOGIC_VECTOR (REG_DATA_LEN-1 downto 0);        -- output register 1 read data to ID
           reg_rd_data_2_o :    out STD_LOGIC_VECTOR (REG_DATA_LEN-1 downto 0));       -- output register 2 read data to ID
end component;

component HI_LO is
    Port ( clk :        in STD_LOGIC;                                               -- Clock
           rst :        in STD_LOGIC;                                               -- Reset
           en :         in STD_LOGIC;                                               -- input enable from MEM/WB
           hi_i :       in STD_LOGIC_VECTOR (REG_DATA_LEN-1 downto 0);              -- input HI data from MEM/WB
           lo_i :       in STD_LOGIC_VECTOR (REG_DATA_LEN-1 downto 0);              -- input LO data from MEM/WB
           hi_o :       out STD_LOGIC_VECTOR (REG_DATA_LEN-1 downto 0);             -- output HI data to EX
           lo_o :       out STD_LOGIC_VECTOR (REG_DATA_LEN-1 downto 0));            -- output LO data to EX
end component;

-- PC to IF/ID signals
signal pc_from_pc : STD_LOGIC_VECTOR(INST_ADDR_LEN-1 downto 0);  -- Need to be mapped to two ports

-- IF/ID to ID signals
signal pc_to_id : STD_LOGIC_VECTOR(INST_ADDR_LEN-1 downto 0);
signal inst_to_id : STD_LOGIC_VECTOR(INST_LEN-1 downto 0);

-- ID to REGISTER and ID/EX signals
signal reg_rd_data_1_from_register: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal reg_rd_data_2_from_register: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal op_from_id: STD_LOGIC_VECTOR(OP_LEN-1 downto 0);
signal funct_from_id: STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0);
signal reg_rd_en_1_to_register: STD_LOGIC;
signal reg_rd_en_2_to_register: STD_LOGIC;
signal reg_rd_addr_1_to_register: STD_LOGIC_VECTOR (REG_ADDR_LEN-1 downto 0);
signal reg_rd_addr_2_to_register: STD_LOGIC_VECTOR (REG_ADDR_LEN-1 downto 0);
signal oprand_1_from_id: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal oprand_2_from_id: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal reg_wt_en_from_id: STD_LOGIC;
signal reg_wt_addr_from_id: STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);

-- ID/EX to EX signals
signal op_to_ex: STD_LOGIC_VECTOR(OP_LEN-1 downto 0);
signal funct_to_ex: STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0);
signal oprand_1_to_ex: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal oprand_2_to_ex: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal reg_wt_en_to_ex: STD_LOGIC;
signal reg_wt_addr_to_ex: STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);

-- EX to EX/MEM signals
signal reg_wt_en_from_ex: STD_LOGIC;
signal reg_wt_addr_from_ex: STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);
signal reg_wt_data_from_ex: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal hilo_en_from_ex: STD_LOGIC;
signal hi_from_ex: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal lo_from_ex: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);

-- EX/MEM to MEM signals
signal reg_wt_en_to_mem: STD_LOGIC;
signal reg_wt_addr_to_mem: STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);
signal reg_wt_data_to_mem: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal hilo_en_to_mem: STD_LOGIC;
signal hi_to_mem: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal lo_to_mem: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);

-- MEM to MEM/WB signals
signal reg_wt_en_from_mem: STD_LOGIC;
signal reg_wt_addr_from_mem: STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);
signal reg_wt_data_from_mem: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);

-- MEM to MEM/WB and EX signals
signal hilo_en_from_mem: STD_LOGIC; 
signal hi_from_mem: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal lo_from_mem: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);

-- MEM/WB to REGISTER signals
signal reg_wt_en_to_register: STD_LOGIC;
signal reg_wt_addr_to_register: STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0);
signal reg_wt_data_to_register: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0); 

-- MEM/WB to HILO and EX signals
signal hilo_en_to_hilo: STD_LOGIC; 
signal hi_to_hilo: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal lo_to_hilo: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);

-- HILO to EX signals
signal hi_from_hilo: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);
signal lo_from_hilo: STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0);

begin

    rom_addr_o <= pc_from_pc;  -- Output 

    PC_0 : PC port map(
        rst => rst, clk => clk, 
        pc_o => pc_from_pc, en_o => rom_en_o);
    
    IF_to_ID_0 : IF_to_ID port map(
        rst => rst, clk => clk, 
        pc_i => pc_from_pc, inst_i => inst_i, 
        pc_o => pc_to_id, inst_o => inst_to_id);
    
    ID_0 : ID port map(
        rst => rst, 
        pc_i => pc_to_id, inst_i => inst_to_id, 
        reg_rd_data_1_i => reg_rd_data_1_from_register, reg_rd_data_2_i => reg_rd_data_2_from_register, 
        ex_reg_wt_en_i => reg_wt_en_from_ex, ex_reg_wt_addr_i => reg_wt_addr_from_ex, ex_reg_wt_data_i => reg_wt_data_from_ex,
        mem_reg_wt_en_i => reg_wt_en_from_mem, mem_reg_wt_addr_i => reg_wt_addr_from_mem, mem_reg_wt_data_i => reg_wt_data_from_mem,
        op_o => op_from_id, funct_o => funct_from_id, 
        reg_rd_en_1_o => reg_rd_en_1_to_register, reg_rd_en_2_o => reg_rd_en_2_to_register, 
        reg_rd_addr_1_o => reg_rd_addr_1_to_register, reg_rd_addr_2_o => reg_rd_addr_2_to_register, 
        operand_1_o => oprand_1_from_id, operand_2_o => oprand_2_from_id, 
        reg_wt_en_o => reg_wt_en_from_id, reg_wt_addr_o => reg_wt_addr_from_id);

    ID_to_EX_0 : ID_to_EX port map(
        rst => rst, clk => clk,
        op_i => op_from_id, funct_i => funct_from_id,
        operand_1_i => oprand_1_from_id, operand_2_i => oprand_2_from_id,
        reg_wt_en_i => reg_wt_en_from_id, reg_wt_addr_i => reg_wt_addr_from_id,
        op_o => op_to_ex, funct_o => funct_to_ex,
        operand_1_o => oprand_1_to_ex, operand_2_o => oprand_2_to_ex,
        reg_wt_en_o => reg_wt_en_to_ex, reg_wt_addr_o => reg_wt_addr_to_ex);
    
    EX_0 : EX port map(
        rst => rst,
        op_i => op_to_ex, funct_i => funct_to_ex,
        operand_1_i => oprand_1_to_ex, operand_2_i => oprand_2_to_ex,
        reg_wt_en_i => reg_wt_en_to_ex, reg_wt_addr_i => reg_wt_addr_to_ex,
        hi_i => hi_from_hilo, lo_i => lo_from_hilo,
        mem_hilo_en_i => hilo_en_from_mem, mem_hi_i => hi_from_mem, mem_lo_i => lo_from_mem,
        wb_hilo_en_i => hilo_en_to_hilo, wb_hi_i => hi_to_hilo, wb_lo_i => lo_to_hilo,
        reg_wt_en_o => reg_wt_en_from_ex, reg_wt_addr_o => reg_wt_addr_from_ex, reg_wt_data_o => reg_wt_data_from_ex,
        hilo_en_o => hilo_en_from_ex, hi_o => hi_from_ex, lo_o => lo_from_ex);
    
    EX_to_MEM_0 : EX_to_MEM port map(
        rst => rst, clk => clk,
        reg_wt_en_i => reg_wt_en_from_ex, reg_wt_addr_i => reg_wt_addr_from_ex, reg_wt_data_i => reg_wt_data_from_ex,
        hilo_en_i => hilo_en_from_ex, hi_i => hi_from_ex, lo_i => lo_from_ex,
        reg_wt_en_o => reg_wt_en_to_mem, reg_wt_addr_o => reg_wt_addr_to_mem, reg_wt_data_o => reg_wt_data_to_mem,
        hilo_en_o => hilo_en_to_mem, hi_o => hi_to_mem, lo_o => lo_to_mem);
    
    MEM_0 : MEM port map(
        rst => rst, 
        reg_wt_en_i => reg_wt_en_to_mem, reg_wt_addr_i => reg_wt_addr_to_mem, reg_wt_data_i => reg_wt_data_to_mem,
        hilo_en_i => hilo_en_to_mem, hi_i => hi_to_mem, lo_i => lo_to_mem,
        reg_wt_en_o => reg_wt_en_from_mem, reg_wt_addr_o => reg_wt_addr_from_mem, reg_wt_data_o => reg_wt_data_from_mem,
        hilo_en_o => hilo_en_from_mem, hi_o => hi_from_mem, lo_o => lo_from_mem);
    
    MEM_to_WB_0 : MEM_to_WB port map(
        rst => rst, clk => clk,
        reg_wt_en_i => reg_wt_en_from_mem, reg_wt_addr_i => reg_wt_addr_from_mem, reg_wt_data_i => reg_wt_data_from_mem,
        hilo_en_i => hilo_en_from_mem, hi_i => hi_from_mem, lo_i => lo_from_mem,
        reg_wt_en_o => reg_wt_en_to_register, reg_wt_addr_o => reg_wt_addr_to_register, reg_wt_data_o => reg_wt_data_to_register,
        hilo_en_o => hilo_en_to_hilo, hi_o => hi_to_hilo, lo_o => lo_to_hilo);
    
    REGISTERS_0 : REGISTERS port map(
        rst => rst, clk => clk,
        reg_rd_en_1_i => reg_rd_en_1_to_register, reg_rd_en_2_i => reg_rd_en_2_to_register,
        reg_rd_addr_1_i => reg_rd_addr_1_to_register, reg_rd_addr_2_i => reg_rd_addr_2_to_register,
        reg_wt_en_i => reg_wt_en_to_register, reg_wt_addr_i => reg_wt_addr_to_register, reg_wt_data_i => reg_wt_data_to_register,
        reg_rd_data_1_o => reg_rd_data_1_from_register, reg_rd_data_2_o => reg_rd_data_2_from_register);
        
    HI_LO_0 : HI_LO port map (
        rst => rst, clk => clk,
        en => hilo_en_to_hilo, hi_i => hi_to_hilo, lo_i => lo_to_hilo,
        hi_o => hi_from_hilo, lo_o => lo_from_hilo);
        
end Behavioral;
