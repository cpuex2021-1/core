#include <stdio.h>
#include <stdlib.h>
#include <math.h>

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

void print_long(long x){
    for(int i=63; i>=0; i--){
        if(i==22)printf("_");
        if(i==45)printf("_");
        printf("%ld", (x>>i)&1l);
    }
    printf("\n");

}
int max(int a, int b){
    return a>b ? a : b;
}

int main(){
    intfloat fi;
    intfloat ans;
    int allerr;
    int maxerr =0;
    
    for(int key = 0; key<1024; key++){
        int kerr = 0;
        long a,b;
        scanf("%ld", &a);
        scanf("%ld", &b);
        //printf("a:%ld b:%ld\n", a,b);
        for(long d = 0; d<8192; d++){
            if(key == 0 && d == 0)continue;
            fi.i = (127 << 23) + (key << 13) + d;
            ans.f = 1.0f / fi.f;
            int ansm = ans.i & ((1<<23)-1);
            long est = -a * d + b;
            int estm = est >> 23 & ((1<<23) -1);
            kerr += abs(ansm - estm);
            maxerr = max(maxerr, abs(ansm - estm));
        }
        if(key < 100)printf("%dth average error: %lf\n", key, (double)kerr / 8192.0);
        allerr += kerr;
    }
    printf("maxerr:%d\n", maxerr);

}