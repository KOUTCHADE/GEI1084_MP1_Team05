library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity arm_top is
    generic (BL_TEST_MODE : boolean := false);
    Port (
        CLK           : in  STD_LOGIC;
        reset         : in  STD_LOGIC;
        PC            : out STD_LOGIC_VECTOR(31 downto 0);
        Instr         : out STD_LOGIC_VECTOR(31 downto 0);
        PCSrc         : out STD_LOGIC;
        ALUResult     : out STD_LOGIC_VECTOR(31 downto 0);
        WriteData     : out STD_LOGIC_VECTOR(31 downto 0);
        PCPlus4       : out STD_LOGIC_VECTOR(31 downto 0);
        PCPlus8       : out STD_LOGIC_VECTOR(31 downto 0);
        Link          : out STD_LOGIC;
        RegWrite      : out STD_LOGIC;
        WriteBackData : out STD_LOGIC_VECTOR(31 downto 0);
        R14Value      : out STD_LOGIC_VECTOR(31 downto 0)
    );
end arm_top;

architecture Structural of arm_top is
    signal Branch_s   : STD_LOGIC;
    signal MemtoReg_s : STD_LOGIC;
    signal MemW_s     : STD_LOGIC;
    signal ALUSrc_s   : STD_LOGIC;
    signal RegW_s     : STD_LOGIC;
    signal ALUOp_s    : STD_LOGIC;
    signal Link_s     : STD_LOGIC;
    signal ImmSrc_s   : STD_LOGIC_VECTOR(1 downto 0);
    signal RegSrc_s   : STD_LOGIC_VECTOR(1 downto 0);
    signal ALUControl_s : STD_LOGIC_VECTOR(1 downto 0);
    signal FlagW_s      : STD_LOGIC_VECTOR(1 downto 0);
    signal PCS_s        : STD_LOGIC;
    signal PCSrc_s      : STD_LOGIC;
    signal RegWrite_s   : STD_LOGIC;
    signal MemWrite_s   : STD_LOGIC;
    signal Instr_s      : STD_LOGIC_VECTOR(31 downto 0);
    signal PC_s         : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus4_s    : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus8_s    : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUFlags_s   : STD_LOGIC_VECTOR(3 downto 0);
    signal Result_s     : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUResult_s  : STD_LOGIC_VECTOR(31 downto 0);
    signal PCNextData_s : STD_LOGIC_VECTOR(31 downto 0);
begin
    U_PC_PATH : entity work.pc_path
        port map (
            clk => CLK, reset => reset, PCSrc => PCSrc_s, Result => PCNextData_s,
            PC => PC_s, PCPlus4 => PCPlus4_s, PCPlus8 => PCPlus8_s
        );

    U_IMEM : entity work.imem
        generic map (BL_TEST_MODE => BL_TEST_MODE)
        port map (PC => PC_s, Instr => Instr_s);

    U_MAIN : entity work.main_decoder
        port map (
            Op => Instr_s(27 downto 26),
            Funct5 => Instr_s(25),
            Funct4 => Instr_s(24),
            Funct0 => Instr_s(20),
            Branch => Branch_s,
            MemtoReg => MemtoReg_s,
            MemW => MemW_s,
            ALUSrc => ALUSrc_s,
            ImmSrc => ImmSrc_s,
            RegW => RegW_s,
            RegSrc => RegSrc_s,
            ALUOp => ALUOp_s,
            Link => Link_s
        );

    U_ALU_DEC : entity work.alu_decoder
        port map (
            ALUOp => ALUOp_s, Funct => Instr_s(24 downto 20),
            ALUControl => ALUControl_s, FlagW => FlagW_s
        );

    U_PC : entity work.pc_logic
        port map (
            Rd => Instr_s(15 downto 12), RegW => RegW_s,
            Branch => Branch_s, PCSrc => PCS_s
        );

    U_COND : entity work.condlogic
        port map (
            clk => CLK, reset => reset, Cond => Instr_s(31 downto 28),
            ALUFlags => ALUFlags_s, FlagW => FlagW_s,
            RegW => RegW_s, MemW => MemW_s, PCS => PCS_s,
            RegWrite => RegWrite_s, MemWrite => MemWrite_s, PCSrc => PCSrc_s
        );

    U_DP : entity work.datapath
        generic map (BL_TEST_MODE => BL_TEST_MODE)
        port map (
            CLK => CLK, Instr => Instr_s, MemtoReg => MemtoReg_s,
            MemWrite => MemWrite_s, ALUControl => ALUControl_s,
            ALUSrc => ALUSrc_s, ImmSrc => ImmSrc_s, RegWrite => RegWrite_s,
            RegSrc => RegSrc_s, Link => Link_s,
            PCPlus4 => PCPlus4_s, PCPlus8 => PCPlus8_s,
            Flags => ALUFlags_s, SrcA => open, SrcB => open,
            ALUResult => ALUResult_s, Output => WriteBackData,
            WriteData => WriteData, Result => Result_s, R14Value => R14Value
        );

    PCNextData_s <= ALUResult_s when Branch_s = '1' else Result_s;
    ALUResult <= ALUResult_s;
    PC <= PC_s;
    Instr <= Instr_s;
    PCSrc <= PCSrc_s;
    PCPlus4 <= PCPlus4_s;
    PCPlus8 <= PCPlus8_s;
    Link <= Link_s;
    RegWrite <= RegWrite_s;
end Structural;
