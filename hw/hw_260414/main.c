#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "time.h"
#include "string.h"

void _fdct(float *in, float *out, unsigned int n);
void _idct(float *in, float *out, unsigned int n);

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

int eq(float * a, float * b, int n){
    for(int i = 0 ; i < n; ++i)
        if(fabsf(a[i]-b[i]) > 0.1f) return 0;
    return 1;
}
#define ATTR_ALIGN_16 __attribute__((__aligned__((16))))

#define N (100000)
ATTR_ALIGN_16 float a2[64*N];
ATTR_ALIGN_16 float b2[64*N];
ATTR_ALIGN_16 float c2[64*N];
ATTR_ALIGN_16 float d2[64*N];
ATTR_ALIGN_16 float a1[64*N];
ATTR_ALIGN_16 float b1[64*N];
ATTR_ALIGN_16 float c1[64*N];
ATTR_ALIGN_16 float d1[64*N];


int main(int argc, char ** argv){
    int i,j;
    const float PI = acosf(-1);
    for(i = 0; i < 8; ++i)
        for(j = 0; j < 8; ++j)
            cosines[i][j] = cosf(PI*((float)j)*(((float)i) + 0.5f)/8);
    srand(time(0));
    for(i = 0; i < 64*N; ++i) a1[i] = a2[i] = rand()%20000-10000;
    for(i=0;i<64*N;i++) c1[i] = d1[i] = b1[i] = c2[i] = d2[i] = b2[i] = 0;
    fdct(a1, b1, N);
    idct(b1, c1, N);
    idct(a1, d1, N);
    unsigned long long time;
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    time = ts.tv_nsec;
    _fdct(a2, b2, N);
    clock_gettime(CLOCK_MONOTONIC, &ts);
    time = ts.tv_nsec - time;
    printf("_fdct: %llu ns\n", time);
    clock_gettime(CLOCK_MONOTONIC, &ts);
    time = ts.tv_nsec;
    _idct(b2, c2, N);
    clock_gettime(CLOCK_MONOTONIC, &ts);
    time = ts.tv_nsec - time;
    printf("_idct: %llu ns\n", time);
    _idct(a2, d2, N);

    if(!eq(b1, b2, 64*N)){
        printf("1\n");
        /*print_arr("b1", b1);*/
        /*print_arr("b2", b2);*/
    }
    if(!eq(c1, c2, 64*N)){
        printf("2\n");
        /*print_arr("c1", c1);*/
        /*print_arr("c2", c2);*/
    }
    if(!eq(d1, d2, 64*N)){
        printf("3\n");
        /*print_arr("d1", d1);*/
        print_arr("d2", d2);
    }
    if(!eq(a1, c1, 64*N)){
        printf("4\n");
        /*print_arr("a1", a1);*/
        /*print_arr("c1", c1);*/
    }
    if(!eq(a2, c2, 64*N)){
        printf("5\n");
        /*print_arr("a2", a2);*/
        /*print_arr("c2", c2);*/
    }

    return 0;
}


