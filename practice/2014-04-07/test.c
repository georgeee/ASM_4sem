__attribute__((__aligned__((16)))) float a[4] = { 300.0, 4.0, 4.0, 12.0 };
__attribute__((__aligned__((16)))) float b[4] = {   1.5, 2.5, 3.5,  4.5 };

int main(){
    __asm__ volatile
        (
         "movups %[a], %%xmm0\n\t"	// поместить 4 переменные с плавающей точкой из a в регистр xmm0
         "movups %[b], %%xmm1\n\t"	// поместить 4 переменные с плавающей точкой из b в регистр xmm1
         "mulps %%xmm1, %%xmm0\n\t"	// перемножить пакеты плавающих точек: xmm0 = xmm0 * xmm1
         // xmm00 = xmm00 * xmm10
         // xmm01 = xmm01 * xmm11
         // xmm02 = xmm02 * xmm12
         // xmm03 = xmm03 * xmm13
         "movups %%xmm0, %[a]\n\t"	// выгрузить результаты из регистра xmm0 по адресам a
         :
         : [a]"m"(*a), [b]"m"(*b)
         : "%xmm0", "%xmm1"
        );
    return 0;
}
