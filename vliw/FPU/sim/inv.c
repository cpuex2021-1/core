#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
float InvSqrt1(float x){
    float simhalfnumber = 0.500438180f*x;
    int i = *(int*)&x;
    i = 0x5F375A86 - (i>>1);
    float y = *(float*)&i;
    y = y*(1.50131454f - simhalfnumber * y *y);
    y = y*(1.50000086f - 0.999124984f*simhalfnumber*y*y);
    return y;
}
typedef union float_int {
    float  f;
    int    i;
}float_int;

void print_bit(int x){
    for(int i=31; i>=0; i--){
        printf("%d",(x>>i) & 1 );
    }
    printf("\n");
}


int main(){
    srand(time(NULL));
    float x = (float)rand() / (float) RAND_MAX;
    float ans = sqrt(x);
    float invsqrt = InvSqrt1(x);
    float sqr  = 1.0f / invsqrt;
    printf("orig:%f\n", x);
    printf("ans :%f\n", ans);
    printf("sqrt:%f\n", sqr);
    float_int fi;
    fi.f = ans;
    print_bit(fi.i);
    fi.f = sqr;
    print_bit(fi.i);

}