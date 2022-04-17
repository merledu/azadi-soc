#include <iostream>
#include <signal.h>
#include "Vazadi_top_verilator.h"
#include "verilated_vcd_c.h"

vluint64_t timeout = 0;
vluint64_t cycles  = 0;
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

  const char *arg_timeout = Verilated::commandArgsPlusMatch("timeout=");
  if (arg_timeout[0])
    timeout = atoi(arg_timeout+9);

  const char *arg_cycles = Verilated::commandArgsPlusMatch("cycles=");
  if (arg_cycles[0])
    cycles = atoi(arg_cycles+8);

  signal(SIGINT, INThandler);

  top->trace (tfp, 99);
  Verilated::mkdir("logs");
  tfp->open("logs/sim.vcd");

  // int num_cycles;
  // for (int i=0; i < argc; ++i){
  //   std::string arg = argv[i];
  //   if (arg.compare(std::string{"--cycles"}) == 0){
  //     sscanf(argv[++i], "%d", &num_cycles);
  //     printf("num_cycles = %d", num_cycles);
  //   }
  // }

  top -> clk_i = 0;

  while (!(Verilated::gotFinish() || done)){

    top->clk_i = !top->clk_i;
    
    top->rst_ni = (main_time < 8000 ) ? 0 : 1;
    top->prog_btn = (main_time >= 10000 &&  main_time <= 14000) ? 1 : 0;

    top->eval();

    if (tfp) tfp -> dump(main_time);

    main_time += 2000; // 4ns ~ 25MHz

    if (timeout && (main_time >= timeout)) {
      printf("Timeout: Exiting at time %lu\n", main_time);
      done = true;
    } else if (cycles && (cycles == (main_time/200))){
      printf("Requested number of cycles executed = %lu \n \
      1 = 10 clocks \n \
      Exiting at time %lu\n", cycles, main_time);
      done = true;
    }
  }
  if (tfp) tfp -> close();

  delete top;
  std::cout << "\nVerilatorTB: End of sim" << std::endl;

  exit(0);
}
