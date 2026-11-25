library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity datapath is
    generic (BL_TEST_MODE : boolean := false);
    Port (
        CLK          : in  STD_LOGIC;
        Instr        : in  STD_LOGIC_VECTOR(31 downto 0);
        MemtoReg     : in  STD_LOGIC;
        MemWrite     : in  STD_LOGIC;
        ALUControl   : in  STD_LOGIC_VECTOR(1 downto 0);
        ALUSrc       : in  STD_LOGIC;
        ImmSrc       : in  STD_LOGIC_VECTOR(1 downto 0);
        RegWrite     : in  STD_LOGIC;
        RegSrc       : in  STD_LOGIC_VECTOR(1 downto 0);
        Link         : in  STD_LOGIC;
        PCPlus4      : in  STD_LOGIC_VECTOR(31 downto 0);
        PCPlus8      : in  STD_LOGIC_VECTOR(31 downto 0);
        Flags        : out STD_LOGIC_VECTOR(3 downto 0);
        SrcA         : out STD_LOGIC_VECTOR(31 downto 0);
        SrcB         : out STD_LOGIC_VECTOR(31 downto 0);
        ALUResult    : out STD_LOGIC_VECTOR(31 downto 0);
        Output       : out STD_LOGIC_VECTOR(31 downto 0);
        WriteData    : out STD_LOGIC_VECTOR(31 downto 0);
        Result       : out STD_LOGIC_VECTOR(31 downto 0);
        R14Value     : out STD_LOGIC_VECTOR(31 downto 0)
    );
end datapath;

architecture Behavioral of datapath is
    signal RD1_internal       : STD_LOGIC_VECTOR(31 downto 0);
    signal RD2_internal       : STD_LOGIC_VECTOR(31 downto 0);
    signal ExtImm_internal    : STD_LOGIC_VECTOR(31 downto 0);
    signal ReadData_internal  : STD_LOGIC_VECTOR(31 downto 0);
    signal SrcA_internal      : STD_LOGIC_VECTOR(31 downto 0);
    signal SrcB_internal      : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResult_internal : STD_LOGIC_VECTOR(31 downto 0);
    signal Flags_internal     : STD_LOGIC_VECTOR(3 downto 0);
    signal NormalResult      : STD_LOGIC_VECTOR(31 downto 0);
    signal WriteBack_internal: STD_LOGIC_VECTOR(31 downto 0);
    signal RA1_internal       : STD_LOGIC_VECTOR(3 downto 0);
    signal RA2_internal       : STD_LOGIC_VECTOR(3 downto 0);
    signal A3_internal        : STD_LOGIC_VECTOR(3 downto 0);
begin
    RA1_internal <= Instr(19 downto 16) when RegSrc(0) = '0' else "1111";
    RA2_internal <= Instr(3 downto 0) when RegSrc(1) = '0' else Instr(15 downto 12);
    A3_internal  <= "1110" when Link = '1' else Instr(15 downto 12);

    U_RF : entity work.register_file
        generic map (BL_TEST_MODE => BL_TEST_MODE)
        port map (
            CLK      => CLK,
            RegWrite => RegWrite,
            RA1      => RA1_internal,
            RA2      => RA2_internal,
            A3       => A3_internal,
            WD3      => WriteBack_internal,
            R15      => PCPlus8,
            RD1      => RD1_internal,
            RD2      => RD2_internal,
            R14Value => R14Value
        );

    U_EXT : entity work.extend
        port map (
            Instr  => Instr(23 downto 0),
            ImmSrc => ImmSrc,
            ExtImm => ExtImm_internal
        );

    SrcA_internal <= RD1_internal;
    SrcB_internal <= RD2_internal when ALUSrc = '0' else ExtImm_internal;
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
    Flags <= Flags_internal;

    U_DM : entity work.data_memory
        port map (
            CLK      => CLK,
            MemWrite => MemWrite,
            A        => ALUResult_internal,
            WD       => RD2_internal,
            RD       => ReadData_internal
        );

    NormalResult <= ALUResult_internal when MemtoReg = '0' else ReadData_internal;
    WriteBack_internal <= PCPlus4 when Link = '1' else NormalResult;
    Output <= WriteBack_internal;
    Result <= WriteBack_internal;
end Behavioral;
