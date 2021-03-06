----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2017/11/12 01:20:17
-- Design Name: 
-- Module Name: include - Behavioral
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

-- Constants Declaration Package
-- Usage: use WORK.INCLUDE.ALL;
-- WORK is the current working directory
package INCLUDE is
    constant INST_ADDR_LEN : integer := 32;
    constant INST_LEN : integer := 32;
    constant REG_ADDR_LEN : integer := 5;
    constant REG_DATA_LEN : integer := 32;
    constant OP_LEN : integer := 6;
    constant FUNCT_LEN : integer := 6;
    constant IMM_LEN : integer := 16;
    constant SHAMT_LEN : integer := 5;
    constant JUMP_ADDR_LEN : integer := 26;
    constant REG_NUM : integer := 32;
    constant ROM_SIZE : integer := 131072;
    constant ROM_SIZE_LOG2 : integer := 17;
    constant RST_ENABLE : STD_LOGIC := '1';
    constant RST_DISABLE : STD_LOGIC := '0';
    constant CHIP_ENABLE : STD_LOGIC := '1';
    constant CHIP_DISABLE : STD_LOGIC := '0';
    constant REG_RD_ENABLE : STD_LOGIC := '1';
    constant REG_RD_DISABLE : STD_LOGIC := '0';
    constant REG_WT_ENABLE : STD_LOGIC := '1';
    constant REG_WT_DISABLE : STD_LOGIC := '0';
    
    constant REG_ZERO_ADDR : STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"00000";
    constant REG_ZERO_DATA : STD_LOGIC_VECTOR(REG_DATA_LEN-1 downto 0) := x"00000000";
    
    -- Instruction type for EX Module
    constant OP_TYPE_NOP :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000000";
    constant OP_TYPE_ARITH :         STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000001";
    constant OP_TYPE_LOGIC :         STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000010";
    constant OP_TYPE_SHIFT :         STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000011";
    constant OP_TYPE_MOVE :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000100";
    constant OP_TYPE_BRANCH :        STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000101";
    
    -- Instruction subtype for EX 
    -- No Operation
    constant FUNCT_TYPE_NOP :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000000";
    -- Arithmetic
    -- Logic
    constant FUNCT_TYPE_AND :         STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000010";
    constant FUNCT_TYPE_OR :         STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000011";
    constant FUNCT_TYPE_XOR :         STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000100";
    constant FUNCT_TYPE_NOR :         STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000101";
    -- Shift
    constant FUNCT_TYPE_SHIFT_LEFT_LOGIC :         STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000001";
    constant FUNCT_TYPE_SHIFT_RIGHT_LOGIC :         STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000010";
    constant FUNCT_TYPE_SHIFT_RIGHT_ARITH :         STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000011";
    -- Move
    constant FUNCT_TYPE_MOVE_ZERO :             STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000001";
    constant FUNCT_TYPE_MOVE_NOT_ZERO :         STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000010";
    constant FUNCT_TYPE_MOVE_FROM_HI :          STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000011";
    constant FUNCT_TYPE_MOVE_TO_HI :            STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000100";
    constant FUNCT_TYPE_MOVE_FROM_LO :          STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000101";
    constant FUNCT_TYPE_MOVE_TO_LO :            STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000110";
    
    -- Introduction to the MIPS32 Architecture
    -- Table A-2 MIPS32 Encoding of the Opcode Field (bits 31..26)
    constant OP_SPECIAL :       STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000000";
    constant OP_REGIMM :        STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000001";
    constant OP_J :             STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000010";           -- J target                             To branch within the current 256 MB-aligned region
    constant OP_JAL :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000011";           -- JAL target                           To execute a procedure call within the current 256 MB-aligned region
    constant OP_BEQ :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000100";           -- BEQ rs, rt, offset                   if rs = rt then branch
    constant OP_BNE :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000101";           -- BNE rs, rt, offset                   if rs ≠ rt then branch
    constant OP_BLEZ :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000110";           -- BLEZ rs, offset                      if rs ≤ 0 then branch
    constant OP_BGTZ :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"000111";           -- BGTZ rs, offset                      if rs > 0 then branch
    constant OP_ADDI :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"001000";           -- ADDI rt, rs, immediate               rt ← rs + immediate
    constant OP_ADDIU :         STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"001001";           -- ADDIU rt, rs, immediate              rt ← rs + immediate
    constant OP_SLTI :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"001010";           -- SLTI rt, rs, immediate               rt ← (rs < immediate)
    constant OP_SLTIU :         STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"001011";           -- SLTIU rt, rs, immediate              rt ← (rs < immediate)
    constant OP_ANDI :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"001100";           -- ANDI rt, rs, immediate               rt ← rs AND immediate
    constant OP_ORI :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"001101";           -- ORI rt, rs, immediate                rt ← rs or immediate
    constant OP_XORI :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"001110";           -- XORI rt, rs, immediate               rt ← rs XOR immediate
    constant OP_LUI :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"001111";           -- LUI rt, immediate                    rt ← immediate || 0^16
    constant OP_COP0 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"010000";
    constant OP_COP1 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"010001";
    constant OP_COP2 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"010010";
    constant OP_COP3 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"010011";
    constant OP_BEQL :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"010100";           -- BEQL rs, rt, offset                  if rs = rt then branch_likely
    constant OP_BNEL :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"010101";           -- BNEL rs, rt, offset                  if rs ≠ rt then branch_likely
    constant OP_BLEZL :         STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"010110";           -- BLEZL rs, rt, offset                 if rs ≤ 0 then branch_likely
    constant OP_BGTZL :         STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"010111";           -- BGTZL rs, rt, offset                 if rs > 0 then branch_likely
    constant OP_SPECIAL2 :      STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"011100";
    constant OP_JALX :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"011101";
    constant OP_LB :            STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"100000";           -- LB rt, offset(base)                  rt ← memory[base+offset]
    constant OP_LH :            STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"100001";           -- LH rt, offset(base)                  rt ← memory[base+offset]
    constant OP_LWL :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"100010";           -- LWL rt, offset(base)                 rt ← rt MERGE memory[base+offset]
    constant OP_LW :            STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"100011";           -- LW rt, offset(base)                  rt ← memory[base+offset]
    constant OP_LBU :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"100100";           -- LBU rt, offset(base)                 rt ← memory[base+offset]
    constant OP_LHU :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"100101";           -- LHU rt, offset(base)                 rt ← memory[base+offset]
    constant OP_LWR :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"100110";           -- LWR rt, offset(base)                 rt ← rt MERGE memory[base+offset]
    constant OP_SB :            STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"101000";           -- SB rt, offset(base)                  memory[base+offset] ← rt
    constant OP_SH :            STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"101001";           -- SH rt, offset(base)                  memory[base+offset] ← rt
    constant OP_SWL :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"101010";           -- SWL rt, offset(base)                 memory[base+offset] ← rt
    constant OP_SW :            STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"101011";           -- SW rt, offset(base)                  memory[base+offset] ← rt
    constant OP_SWR :           STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"101110";           -- SWR rt, offset(base)                 memory[base+offset] ← rt
    constant OP_CACHE :         STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"101111";
    constant OP_LL :            STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"110000";
    constant OP_LWC1 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"110001";
    constant OP_LWC2 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"110010";
    constant OP_PREF :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"110011";
    constant OP_LDC1 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"110101";
    constant OP_LDC2 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"110110";
    constant OP_SC :            STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"111000";
    constant OP_SWC1 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"111001";
    constant OP_SWC2 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"111010";
    constant OP_SDC1 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"111101";
    constant OP_SDC2 :          STD_LOGIC_VECTOR(OP_LEN-1 downto 0) := b"111110";
    
    -- Introduction to the MIPS32 Architecture
    -- Table A-3 MIPS32 SPECIAL Opcode Encoding of Function Field (bits 5..0)
    constant FUNCT_SLL :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000000";            -- SLL $rd, $rt, imm        rd ← rt << sa
    constant FUNCT_MOVCI :      STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000001";            
    constant FUNCT_SRL :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000010";            -- SRL rd, rt, sa           rd ← rt >> sa (logical)
    constant FUNCT_SRA :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000011";            -- SRA rd, rt, sa           rd ← rt >> sa (arithmatic)
    constant FUNCT_SLLV :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000100";            -- SLLV rd, rt, rs          rd ← rt << rs
    constant FUNCT_SRLV :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000110";            -- SRLV rd, rt, rs          rd ← rt >> rs (logical)
    constant FUNCT_SRAV :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000111";            -- SRAV rd, rt, rs          rd ← rt >> rs (arithmetic)
    constant FUNCT_JR :         STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"001000";            -- JR rs                    PC ← rs
    constant FUNCT_JALR :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"001001";            -- JALR (rd, = 31) rs       rd ← return_addr, PC ← rs
    constant FUNCT_MOVZ :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"001010";            -- MOVZ rd, rs, rt          if rt = 0 then rd ← rs
    constant FUNCT_MOVN :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"001011";            -- MOVN rd, rs, rt          if rt ≠ 0 then rd ← rs
    constant FUNCT_SYSCALL :    STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"001100";            -- SYSCALL                  A system call exception occurs
    constant FUNCT_BREAK :      STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"001101";            -- BREAK                    A breakpoint exception occurs
    constant FUNCT_SYNC :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"001111";            -- SYNC (stype = 0 implied) To order loads and stores.
    constant FUNCT_MFHI :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"010000";            -- MFHI rd                  rd ← HI
    constant FUNCT_MTHI :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"010001";            -- MTHI rs                  HI ← rs
    constant FUNCT_MFLO :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"010010";            -- MFLO rd                  rd ← LO
    constant FUNCT_MTLO :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"010011";            -- MTLO rs                  LO ← rs
    constant FUNCT_MULT :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"011000";            -- MULT rs, rt              (LO, HI) ← rs × rt
    constant FUNCT_MULTU :      STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"011001";            -- MULTU rs, rt             (LO, HI) ← rs × rt
    constant FUNCT_DIV :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"011010";            -- DIV rs, rt               (LO, HI) ← rs / rt
    constant FUNCT_DIVU :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"011011";            -- DIVU rs, rt              (LO, HI) ← rs / rt
    constant FUNCT_ADD :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"100000";            -- ADD rd, rs, rt           rd ← rs + rt
    constant FUNCT_ADDU :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"100001";            -- ADDU rd, rs, rt          rd ← rs + rt
    constant FUNCT_SUB :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"100010";            -- SUB rd, rs, rt           rd ← rs - rt
    constant FUNCT_SUBU :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"100011";            -- SUBU rd, rs, rt          rd ← rs - rt
    constant FUNCT_AND :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"100100";            -- AND rd, rs, rt           rd ← rs AND rt
    constant FUNCT_OR :         STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"100101";            -- OR rd, rs, rt            rd ← rs or rt
    constant FUNCT_XOR :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"100110";            -- XOR rd, rs, rt           rd ← rs XOR rt
    constant FUNCT_NOR :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"100111";            -- NOR rd, rs, rt           rd ← rs NOR rt
    constant FUNCT_SLT :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"101010";            -- SLT rd, rs, rt           rd ← (rs < rt)
    constant FUNCT_SLTU :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"101011";            -- SLTU rd, rs, rt          rd ← (rs < rt)
    constant FUNCT_TGE :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"110000";            -- TGE rs, rt               if rs ≥ rt then Trap
    constant FUNCT_TGEU :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"110001";            -- TGEU rs, rt              if rs ≥ rt then Trap
    constant FUNCT_TLT :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"110010";            -- TLT rs, rt               if rs < rt then Trap
    constant FUNCT_TLTU :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"110011";            -- TLTU rs, rt              if rs < rt then Trap
    constant FUNCT_TEQ :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"110100";            -- TEQ rs, rt               if rs = rt then Trap
    constant FUNCT_TNE :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"110110";            -- TNE rs, rt               if rs ≠ rt then Trap
    
    -- Introduction to the MIPS32 Architecture
    -- Table A-4 MIPS32 REGIMM Encoding of rt Field (bits 20..16)
    constant RT_BLTZ :          STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"00000";
    constant RT_BGEZ :          STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"00001";
    constant RT_BLTZL :         STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"00010";
    constant RT_BGEZL :         STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"00011";
    constant RT_TGEI :          STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"01000";
    constant RT_TGEIU :         STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"01001";
    constant RT_TLTI :          STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"01010";
    constant RT_TLTIU :         STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"01011";
    constant RT_TEQI :          STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"01100";
    constant RT_TNEI :          STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"01110";
    constant RT_BLTZAL :        STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"10000";
    constant RT_BGEZAL :        STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"10001";
    constant RT_BLTZALL :       STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"10010";
    constant RT_BGEZALL :       STD_LOGIC_VECTOR(REG_ADDR_LEN-1 downto 0) := b"10011";
    
    -- Introduction to the MIPS32 Architecture
    -- Table A-5 MIPS32 SPECIAL2 Encoding of Function Field (bits 5..0)
    constant FUNCT_MADD :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000000";
    constant FUNCT_MADDU :      STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000001";
    constant FUNCT_MUL :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000010";
    constant FUNCT_MSUB :       STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000100";
    constant FUNCT_MSUBU :      STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"000101";
    constant FUNCT_CLZ :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"100000";
    constant FUNCT_CLO :        STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"100001";
    constant FUNCT_SDBRP :      STD_LOGIC_VECTOR(FUNCT_LEN-1 downto 0) := b"111111";
    
    -- Introduction to the MIPS32 Architecture
    -- Table A-6 MIPS32 MOVCI Encoding of tf Bit (bit 16)
    constant TF_MOVF :          STD_LOGIC := '0';
    constant TF_MOVT :          STD_LOGIC := '1';
    
end INCLUDE;

