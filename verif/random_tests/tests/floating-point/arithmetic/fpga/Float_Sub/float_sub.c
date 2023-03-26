#include <stdio.h>
#include "gpio.h"
float float_sub(float a , float b);
int main()
{
float a = 5.5 , b = 6.5 ;
float c = float_sub(5.5 , 6.5);
int x = c;
gpio_direct_write(3,x);
return 0; 
}
float float_sub(float a , float b)
{
return a-b;
}

