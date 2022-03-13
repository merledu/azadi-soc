#include <iostream>
#include <signal.h>
#include "Vazadi_top_verilator.h"
#include "verilated_vcd_c.h"

vluint64_t main_time = 0;
static bool done;

void INThandler(int signal) {
	printf("\nCaught ctrl-c\n");
	done = true;
}

double sc_time_stamp () {
  return main_time;
}

int main (int argc, char **argv) {

  std::cout << "\nVerilatorTB: Start of sim\n" << std::endl; 
  Verilated::commandArgs(argc, argv);
  Vazadi_top_verilator* top = new Vazadi_top_verilator;

  Verilated::traceEverOn(true);
  VerilatedVcdC * tfp = new VerilatedVcdC;

  signal(SIGINT, INThandler);

  top->trace (tfp, 99);
  Verilated::mkdir("logs");
  tfp->open("logs/sim.vcd");

  top -> clk_i = 0;
  top -> gpio_i = 8;

  while (!(Verilated::gotFinish() || done)){

    top->clk_i = !top->clk_i;
    
    if(main_time < 4000) {
      top -> rst_ni = 0;
    }
    else {
      top -> rst_ni = 1;
    }

    top->eval();

    if (tfp) tfp -> dump(main_time);

    main_time += 2000; // 4ns ~ 25MHz
  }
  if (tfp) tfp -> close();

  delete top;
  std::cout << "\nVerilatorTB: End of sim" << std::endl;

  exit(0);
}
