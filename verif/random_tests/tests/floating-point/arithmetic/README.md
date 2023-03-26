Testing Floating Point Unit of Azadi SoC in assembly.

|        Tests       |  Passed/Failed   |  Expected output   |  Actual output   |
|--------------------|------------------|--------------------|------------------|
|       FADD.S       |     Passed       |       0x21         |      0x21        |  
|       FCLASS.S     |     Passed       |       0X40         |      0X40        |
|       FCVT.S.W     |     Passed       |       0X25         |      0X25        | 
|       FCVT.S.WU    |     Passed       |       0X41A        |      0X41A       |
|       FCVT.W.S     |     Passed       |       0X14         |      0X14        |
|       FCVT.WU.S    |     Passed       |       0X14         |      0X14        |
|       FDIV.S       |     Passed       |       0X40         |      0X40        |
|       FEQ.S        |     Passed       |       0X00         |      0X00        |
|       FLE.S        |     Passed       |       0X01         |      0X01        |
|       FLT.S        |     Passed       |       0X01         |      0X01        |
|       FLW.S        |     Passed       |       0x21         |      0x21        |
|       FMADD.S      |     Passed       |       0X40A0       |      0X40A0      |
|       FMAX.S       |     Passed       |       0X14         |      0X14        |
|       FMIN.S       |     Passed       |       0X0D         |      0X0D        |
|       FMSUB.S      |     Passed       |       0XBF80       |      0XBF80      |
|       FMUL.S       |     Passed       |       0x410        |      0x410       |
|       FMV.S.X      |     Passed       |       0x20         |      0x20        |
|       FMV.X.S      |     Passed       |       0x14         |      0x14        |
|       FNMADD.S     |     Passed       |       0XC0A0       |      0XC0A0      |
|       FMNMSUB.S    |     Passed       |       0X3F80       |      0x3F80      |
|       FSIGNJ.S     |     Passed       |       0X3F80       |      0x3F80      |
|       FSIGNJN.S    |     Passed       |       0XBF80       |      0xBF80      |
|       FSIGNJX.S    |     Passed       |       0X3F80       |      0x3F80      |
|       FSQRT.S      |     Passed       |       0X40A0       |      0X40A0      |
|       FSUB.S       |     Passed       |       0X14         |      0x14        |
|       FSW.S        |     Passed       |       0x21         |      0x21        |
