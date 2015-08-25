#include "stdio.h"

unsigned long long fac(unsigned int);

int main(){
    int i;
    scanf("%d", &i);
    printf("%llu\n", fac(i));
    return 0;
}
