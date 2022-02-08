#include <stdio.h>
typedef union intfloat{
    int   i;
    float f;
}intfloat;

void print_bit(int x){
    for(int i=31; i>=0; i--){
        printf("%d", (x>>i)&1);
        if(i==31)printf("_");
        if(i==23)printf("_");
    }
    printf("\n");
}

int invalid_float(int x){
    int xe = (x >> 23) & 0xff;
    return xe == 0 || xe == 255 ;
}

int fadd(int x, int y){
    int xs = x>>31;
    int ys = y>>31;
    int xe = (x>>23) & 0xff;
    int ye = (y>>23) & 0xff;
    int xzero = xe == 0;
    int yzero = ye == 0;
    long xm = (1 << 23) | (x & 0x7fffff);
    long ym = (1 << 23) | (y & 0x7fffff);

    
 
}

int main(){

}