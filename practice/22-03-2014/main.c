#include "stdio.h"

unsigned long long fac(unsigned int);
double fac_d(int);

int main(){
    int i;
    scanf("%d", &i);
    printf("%llu\n", fac(i));
    printf("%lf\n", fac_d(i));
    return 0;
}
