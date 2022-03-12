#include <iostream>
#include "Vazadi_top_verilator.h"
#include "verilated_vcd_c.h"

vluint64_t main_time = 0;

double sc_time_stamp () {
  return main_time;
}

int main (int argc, char **argv) {

  std::cout << "\nVerilatorTB: Start of sim\n" << std::endl; 
  Verilated::commandArgs(argc, argv);
  Vazadi_top_verilator* top = new Vazadi_top_verilator;

  Verilated::traceEverOn(true);
  VerilatedVcdC * tfp = new VerilatedVcdC;

  top->trace (tfp, 99);
  Verilated::mkdir("logs");
  tfp->open("logs/sim.vcd");

  top -> clk_i = 0;
  top -> gpio_i = 8;

  while (!Verilated::gotFinish()){

    top->clk_i = top->clk_i ? 0 : 1; 
    
    if(main_time < 5) {
      top -> rst_ni = 0;
    }
    else {
      top -> rst_ni = 1;
    }

    top->eval();

    if (tfp) tfp -> dump(main_time);

    main_time ++;
  }
  if (tfp) tfp -> close();

  delete top;
  std::cout << "\nVerilatorTB: End of sim" << std::endl;

  exit(0);
}
