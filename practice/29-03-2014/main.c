#include "stdio.h"

double seq(double, int);

int main(int argc, char ** argv){
    int i;
    double d;
    sscanf(argv[1], "%lf", &d);
    sscanf(argv[2], "%d", &i);
    printf("%lf\n", seq(d,i));
    return 0;
}
