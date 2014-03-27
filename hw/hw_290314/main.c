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

int main(int argc, char ** argv){
    char res[100];
    _print(res, argv[1], argv[2]);
    /*int i;*/
    /*const int cnt = 17;*/
    /*for(i=0; i<cnt; ++i){*/
        /*printf("0x%02X", res[i]);*/
        /*if(i < cnt - 1) printf(", ");*/
    /*}*/
    /*putchar('\n');*/
    printf("'%s'\n", res);
    char format[100];
    format[0] = '\'';
    format[1] = '%';
    strcpy(format+2, argv[1]);
    int fl = strlen(format);
    format[fl++] = 'l';
    format[fl++] = 'l';
    format[fl++] = 'd';
    format[fl++] = '\'';
    format[fl++] = '\0';
    long long d = 0;
    sscanf(argv[2], "%llx", &d);
    printf(format, d);
    putchar('\n');
    return 0;
}


