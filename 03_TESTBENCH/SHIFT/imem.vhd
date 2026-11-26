-- Programme de test SHIFT (S1-S10) et CMP C5 - GEI1084 MP1
-- Une instruction par mot; commentaire = assembleur ARM et resultat attendu.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity imem is
    port (
        PC    : in  STD_LOGIC_VECTOR(31 downto 0);
        Instr : out STD_LOGIC_VECTOR(31 downto 0)
    );
end imem;

architecture Behavioral of imem is

    type ROM_type is array (0 to 31)
        of STD_LOGIC_VECTOR(31 downto 0);

    constant ROM : ROM_type := (
        0  => x"E2801012",  -- 0x00 [setup] ADD R1, R0, #0x12
        1  => x"E2802034",  -- 0x04 [setup] ADD R2, R0, #0x34
        2  => x"E0821401",  -- 0x08 [S3] ADD R1, R2, R1, LSL #8      ; R1 = 0x1234
        3  => x"E2802056",  -- 0x0C [setup] ADD R2, R0, #0x56
        4  => x"E0821401",  -- 0x10 [S3] ADD R1, R2, R1, LSL #8      ; R1 = 0x123456
        5  => x"E2802078",  -- 0x14 [setup] ADD R2, R0, #0x78
        6  => x"E0821401",  -- 0x18 [S3] ADD R1, R2, R1, LSL #8      ; R1 = 0x12345678
        7  => x"E0803001",  -- 0x1C [S1] ADD R3, R0, R1, LSL #0      ; R3 = 0x12345678
        8  => x"E2804003",  -- 0x20 [setup] ADD R4, R0, #3
        9  => x"E0805084",  -- 0x24 [S2] ADD R5, R0, R4, LSL #1      ; R5 = 6
        10 => x"E0805204",  -- 0x28 [S3] ADD R5, R0, R4, LSL #4      ; R5 = 0x30
        11 => x"E2806020",  -- 0x2C [setup] ADD R6, R0, #0x20
        12 => x"E08070A6",  -- 0x30 [S4] ADD R7, R0, R6, LSR #1      ; R7 = 0x10
        13 => x"E2808001",  -- 0x34 [setup] ADD R8, R0, #1
        14 => x"E0808F88",  -- 0x38 [S5] ADD R8, R0, R8, LSL #31     ; R8 = 0x80000000
        15 => x"E08090A8",  -- 0x3C [S5] ADD R9, R0, R8, LSR #1      ; R9 = 0x40000000 (pas 0xC0000000)
        16 => x"E080A124",  -- 0x40 [S6] ADD R10, R0, R4, LSR #2     ; R10 = 0
        17 => x"E001B204",  -- 0x44 [S7] AND R11, R1, R4, LSL #4     ; 0x12345678 AND 0x30 = 0x30
        18 => x"E186C404",  -- 0x48 [S8] ORR R12, R6, R4, LSL #8     ; 0x20 OR 0x300 = 0x320
        19 => x"E046D104",  -- 0x4C [S8b] SUB R13, R6, R4, LSL #2     ; 0x20 - 0xC = 0x14 (SUB decale)
        20 => x"E084D006",  -- 0x50 [S9] ADD R13, R4, R6              ; sans decalage : 0x23
        21 => x"E284E085",  -- 0x54 [S10] ADD R14, R4, #0x85          ; chemin immediat : 0x88
        22 => x"E2802001",  -- 0x58 [setup] ADD R2, R0, #1
        23 => x"E1580002",  -- 0x5C [C5] CMP R8, R2                  ; 0x80000000 - 1 = 0x7FFFFFFF, NZCV = 0011
        24 => x"62803055",  -- 0x60 [C5] ADDVS R3, R0, #0x55        ; V = 1 : execute
        25 => x"428030AA",  -- 0x64 [C5] ADDMI R3, R0, #0xAA        ; N = 0 : non execute
        26 => x"EAFFFFFE",  -- 0x68 [end] B .                         ; fin
        others => (others => '0')
    );

begin

    Instr <= ROM(to_integer(unsigned(PC(6 downto 2))));

end Behavioral;
