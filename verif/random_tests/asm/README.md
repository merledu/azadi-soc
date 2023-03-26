Testing Azadi SoC (in C and assembly both) 

|      Tests     |  Passed/Failed   |      Ports     |  Expected output   |  Actual output   |
|----------------|------------------|----------------|--------------------|------------------|
| add            |     Passed       |      gpio_o    |      0x0CH         |     0x0CH        |
| addi           |     Passed       |      gpio_o    |      0x06H         |     0x06H        |
| Branch         |     Passed       |      gpio_o    |      0x0DH         |     0x0DH        |
| Discriminant   |     Failed       |      gpio_o    | 0x02H(two solution)|       --         |
| Fibonacci      |     Failed       |      gpio_o    |  Fibonacci series  |       --         |
| jal            |     Passed       |      gpio_o    |      0x05H         |     0x05H        |
| logic_gates    |     Passed       |      gpio_o    |   0x0A,0X00,0X01E  | 0x0A,0X00,0X01E  |
| lui            |     Passed       |      gpio_o    |      0x2002H       |     0x2002H      |
| multiply       |     Passed       |      gpio_o    |      0x04H         |     0x04H        |
| slli           |     Passed       |      gpio_o    |      0xD0H         |     0xD0H        |
| slt            |     Passed       |      gpio_o    |      0x00H         |     0x00h        |
| slti           |     Passed       |      gpio_o    |      0x01H         |     0x01H        |
| sub            |     Passed       |      gpio_o    |      0x0AH         |     0x0AH        |
