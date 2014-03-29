#include "stdio.h"
#include "string.h"

/*void _print(char *out_buf, const char *format, const char *hex_number);*/

/*int main(int argc, char ** argv){*/
    /*char res[100];*/
    /*_print(res, argv[1], argv[2]);*/
    /*puts(res);*/
    /*return 0;*/
/*}*/

void _print(char *out_buf, const char *format, const char *hex_number);

void gen_printf_format(char* printf_format, const char * format){
    int fl = 0;
    printf_format[fl++] = '%';
    strcpy(printf_format + fl, format);
    fl = strlen(printf_format);
    printf_format[fl++] = 'l';
    printf_format[fl++] = 'l';
    printf_format[fl++] = 'd';
    printf_format[fl++] = '\0';
}

void gen_res(char *printf_buffer, char *my_buffer, const char *format, const char *hex_number, long long d, const char * printf_format){
    _print(my_buffer, format, hex_number);
    sprintf(printf_buffer, printf_format, d);
}

char printf_buffer[1000];
char my_buffer[1000];
char hexnum_buffer[1000];

int test_number_impl(const char * format, const char * printf_format, long long d, char * hexnum_buffer){
    gen_res(printf_buffer, my_buffer, format, hexnum_buffer, d, printf_format);
    return strcmp(printf_buffer, my_buffer) == 0;
}

char * get_hexnum(long long d){
    int sign = d < 0;
    if(sign) hexnum_buffer[0] = '-';
    sprintf(hexnum_buffer+sign, "%llx", sign ? -d : d);
    return hexnum_buffer;
}

int test_number(const char * format, const char * printf_format, long long d){
    return test_number_impl(format, printf_format, d, get_hexnum(d));
}

int test(const char * format, long long min, long long max){
    char printf_format[100];
    gen_printf_format(printf_format, format);
    int res = 1;
    long long i = min;
    while(i <= max && res)
        if((res = test_number(format, printf_format, i))){
            if(i==max) break;
            else ++i;
        }
    if(!res) printf("./main '%s' %s\ni=%lld\n", format, get_hexnum(i), i);
    return res;
}

/* next lexicographical permutation */
int next_lex_perm(char *a, int n) {
#define swap(i, j) {t = a[i]; a[i] = a[j]; a[j] = t;}
    int k, l, t;

    /* 1. Find the largest index k such that a[k] < a[k + 1]. If no
     * such
     *        index exists, the permutation is the last permutation. */
    for (k = n - 1; k && a[k - 1] >= a[k]; k--);
    if (!k--) return 0;

    /* 2. Find the largest index l such that a[k] < a[l]. Since
     * k + 1 is
     *     such an index, l is well defined */
    for (l = n - 1; a[l] <= a[k]; l--);

    /* 3. Swap a[k] with a[l] */
    swap(k, l);

    /* 4. Reverse the sequence from a[k + 1] to the end
     * */
    for (k++, l = n - 1; l > k; l--, k++)
        swap(k, l);
    return 1;
#undef swap
}

int test_format(){
    int mask = 0;
    char format[100];
    int widths [100];
    int wc = 0;
    widths[wc++] = 0;
    widths[wc++] = 5;
    widths[wc++] = 10;
    widths[wc++] = 20;
    widths[wc++] = 50;
    widths[wc++] = 100;
    char modifiers[10];
    modifiers[0] = ' ';
    modifiers[1] = '+';
    modifiers[2] = '-';
    modifiers[3] = '0';
    modifiers[4] = '\0';
    int j;
    for(j = 0; j < 24; ++j){
        for(; mask < (1<<4); mask++){
            int fl = 0;
            int i = 0;
            for(; i < 4; ++i)
                if(mask & (1<<i)) format[fl++] = modifiers[i];
            int w = 0;
            for(; w < wc; ++w){
                if(widths[w] == 0) format[fl] = 0;
                else sprintf(format + fl, "%d", widths[w]);
                if(!test(format, -1000, 1000)) return 0;
            }
        }
        next_lex_perm(modifiers, 4);
    }
}


int main(int argc, char ** argv){
    test_format();
    test("", -100000, 100000);
    test("", -9223372036854775807, -9223372036854765807);
    test("", 9223372036854765807, 9223372036854775807);
    return 0;
}


