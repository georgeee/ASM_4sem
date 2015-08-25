#include "stdio.h"

unsigned long long fac(unsigned int a){
    unsigned int result = 1;
    int i=1; 
    do{
       result*=i++; 
    }while(i<=a);
    return result;
}


int main(){
    int i;
    scanf("%d", &i);
    printf("%llu\n", fac(i));
    return 0;
}
