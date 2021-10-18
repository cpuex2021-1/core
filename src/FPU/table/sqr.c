#include <stdio.h>
#include <stdlib.h>
#include <math.h>

long init_grad[1024];


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

void initsqr(){
    FILE *fp;
    fp = fopen("sqrparam.txt", "r");
    for(int i=0; i<1024; i++){
        fscanf(fp, "%lx", &init_grad[i]);
    }
    fclose(fp);
}

float sqr(float a){
    intfloat x;
    x.f = a;
    int s = x.i>>31;
    int e = (x.i>>23 ) & 0xff;
    long key = (x.i>>14) & 0x3ff;
    long diff = x.i & 0x3fff;
    long init = (init_grad[key] >> 13) << 13;
    long grad = init_grad[key] & 0x1fff;
    /*if(diff==1023){
        printf("key:%ld", key);
        printf("diff:%ld\n", diff);
        printf("init:%ld\n", init);
        printf("grad:%ld\n", grad);
    }*/
    long m_ = init  + grad * diff;
    int m = m_>>13;
    //printf("%d\n", m);
    x.i = (s<<31) + ((((e+127)/2) << 23)) + m;
    //printf("%d\n", x.i);
    float ans = x.f;
    //print_bit(x.i);
    return ans;

}

int main(){
    initsqr();

    intfloat ans;
    intfloat est;

    /*for(int e = 1; e<256; e=e+2){
        for(int key=0; key <1024; key++){
            for(int diff=0; diff<16384; diff++){
                ans.i = (e<<23) + (key<<14) + diff;

                if(key==1023){
                    printf("%f: %f %f\n", ans.f, sqrt(ans.f), sqr(ans.f));
                }


            }
        }
    }*/
    int maxerr = 0;
    for(unsigned int i = 127<<23; i<(129<<23); i++){
        ans.i = i;
        est.f = sqr(ans.f);
        ans.f = sqrt(ans.f);
        int diff = abs(est.i-ans.i);
        //printf("%f %f\n", ans.f, est.f);
        if(diff > maxerr) maxerr = diff;
    }
    printf("maxerr:%d\n", maxerr);

}