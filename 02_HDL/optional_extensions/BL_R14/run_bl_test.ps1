$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSCommandPath
$vivadoBin = if ($env:XILINX_VIVADO) { Join-Path $env:XILINX_VIVADO "bin" } else { "C:/Xilinx/Vivado/2017.4/bin" }
$files = @(
    "adder.vhd",
    "alu_arithmetic.vhd",
    "result_selector.vhd",
    "flag_unit.vhd",
    "alu32.vhd",
    "alu_decoder.vhd",
    "condcheck.vhd",
    "flopenr.vhd",
    "flag_registers.vhd",
    "condlogic.vhd",
    "pc_reg.vhd",
    "pc_path.vhd",
    "register_file.vhd",
    "extend.vhd",
    "data_memory.vhd",
    "main_decoder.vhd",
    "pc_logic.vhd",
    "datapath.vhd",
    "imem.vhd",
    "arm_top.vhd",
    "tb_arm_top_bl.vhd"
) | ForEach-Object { Join-Path $root $_ }
Push-Location $root
try {
    & (Join-Path $vivadoBin "xvhdl.bat") -work work $files
    if ($LASTEXITCODE -ne 0) { throw "Analyse VHDL echouee: $LASTEXITCODE" }
    & (Join-Path $vivadoBin "xelab.bat") work.tb_arm_top_bl -s bl_r14_snapshot
    if ($LASTEXITCODE -ne 0) { throw "Elaboration echouee: $LASTEXITCODE" }
    & (Join-Path $vivadoBin "xsim.bat") bl_r14_snapshot -tclbatch "run_xsim.tcl" | Tee-Object -FilePath "BL_Test_Results.txt"
    if ($LASTEXITCODE -ne 0) { throw "Simulation echouee: $LASTEXITCODE" }
    $passCount = (Select-String -LiteralPath "BL_Test_Results.txt" -Pattern "B[1-8] PASS|B2 PASS; B3 PASS").Count
    if (-not (Select-String -LiteralPath "BL_Test_Results.txt" -Pattern "Tous les tests BL B1-B8 sont passes")) {
        throw "Le message final de validation est absent."
    }
    Write-Host "Simulation BL terminee; verifier les messages PASS dans BL_Test_Results.txt"
} finally {
    Pop-Location
}
