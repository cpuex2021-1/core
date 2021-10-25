#include <stdio.h>
#include <stdlib.h>

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

int lt(int x, int y){
    int xs = (x>>31) & 1;
    int ys = (y>>31) & 1;
    int xe = (x>>23) & 0xff;
    int ye = (y>>23) & 0xff;
    int xm = x & 0x7fffff;
    int ym = y & 0x7fffff;
    int el = xe < ye;
    int eeq = xe == ye;
    int ml = xm < ym;
    int absl = el | (eeq & ml);

    int pp = 1- (xs & ys);
    int np = xs && ~ys;
    int nn = xs & ys;

    int emeq = (x & 0x3fffffff) == (y& 0x3fffffff);
    //printf("x:%d xs:%d xe:%d xm:%d\n", x,xs,xe,xm);
    //printf("y:%d ys:%d ye:%d ym:%d\n", y,ys,ye,ym);
    //printf("el:%d eeq:%d mL:%d absl:%d pp:%d np:%d nn:%d\n", el,eeq,ml,absl,pp,np,nn);
    return (pp&&absl) || np || (nn && ~absl && ~emeq) || x==y;
}


int main(){
    intfloat a,b;
    for(int i=0; i<100000000; i++){
        a.i = rand();
        b.i = rand();
        if(!invalid_float(a.i, b.i)){
            int res = lt(a.i, b.i);
            int ans = a.f <= b.f;
            if(ans != res){
                printf("x:%f y:%f\n", a.f, b.f);
                printf("ans:%d res:%d\n", ans, res);
            }
        }
    }


}