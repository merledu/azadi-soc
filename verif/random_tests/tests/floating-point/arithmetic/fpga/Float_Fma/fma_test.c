#include <stdio.h>
#include "gpio.h"
int main()
{
//a <- a + (b x c)
float a = 5.2 , b = 6.3  , c = 2.4 , x = a + ( b * c);
int y = x;
gpio_direct_write(3,y);

return 0; 
}
