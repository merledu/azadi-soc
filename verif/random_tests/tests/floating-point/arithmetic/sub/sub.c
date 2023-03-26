#include <stdio.h>

float sub(float a, float b);

int main()
{
    float a = 36252.4, b = 1160.26;
    float c = sub(a,b);
    return 0;
}

float sub(float a, float b)
{
    return a-b;
}
