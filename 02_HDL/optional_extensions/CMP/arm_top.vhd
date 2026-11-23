


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity arm_top is
    Port (
        CLK       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;

        PC        : out STD_LOGIC_VECTOR(31 downto 0);
        Instr     : out STD_LOGIC_VECTOR(31 downto 0);
        PCSrc     : out STD_LOGIC;
        
        ALUResult    : out STD_LOGIC_VECTOR(31 downto 0);
        WriteData    : out STD_LOGIC_VECTOR(31 downto 0);
        
        -- Sorties de diagnostic pour les tests CMP
        ALUFlags_dbg : out STD_LOGIC_VECTOR(3 downto 0);
        FlagW_dbg    : out STD_LOGIC_VECTOR(1 downto 0);
        RegWrite_dbg : out STD_LOGIC;
        Flags_dbg    : out STD_LOGIC_VECTOR(3 downto 0)

    );
end arm_top;

architecture Structural of arm_top is

    -- Signaux du decodeur principal
    signal Branch_s   : STD_LOGIC;
    signal MemtoReg_s : STD_LOGIC;
    signal MemW_s     : STD_LOGIC;
    signal ALUSrc_s   : STD_LOGIC;
    signal RegW_s     : STD_LOGIC;
    signal ALUOp_s    : STD_LOGIC;

    signal ImmSrc_s : STD_LOGIC_VECTOR(1 downto 0);
    signal RegSrc_s : STD_LOGIC_VECTOR(1 downto 0);

    -- Signaux du decodeur ALU
    signal ALUControl_s : STD_LOGIC_VECTOR(1 downto 0);
    signal FlagW_s      : STD_LOGIC_VECTOR(1 downto 0);
    

    -- Commande brute du PC
    signal PCS_s : STD_LOGIC;

    -- Commandes conditionnelles
    signal PCSrc_s    : STD_LOGIC;
    signal RegWrite_s : STD_LOGIC;
    signal MemWrite_s : STD_LOGIC;

    -- Signaux de la memoire d'instructions
    signal Instr_s : STD_LOGIC_VECTOR(31 downto 0);

    -- Signaux du chemin PC
    signal PC_s       : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus4_s  : STD_LOGIC_VECTOR(31 downto 0);
    signal PCPlus8_s  : STD_LOGIC_VECTOR(31 downto 0);

    -- Signaux du datapath
    signal ALUFlags_s : STD_LOGIC_VECTOR(3 downto 0);
    signal Flags_s : STD_LOGIC_VECTOR(3 downto 0);
    signal Result_s   : STD_LOGIC_VECTOR(31 downto 0);

begin

    -- 1. Chemin PC
    U_PC_PATH : entity work.pc_path
        port map (
            clk     => CLK,
            reset   => reset,
            PCSrc   => PCSrc_s,
            Result  => Result_s,
            PC      => PC_s,
            PCPlus4 => PCPlus4_s,
            PCPlus8 => PCPlus8_s
        );

    -- 2. Memoire d'instructions
    U_IMEM : entity work.imem
        port map (
            PC    => PC_s,
            Instr => Instr_s
        );

    -- 3. Decodeur principal
    U_MAIN : entity work.main_decoder
        port map (
            Op       => Instr_s(27 downto 26),
            Funct5   => Instr_s(25),
            Funct0   => Instr_s(20),

            Branch   => Branch_s,
            MemtoReg => MemtoReg_s,
            MemW     => MemW_s,
            ALUSrc   => ALUSrc_s,
            ImmSrc   => ImmSrc_s,
            RegW     => RegW_s,
            RegSrc   => RegSrc_s,
            ALUOp    => ALUOp_s,
            Opcode   => Instr_s(24 downto 21)
        );

    -- 4. Decodeur ALU
    U_ALU_DEC : entity work.alu_decoder
        port map (
            ALUOp      => ALUOp_s,
            Funct      => Instr_s(24 downto 20),
            ALUControl => ALUControl_s,
            FlagW      => FlagW_s
        );

    -- 5. Logique PC brute
    U_PC : entity work.pc_logic
        port map (
            Rd     => Instr_s(15 downto 12),
            RegW   => RegW_s,
            Branch => Branch_s,
            PCSrc  => PCS_s
        );

    -- 6. Logique conditionnelle
    U_COND : entity work.condlogic
        port map (
            clk      => CLK,
            reset    => reset,
            Cond     => Instr_s(31 downto 28),
            ALUFlags => ALUFlags_s,
            FlagW    => FlagW_s,

            RegW     => RegW_s,
            MemW     => MemW_s,
            PCS      => PCS_s,

            RegWrite  => RegWrite_s,
            MemWrite  => MemWrite_s,
            PCSrc     => PCSrc_s,
            Flags_dbg => Flags_s
        );

    -- 7. Datapath
    U_DP : entity work.datapath
        port map (
            CLK        => CLK,
            Instr      => Instr_s,

            MemtoReg   => MemtoReg_s,
            MemWrite   => MemWrite_s,
            ALUControl => ALUControl_s,
            ALUSrc     => ALUSrc_s,
            ImmSrc     => ImmSrc_s,
            RegWrite   => RegWrite_s,
            RegSrc     => RegSrc_s,
            PCPlus8    => PCPlus8_s,

            Flags      => ALUFlags_s,
            SrcA       => open,
            SrcB       => open,
            ALUResult  => ALUResult,
            Output     => open,
            WriteData  => WriteData,
            Result     => Result_s
        );

    -- 8. Sorties du processeur
    PC    <= PC_s;
    Instr <= Instr_s;
    PCSrc <= PCSrc_s;
    
    -- Signaux de diagnostic
    ALUFlags_dbg <= ALUFlags_s;
    FlagW_dbg    <= FlagW_s;
    RegWrite_dbg <= RegWrite_s;    
    Flags_dbg <= Flags_s;


end Structural;

