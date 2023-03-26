# Azadi-SoC

This repo has RTL, simulation, verification (UVM), APR files and scripts of `Azadi-SoC`.

The progress chart of this project is being documented using GitHub Projects and can be be viewed [here](https://github.com/merledu/azadi-tsmc/projects/1).

## SoC Block Diagram
![SoC Block Diagram](docs/azadi-tsmc.png)

## Memory Map
We are using TileLink-UL bus protocol in Azadi SoC to enable communication of CPU with peripherals. The overview of the internal cross bars are shown in the given picture.  

![xbar-overview](docs/xbar-overview.png)

<details>
<summary> The memory map table of SoC: </summary>
<p>

|  Host           |  Peripheral           |  Base Address    |  Max Address     |  Address Space |
|:------------    |:--------------------- |:---------------- |:-----------------|:-------------- |
| Host0 (IFU)     | QSPI Flash Controller | 32'h80000000     | 32'h80FFFFFF     |    2 MBytes    |
|                 | ICCM (32KB)           | 32'h10000000     | 32'h10001FFF     |    1 KBytes    |
| Host1 (LSU)     | DCCM (32KB)           | 32'h20000000     | 32'h20001FFF     |    1 KBytes    |
|                 | Boot Register         | 32'h20002000     | 32'h20002000     |    4  Bytes    |
|                 | Timer0                | 32'h30000000     | 32'h30000FFF     |  512  Bytes    |
|                 | Timer1                | 32'h30001000     | 32'h30001FFF     |  512  Bytes    |
|                 | Timer2                | 32'h30002000     | 32'h30002FFF     |  512  Bytes    |
|                 | TIC                   | 32'h30003000     | 32'h300030FF     |   32  Bytes    |
|                 | Periph                | 32'h40000000     | 32'h4000FFFF     |    8 KBytes    |
|                 | PLIC                  | 32'h50000000     | 32'h50000FFF     |  512  Bytes    |
|                 | ROM                   | 32'h60000000     | 32'h500000FF     |  256  Bytes    |
| **Periph (Xbar-peripheral)** |          |                  |                  |                |
| LSU -> periph   | GPIO                  | 32'h40001000     | 32'h400010FF     |   32  Bytes    |
|                 | UART0                 | 32'h40002000     | 32'h400020FF     |   32  Bytes    |
|                 | UART1                 | 32'h40002100     | 32'h400021FF     |   32  Bytes    |
|                 | UART2                 | 32'h40002200     | 32'h400022FF     |   32  Bytes    |
|                 | UART3                 | 32'h40002300     | 32'h400023FF     |   32  Bytes    |
|                 | SPI0                  | 32'h40003000     | 32'h400030FF     |   32  Bytes    |
|                 | SPI1                  | 32'h40003100     | 32'h400031FF     |   32  Bytes    |
|                 | SPI2                  | 32'h40003200     | 32'h400032FF     |   32  Bytes    |
|                 | SPI3                  | 32'h40003300     | 32'h400033FF     |   32  Bytes    |
|                 | PWM0                  | 32'h40004000     | 32'h400040FF     |   32  Bytes    |
|                 | PWM1                  | 32'h40004100     | 32'h400041FF     |   32  Bytes    |
|                 | PWM2                  | 32'h40004200     | 32'h400042FF     |   32  Bytes    |
|                 | PWM3                  | 32'h40004300     | 32'h400043FF     |   32  Bytes    |
</p>
</details>
