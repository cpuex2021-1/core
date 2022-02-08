#include <stdio.h>
#include <stdlib.h>
#include <math.h>

long init_grad[1024];

typedef union intfloat{
    int   i;
    float f;
}intfloat;

int mask(int n){
    return (1<<n) - 1;
}
void print_bit(int x){
    for(int i=31; i>=0; i--){
        printf("%d", (x>>i)&1);
        if(i==31)printf("_");
        if(i==23)printf("_");
    }
    printf("\n");
}

float finv(float x){
    intfloat ai;
    ai.f = x;
    long key = (ai.i >> 13) & ((1ll<<10) - 1);
    long diff= ai.i & ((1<<13) -1);
    int ae = (ai.i >>23) & ((1<<8)-1);
    int as = ai.i >> 31;
    int e;
    // e >= 253のときは結果が非正規化数になるので考えなくていっちゃいい
    if(ae >253 ) e = 0; else  e = 253- ae;

    long a,b;
    a = init_grad[key] &  ((1ll<<13)-1);
    b = (init_grad[key]>>13) << 13 ; 
    long m_ =  b -  2 * a * diff;
    int m = m_ >> 13;
    ai.i = (as<<31) | (e<<23) | m;
    return ai.f;
}

void finv_init(){
    FILE *fp;
    fp = fopen("invparam.txt", "r");
    for(int i=0; i<1024; i++){
        fscanf(fp, "%lx", &init_grad[i]);
    }
    fclose(fp);
}

int main(){
    finv_init();

    int maxerr = 0;
    for(int e = 253; e<256; e++){
    for(int key = 0; key<1024; key++){
        int kerr= 0;
        for(int diff = 0; diff<8192; diff++){
            intfloat f;
            intfloat est;
            f.i = (e<< 23) + (key<<13) + diff;
            est.f = finv(f.f);
            f.f = 1.0/f.f;
            if(e==253) print_bit(f.i);
            //printf("%f %f\n", f.f,  est.f);
            kerr += abs(f.i- est.i);
            if(abs(f.i>est.i) > maxerr) maxerr = abs(f.i-est.i);
        }
        printf("e: %d key:%d err:%d\n",e, key, kerr);
    }
    }
    printf("maxerr: %d\n", maxerr);

}