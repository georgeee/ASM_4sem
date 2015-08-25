#include <iostream>
#include <chrono>
#include <cstdlib>
#include <fstream>
#include <cmath>

extern "C" void _fdct(const float*, float*, unsigned int)__attribute__((__cdecl__));
extern "C" void _idct(const float*, float*, unsigned int)__attribute__((__cdecl__));

using namespace std;

unsigned int generate(float** ptr) {
    unsigned int n = 100;
    posix_memalign((void**)ptr, 16, n * 64 * sizeof(float));
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < 8; j++) {
            for(int k = 0; k < 8; k++) {
                (*ptr)[64 * i + 8 * j + k] = (float)(rand() % 50000);
            }
        }
    }
    return n;
}

float pc_cosf[64]__attribute__((aligned(16)));
float pc_cosi[64]__attribute__((aligned(16)));

void precalc() {
    for(int i = 0; i < 8; i++) {
        for(int j = 0; j < 8; j++) {
            pc_cosf[8 * i + j] = cos(3.14159 / 8 * (i + 0.5) * j) * sqrt(1 / 32.);
            if(j == 0) pc_cosf[8 * i + j] /= sqrt(2);
        }
    }
    for(int i = 0; i < 8; i++) pc_cosi[i] = 1;
    for(int i = 1; i < 8; i++) {
        for(int j = 0; j < 8; j++) {
            pc_cosi[8 * i + j] = sqrt(2) * cos(3.14159 / 8 * i * (j + 0.5));
        }
    }
}

inline void tarnsform(const float*, float*, unsigned int, const float*)__attribute__((always_inline));
inline void t_fdct(const float*, float*, unsigned int)__attribute__((always_inline));
inline void t_idct(const float*, float*, unsigned int)__attribute__((always_inline));

inline void transform(const float* __restrict__ in, float* __restrict__ out, unsigned int n, const float* __restrict__ t) {
    float* temp;
    posix_memalign((void**)&temp, 16, n * 64 * sizeof(float));
    for(int i = 0; i < n; i++) {
        for(int j = 0; j < 8; j++) {
            for(int k = 0; k < 8; k++) {
                int index = 64 * i + 8 * j;
                temp[index + k] = 0;
                for(int l = 0; l < 8; l++) {
                    temp[index + k] += in[index + l] * t[8 * l + k];
                }
            }
        }
        for(int j = 0; j < 8; j++) {
            for(int k = 0; k < 8; k++) {
                int index = 64 * i + 8 * k;
                out[index + j] = 0;
                for(int l = 0; l < 8; l++) {
                    out[index + j] += temp[64 * i + 8 * l + j] * t[8 * l + k];
                }
            }
        }
    }
    free(temp);
}

inline void t_fdct(const float* in, float* out, unsigned int n) {
    transform(in, out, n, pc_cosf);
}

inline void t_idct(const float* in, float* out, unsigned int n) {
    transform(in, out, n, pc_cosi);
}

bool a_eq(float a, float b) {
    return a > b - 0.5 && a < b + 0.5;
}

bool check(void (*ft)(const float*, float*, unsigned int), void (*it)(const float*, float*, unsigned int)) {
    bool res = true;
    ifstream f_in("test.in");
    float* in, *out, *temp;
    posix_memalign((void**)&in, 16, 64 * sizeof(float));
    posix_memalign((void**)&out, 16, 64 * sizeof(float));
    posix_memalign((void**)&temp, 16, 64 * sizeof(float));
    for(int i = 0; i < 64; i++) f_in >> in[i];
    ft(in, out, 1);
    for(int i = 0; i < 64; i++) {
        float x;
        f_in >> x;
        if(!a_eq(x, out[i])) res = false;
    }
    it(out, temp, 1);
    for(int i = 0; i < 64; i++) if(!a_eq(in[i], temp[i])) res = false;
    free(in);
    free(out);
    free(temp);
    f_in.close();
    return res;
}

int main() {
    precalc();
    cout << "Checking assembler implementation: ";
    if(!check(_fdct, _idct)) {
        cout << "Fail\n";
        return 0;
    }
    cout << "OK\nChecking c++ implementation      : ";
    if(!check(t_fdct, t_idct)) {
        cout << "Fail\n";
        return 0;
    }
    cout << "OK\nRunning tests... ";
    cout.flush();
    long long at = 0, ct = 0;
    for(int i = 0; i < 10000; i++) {
        float* in __attribute__((aligned(16))), *ar __attribute__((aligned(16))), *cr __attribute__((aligned(16)));
        int n = generate(&in);
        posix_memalign((void**)&ar, 16, 64 * n * sizeof(float));
        posix_memalign((void**)&cr, 16, 64 * n * sizeof(float));
        chrono::time_point<chrono::system_clock> start, end;
        start = chrono::system_clock::now();
        t_fdct(in, cr, n);
        end = chrono::system_clock::now();
        ct += chrono::duration_cast<chrono::nanoseconds>(end - start).count();
        start = chrono::system_clock::now();
        _fdct(in, ar, n);
        end = chrono::system_clock::now();
        at += chrono::duration_cast<chrono::nanoseconds>(end - start).count();
        for(int j = 0; j < 64 * n; j++) {
            if(!a_eq(cr[j], ar[j])){
                cout << "Fail!\n";
                for(int k = 0; k < 8; k++) {
                    for(int l = 0; l < 8; l++) {
                        cout << in[8 * k + l] << " ";
                    }
                    cout << "\n";
                }
                return 0;
            }
        }
        _idct(ar, cr, n);
        for(int j = 0; j < 64 * n; j++) {
            if(!a_eq(in[j], cr[j])){
                cout << "Fail!\n";
                for(int k = 0; k < 8; k++) {
                    for(int l = 0; l < 8; l++) {
                        cout << in[8 * k + l] << " ";
                    }
                    cout << "\n";
                }
                return 0;
            }
        }
        free(in);
        free(ar);
        free(cr);
    }
    cout << "OK\nTime taken:\n  c++: " << ct << "\n  asm: " << at << "\n";
    return 0;
}
