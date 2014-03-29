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
    for(; mask < (1<<4); mask++){
        int fl = 0;
        if(mask & (1<<0)) format[fl++] = '0';
        if(mask & (1<<1)) format[fl++] = ' ';
        if(mask & (1<<2)) format[fl++] = '-';
        if(mask & (1<<3)) format[fl++] = '+';
        int w = 0;
        for(; w < wc; ++w){
            if(widths[w] == 0) format[fl] = 0;
            else sprintf(format + fl, "%d", widths[w]);
            if(!test(format, -1000, 1000)) return 0;
        }
    }
}

int main(int argc, char ** argv){
    test_format();
    test("", -100000, 100000);
    test("", -9223372036854775807, -9223372036854765807);
    test("", 9223372036854765807, 9223372036854775807);
    return 0;
}


