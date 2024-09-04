## pin outputs to connect to logic analyzer (ARTY S7-25 Board ONLY)
                        
## CLK
set_property -dict { PACKAGE_PIN R2    IOSTANDARD SSTL135 } [get_ports { clk }]; #IO_L12P_T1_MRCC_34 Sch=ddr3_clk[200]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5.000}  [get_ports { clk }];

## INPUT
set_property -dict { PACKAGE_PIN C18   IOSTANDARD LVCMOS33 } [get_ports { rst_n }]; #IO_L11N_T1_SRCC_15
set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { miso }]; #IO_L8N_T1_D12_14 Sch=ja_n[4]

set_property -dict { PACKAGE_PIN M16   IOSTANDARD LVCMOS33 } [get_ports { cs }]; #IO_L7P_T1_D09_14 Sch=ja_p[3]
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { sck }]; #IO_L7N_T1_D10_14 Sch=ja_n[3]
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { mosi }]; #IO_L8P_T1_D11_14 Sch=ja_p[4]


set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { data[0] }]; #IO_L24P_T3_A01_D17_14        Sch=jd10/ck_io[26]
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { data[1] }]; #IO_L23N_T3_A02_D18_14        Sch=jd9/ck_io[27]
set_property -dict { PACKAGE_PIN R11   IOSTANDARD LVCMOS33 } [get_ports { data[2] }]; #IO_L23P_T3_A03_D19_14        Sch=jd8/ck_io[28]
set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { data[3] }]; #IO_L22N_T3_A04_D20_14        Sch=jd7/ck_io[29]
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { data[4] }]; #IO_L22P_T3_A05_D21_14        Sch=jd4/ck_io[30]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { data[5] }]; #IO_L21N_T3_DQS_A06_D22_14    Sch=jd3/ck_io[31]
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { data[6] }]; #IO_L21P_T3_DQS_14            Sch=jd2/ck_io[32]
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { data[7] }]; #IO_L20N_T3_A07_D23_14        Sch=jd1/ck_io[33]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { data[8] }]; #IO_L20P_T3_A08_D24_14        Sch=jc10/ck_io[34]
set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { data[9] }]; #IO_L19N_T3_A09_D25_VREF_14   Sch=jc9/ck_io[35]
set_property -dict { PACKAGE_PIN P13   IOSTANDARD LVCMOS33 } [get_ports { data[10] }]; #IO_L19P_T3_A10_D26_14        Sch=jc8/ck_io[36]
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { data[11] }]; #IO_L16P_T2_CSI_B_14          Sch=jc7/ck_io[37]

set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { dv }]; #IO_L15N_T2_DQS_DOUT_CSO_B_14 Sch=jc4/ck_io[38]

