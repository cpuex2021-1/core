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
// 最小二乗法
int y[8191];
/*long xsum = 8191l * 4096l; // 8191 * 8192 / 2
long x2sum = 8191l * 8192l * 16383l / 6l; // n * (n+1) * (2n+1) / 6
int err[1000];*/
int main(){
    intfloat fi;
    intfloat ans;
    for(int key = 0; key<1024; key++){
        long mul = 0;
        long sum = 0;
        for(int d =0; d<8192; d++){
            fi.i = (127 << 23) + (key << 13) + d;
            //print_bit(fi.i);
            ans.f = 1.0f/fi.f;
            y[d] = ((long)ans.i & ((1<<23) -1)) ;
            if(key==0 && d == 0)y[d] = (1<<23)  -1;
            printf("%d " ,y[d]);
        }
            /*mul += d * y[d];
            sum += y[d];
        
        long a = (mul - xsum/8192 * sum ) / (x2sum - xsum / 8192l * xsum );
        long b = (sum - a * xsum) / 8192;
        for(int i=0; i<1000; i++){
            err[i] = 0;
        }
        for(int d = 0; d<8192; d++){
            int ans = y[d] >> 23;
            int est = (a*d + b) >> 23;
            /*printf("ans:");
            print_bit(ans);
            printf("est:");
            print_bit(est);
            printf("%d\n", abs(ans - est));
        }
        printf("err\n");
        for(int i=0; i<100; i++){
            printf("%d : %d\n", i, err[i]);
        }
        printf("sum:%ld\n", sum);
        printf("mul:%ld\n", mul);
        printf("a:%ld\n", a);
        printf("b:%ld\n", b);*/
        printf("\n");
    }

}