#include <stdio.h>

int add(int a, int b);

int main()
{
    float a = 50.25, b = 606;
    float c = add(a,b);
    return 0;
}

int add(int a, int b)
{
    return a-b;
}
