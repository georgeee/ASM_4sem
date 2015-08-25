#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "string.h"
#include "time.h"

void _fdct(float *in, float *out, unsigned int n);
void _idct(float *in, float *out, unsigned int n);

#define ATTR_ALIGN_16 __attribute__((__aligned__((16))))

ATTR_ALIGN_16 float a[64];
ATTR_ALIGN_16 float b[64];
ATTR_ALIGN_16 float c[64];
ATTR_ALIGN_16 float d[64];

void print_arr(const char * name, const float * a){
    printf("%s:", name);
    int i,j;
    for(i=0; i<64; ++i){
        if(! (i & 7)) putchar('\n');
        printf("%.3f ", a[i]);
    }
    putchar('\n');
    putchar('\n');
}

float cosines[8][8];

void fdct(float *_in, float *_out, unsigned int N){
    const float C0 = 0.125f;
    const float CN = 0.25f/sqrt(2);
    float * in1 = malloc(sizeof(float)*64);
    float * in = _in;
    float * out = _out;
    for(int block = 0; block < N; block++){
        for(int i = 0; i < 8; ++i){
            for(int j = 0; j < 8; ++j){
                int index = (i<<3) ^ j;
                in1[index] = 0;
                for(int n = 0; n < 8; ++n){
                    in1[index] += in[(i<<3) ^ n]*cosines[n][j];
                }
            }
        }
        for(int i = 0; i < 8; ++i){
            for(int j = 0; j < 8; ++j){
                int index = (i<<3) ^ j;
                out[index] = in1[index];
                out[index] = 0;
                for(int n = 0; n < 8; ++n){
                    out[index] += in1[(n<<3) ^ j]*cosines[n][i];
                }
            }
        }
        out[0] *= 0.015625f;
        for(int i = 1; i < 8; ++i){
            out[i] *= 0.03125f/sqrt(2);
            out[i<<3] *= 0.03125f/sqrt(2);
        }
        for(int i = 1; i < 8; ++i){
            for(int j = 1; j < 8; ++j){
                out[(i<<3) ^ j] *= 0.03125;
            }
        }
        in += 64;
        out += 64;
    }
    free(in1);
}

void idct(float *_in, float *_out, unsigned int N){
    const float C0 = 1.0f;
    const float CN = sqrt(2);
    float * in1 = malloc(sizeof(float)*64);
    float * in = _in;
    float * out = _out;
    for(int block = 0; block < N; block++){
        /*in[0] /= 0.015625f;*/
        /*for(int i = 1; i < 8; ++i){*/
            /*in[i] /= 0.03125f/sqrt(2);*/
            /*in[i<<3] /= 0.03125f/sqrt(2);*/
        /*}*/
        /*for(int i = 1; i < 8; ++i){*/
            /*for(int j = 1; j < 8; ++j){*/
                /*in[(i<<3) ^ j] /= 0.03125;*/
            /*}*/
        /*}*/
        for(int i = 0; i < 8; ++i){
            for(int j = 0; j < 8; ++j){
                int index = (i<<3) ^ j;
                in1[index] = 0;
                for(int n = 0; n < 8; ++n){
                    in1[index] += (n==0?C0:CN)*in[(i<<3) ^ n]*cosines[j][n];
                }
            }
        }
        for(int i = 0; i < 8; ++i){
            for(int j = 0; j < 8; ++j){
                int index = (i<<3) ^ j;
                /*out[index] = in1[index];*/
                out[index] = 0;
                for(int n = 0; n < 8; ++n){
                    out[index] += (n==0?C0:CN)*in1[(n<<3) ^ j]*cosines[i][n];
                }
            }
        }
        in += 64;
        out += 64;
    }
    free(in1);
}

int main(int argc, char ** argv){
    int i,j;
    const float PI = acosf(-1);
    for(i = 0; i < 8; ++i)
        for(j = 0; j < 8; ++j)
            cosines[i][j] = cosf(PI*((float)j)*(((float)i) + 0.5f)/8);
    /*for(i=0; i<64; ++i) scanf("%f", &a[i]);*/
    /*a[0] = 1;*/
    /*a[1] = 10;*/
    /*a[2] = 100;*/
    /*a[3] = 1000;*/
    /*a[4] = 10000;*/
    /*a[5] = 100000;*/
    /*a[6] = 1000000;*/
    /*a[7] = 10000000;*/
    /*a[8+0] = 2;*/
    /*a[8+1] = 20;*/
    /*a[8+2] = 200;*/
    /*a[8+3] = 2000;*/
    /*a[8+4] = 20000;*/
    /*a[8+5] = 200000;*/
    /*a[8+6] = 2000000;*/
    /*a[8+7] = 20000000;*/
    a[0]=-16342;
    a[1]=2084;
    a[2]=-10049;
    a[3]=10117;
    a[4]=2786;
    a[5]=-659;
    a[6]=-4905;
    a[7]=12975;
    a[8]=10579;
    a[9]=8081;
    a[10]=-10678;
    a[11]=11762;
    a[12]=6898;
    a[13]=444;
    a[14]=-6422;
    a[15]=-15892;
    a[16]=-13388;
    a[17]=-4441;
    a[18]=-11556;
    a[19]=-10947;
    a[20]=16008;
    a[21]=-1779;
    a[22]=-12481;
    a[23]=-16230;
    a[24]=-16091;
    a[25]=-4001;
    a[26]=1038;
    a[27]=2333;
    a[28]=3335;
    a[29]=3512;
    a[30]=-10936;
    a[31]=5343;
    a[32]=-1612;
    a[33]=-4845;
    a[34]=-14514;
    a[35]=3529;
    a[36]=9284;
    a[37]=9916;
    a[38]=652;
    a[39]=-6489;
    a[40]=12320;
    a[41]=7428;
    a[42]=14939;
    a[43]=13950;
    a[44]=1290;
    a[45]=-11719;
    a[46]=-1242;
    a[47]=-8672;
    a[48]=11870;
    a[49]=-9515;
    a[50]=9164;
    a[51]=11261;
    a[52]=16279;
    a[53]=16374;
    a[54]=3654;
    a[55]=-3524;
    a[56]=-7660;
    a[57]=-6642;
    a[58]=11146;
    a[59]=-15605;
    a[60]=-4067;
    a[61]=-13348;
    a[62]=5807;
    a[63]=-14541;
    fdct(a, b, 1);
    idct(b, c, 1);
    /*idct(a, d, 1);*/
    print_arr("orig (C)", a);
    print_arr("fdct (C)", b);
    for(i=0;i<64;i++)b[i]=0;
    print_arr("fdct . idct (C)", c);
    for(i=0;i<64;i++)c[i]=0;
    /*print_arr("idct (C)", d);*/
    unsigned long long time;
    time = clock();
    _fdct(a, b, 1);
    time = clock() - time;
    printf("_fdct: %llu ms\n", time * 1000000 / CLOCKS_PER_SEC);
    time = clock();
    _idct(b, c, 1);
    time = clock() - time;
    printf("_idct: %llu ms\n", time * 1000000 / CLOCKS_PER_SEC);
    /*_idct(a, d, 1);*/
    /*print_arr("orig", a);*/
    print_arr("fdct", b);
    print_arr("fdct . idct", c);
    /*print_arr("idct", d);*/
    return 0;
}


