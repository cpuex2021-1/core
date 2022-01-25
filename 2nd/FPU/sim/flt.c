#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

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

int invalid_float(int x, int y){
    int xe = (x >> 23) & 0xff;
    int ye = (y >> 23) & 0xff;
    return xe == 0 || xe == 255 || ye == 0 || ye ==255;
}

long long lt(long long x, long long y){
    long long  xs = (x>>31) & 1;
    long long  ys = (y>>31) & 1;
    long long  xe = (x>>23) & 0xff;
    long long  ye = (y>>23) & 0xff;
    long long  xm = x & 0x7fffff;
    long long  ym = y & 0x7fffff;
    long long  el = xe < ye;
    long long  eeq = xe == ye;
    long long  ml = xm < ym;
    long long  absl = el | (eeq & ml);

    long long  pp = xs ==0 && ys ==0;
    long long  np = xs == 1&& ys == 0;
    long long  nn = xs==1 & ys==1;

    long long emeq = (x & 0x7fffffff) == (y& 0x7fffffff);
    //printf("x:%d xs:%d xe:%d xm:%d\n", x,xs,xe,xm);
    //printf("y:%d ys:%d ye:%d ym:%d\n", y,ys,ye,ym);
    //printf("el:%d eeq:%d mL:%d absl:%d pp:%d np:%d nn:%d\n", el,eeq,ml,absl,pp,np,nn);
    return (pp&&absl) || np || (nn==1 && absl==0 && emeq==0);
}


int main(){
    intfloat a,b;
    a.f = -1.0;
    b.f = -1.25;
    printf("%f %f\n", a.f,b.f);
    printf("%lld %d\n", lt((long long)a.i,(long long)b.i), a.f<b.f);
    srand(time(NULL));
        a.i = -rand();
    for(int i=INT_MIN; i<INT_MAX; i++){
        b.i = i;
        if(!invalid_float(a.i, b.i)){
            long long res = lt((long long)a.i, (long long)b.i);
            int ans = a.f < b.f;
            if(ans != res){
                printf("x:%f y:%f\n", a.f, b.f);
                printf("ans:%d res:%lld\n", ans, res);
            }
        }
    }


}