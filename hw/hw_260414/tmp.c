#include "stdio.h"
#include "math.h"

float cosines[8][8];
float cosines2[8][8];

void print_floats_as_hex(float * ptr, int n, const char * label){
    int i;
    printf("align 16\n%s dd ", label);
    for(i = 0; i < n; ++i){
        printf("0x%X", *(int *)(ptr + i));
        if(i < n - 1) printf(", ");
    }
    printf("\n");
}

float coefs[64];
int main(int argc, char ** argv){
    const float C0 = 1.0f;
    const float CN = sqrt(2.0f);
    const float PI = acosf(-1);
    int i,j;
    for(i = 0; i < 8; ++i)
        for(j = 0; j < 8; ++j)
            cosines2[i][j] = (j==0?C0:CN)*cosf(PI*((float)j)*(((float)i) + 0.5f)/8);
    for(i = 0; i < 8; ++i)
        for(j = 0; j < 8; ++j)
            cosines[j][i] = cosf(PI*((float)j)*(((float)i) + 0.5f)/8);
    coefs[0] = 0.015625f;
    for(i = 1; i < 8; ++i){
        coefs[i] = 0.03125f/sqrt(2.0f);
        coefs[i<<3] = 0.03125f/sqrt(2.0f);
    }
    for(i = 1; i < 8; ++i){
        for(j = 1; j < 8; ++j){
            coefs[(i<<3) ^ j] = 0.03125;
        }
    }
    print_floats_as_hex(cosines, 64, "cosines");
    print_floats_as_hex(coefs, 64, "coefs");
    print_floats_as_hex(cosines2, 64, "cosines2");
    float zero = 0;
    print_floats_as_hex(&zero, 1, "zero");
    return 0;
}
