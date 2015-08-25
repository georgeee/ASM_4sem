#include "stdio.h"

int main(int argc, char ** argv){
    long long d;
    sscanf(argv[1], "%llx", &d);
    printf("%lld\n", d);
    return 0;
}
