#include <stdint.h>
#include <signal.h>
#include <iostream>
#include <cstdio>
#include <stdlib.h>

#include "Vazadi_soc_top.h"
#include "verilated_vcd_c.h"


using namespace std;


vluint64_t main_time = 0;
static bool done;

enum states {
  START,
  SHIFT,
  TOGGLE,
  DONE
};

void INThandler(int signal) {
	printf("\nCaught ctrl-c\n");
	done = true;
}

double sc_time_stamp () {
  return main_time;
}

// Reads hex file
void read_hex(const char * filepath, int *prog_image){
  FILE *fptr = fopen(filepath, "r");
  char line[9];
  int index=1;

  prog_image[0] = 0xB1;
  while(fscanf(fptr, "%s", line) && !feof(fptr)){
    if(line[0] != '@'){
      prog_image[index] = strtol(line, NULL, 16);
      index+=1;
    }
  }
}

int main (int argc, char **argv) {

  Verilated::commandArgs(argc, argv);
  Vazadi_soc_top* top = new Vazadi_soc_top;

  Verilated::traceEverOn(true);
  VerilatedVcdC * tfp = new VerilatedVcdC;

  const char *arg_rom = Verilated::commandArgsPlusMatch("ROM_BIN=");
  const char *arg_hex = Verilated::commandArgsPlusMatch("HEX=");
  
  int prog_image[1024];
  int counter = 0;
  int index = 0;

  states state = START;

  // arg_hex+5 because we want to remove "+HEX=" from the path string.
  if (arg_hex[0]){
    read_hex(arg_hex+5, prog_image);
  }

  cout << "\nVerilatorTB: Start of sim\n" << endl;
  signal(SIGINT, INThandler);

  top->trace (tfp, 99);
  Verilated::mkdir("build/logs");
  tfp->open("build/logs/sim.vcd");

  top -> clk_main_i = 0;
  top -> rst_ni = 0;
  top -> por_ni = 0;
  top -> pll_lock_i = 0;
  top -> boot_sel_o = 0;

  top -> hk_sck_i = 1;
  top -> hk_csb_i = 1;

  // simulation start
  while (!(Verilated::gotFinish()) && !done){

    top->clk_main_i = !top->clk_main_i;
    top->eval();
    if (tfp) tfp -> dump(main_time);

    // loads program through spi slave
    if(main_time > 20){
      
      top -> rst_ni = 1;
      top -> por_ni = 1;
      top -> pll_lock_i = 1;

      if(!top -> led_alive_o){
        switch (state)
        {
        case START:
          top -> hk_csb_i = 0;
          state = SHIFT;
          break;
        case SHIFT:
          top -> hk_sdi_i = prog_image[index] & 1;
          prog_image[index] = prog_image[index] >> 1;
          if(counter == 8) {
            index += 1;
            top -> hk_sck_i = 1;
            state = DONE;
            counter = 0;
          } else {
            top -> hk_sck_i = 0;
            state = TOGGLE;
          }
          counter += 1;
          break;
        case DONE:
          top -> hk_csb_i = 1;
          if(counter == 8) {
            counter = 0;
            state = START;
          } else {
            counter += 1;
          }
          break;
        case TOGGLE:
          top -> hk_sck_i = 1;
          if (top -> hk_csb_i == 0) state = SHIFT;
          break;
        default:
          break;
        }
      }
    }
    main_time++;
  }
  if (tfp) tfp -> close();

  delete top;
  cout << "\nVerilatorTB: End of sim" << endl;

  exit(0);
}