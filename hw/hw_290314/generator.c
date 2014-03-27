#include "stdio.h"

/*void _print(char *out_buf, const char *format, const char *hex_number);*/

/*int main(int argc, char ** argv){*/
    /*char res[100];*/
    /*_print(res, argv[1], argv[2]);*/
    /*puts(res);*/
    /*return 0;*/
/*}*/

void _print(unsigned char *out_buf, const char *format, const char *hex_number);

int main(int argc, char ** argv){
    unsigned char res[100];
    _print(res, argv[1], argv[2]);
    int i;
    for(i=0; i<16; ++i){
        printf("0x%02X", res[i]);
        if(i < 15) printf(", ");
    }
    putchar('\n');
    return 0;
}


