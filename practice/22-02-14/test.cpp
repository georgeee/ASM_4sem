#include <cstdio>

using namespace std;

int main(){
    char str[255];
    char * s = str;
    scanf("%s", str);
    for(;*s != 0; s++)
        printf("%d, ", *s);
    printf("\nnew line char: %d", (int)'\n');
    return 0;
}
