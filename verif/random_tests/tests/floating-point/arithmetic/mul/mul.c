#include <stdio.h>

float mul(float a, float b);

int main()
{
    float a = 50.25, b = 606;
    float c = mul(a,b);
    return 0;
}

float mul(float a, float b)
{
    return a*b;
}
