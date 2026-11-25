----------------------------------------------------------------------------------

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
    Port (
        CLK        : in  STD_LOGIC;
        Instr      : in  STD_LOGIC_VECTOR(31 downto 0);

        MemtoReg   : in  STD_LOGIC;
        MemWrite   : in  STD_LOGIC;
        ALUControl : in  STD_LOGIC_VECTOR(1 downto 0);
        ALUSrc     : in  STD_LOGIC;
        ImmSrc     : in  STD_LOGIC_VECTOR(1 downto 0);
        RegWrite   : in  STD_LOGIC;
        RegSrc     : in  STD_LOGIC_VECTOR(1 downto 0);
        PCPlus8    : in  STD_LOGIC_VECTOR(31 downto 0);
        PCPlus4    : in  STD_LOGIC_VECTOR(31 downto 0);
        BL         : in  STD_LOGIC;

        Flags      : out STD_LOGIC_VECTOR(3 downto 0);
        SrcA       : out STD_LOGIC_VECTOR(31 downto 0);
        SrcB       : out STD_LOGIC_VECTOR(31 downto 0);
        ALUResult  : out STD_LOGIC_VECTOR(31 downto 0);
        Output     : out STD_LOGIC_VECTOR(31 downto 0);
        WriteData  : out STD_LOGIC_VECTOR(31 downto 0);
        Result     : out STD_LOGIC_VECTOR(31 downto 0)
        
    );
end datapath;

architecture Behavioral of datapath is

-- Signaux connectés

signal RD1_internal       : STD_LOGIC_VECTOR(31 downto 0);
signal RD2_internal       : STD_LOGIC_VECTOR(31 downto 0);

signal ExtImm_internal    : STD_LOGIC_VECTOR(31 downto 0);
signal ReadData_internal  : STD_LOGIC_VECTOR(31 downto 0);

signal SrcA_internal      : STD_LOGIC_VECTOR(31 downto 0);
signal SrcB_internal      : STD_LOGIC_VECTOR(31 downto 0);

signal ALUResult_internal : STD_LOGIC_VECTOR(31 downto 0);
signal Flags_internal     : STD_LOGIC_VECTOR(3 downto 0);

signal Result_internal    : STD_LOGIC_VECTOR(31 downto 0);

signal RA1_internal       : STD_LOGIC_VECTOR(3 downto 0);
signal RA2_internal       : STD_LOGIC_VECTOR(3 downto 0);

signal A3_internal        : STD_LOGIC_VECTOR(3 downto 0);
signal WD3_internal       : STD_LOGIC_VECTOR(31 downto 0);

begin
    
-- Selection des adresses de lecture
RA1_internal <= Instr(19 downto 16)
                when RegSrc(0) = '0'
                else "1111";

RA2_internal <= Instr(3 downto 0)
                when RegSrc(1) = '0'
                else Instr(15 downto 12);

A3_internal <= "1110" when BL = '1'
               else Instr(15 downto 12);

WD3_internal <= PCPlus4 when BL = '1'
                else Result_internal;

-- Instanciation du Register File
U_RF : entity work.register_file
    port map (
        CLK      => CLK,
        RegWrite => RegWrite,
        RA1      => RA1_internal,
        RA2      => RA2_internal,
        A3       => A3_internal,
        WD3      => WD3_internal,
        R15      => PCPlus8,
        RD1      => RD1_internal,
        RD2      => RD2_internal
    );
    
 -- Instanciation du module Extend
U_EXT : entity work.extend
    port map (
        Instr  => Instr(23 downto 0),
        ImmSrc => ImmSrc,
        ExtImm => ExtImm_internal
    );

-- Premiere entree de l'ALU
SrcA_internal <= RD1_internal;

-- Multiplexeur ALUSrc
SrcB_internal <= RD2_internal when ALUSrc = '0'
                 else ExtImm_internal;
                 
SrcA <= SrcA_internal;
SrcB <= SrcB_internal;
WriteData <= RD2_internal;
    
U_ALU : entity work.alu32
    port map (
        A          => SrcA_internal,
        B          => SrcB_internal,
        ALUControl => ALUControl,
        Result     => ALUResult_internal,
        ALUFlags   => Flags_internal
    );
    
ALUResult <= ALUResult_internal;
Flags     <= Flags_internal;

-- Instanciation de la Data Memory
U_DM : entity work.data_memory
    port map (
        CLK      => CLK,
        MemWrite => MemWrite,
        A        => ALUResult_internal,
        WD       => RD2_internal,
        RD       => ReadData_internal
    );
    
    -- Multiplexeur MemtoReg
Result_internal <= ALUResult_internal
                   when MemtoReg = '0'
                   else ReadData_internal;
                   
Output <= Result_internal;
Result <= Result_internal;

end Behavioral;
