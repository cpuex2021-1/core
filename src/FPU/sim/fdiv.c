#include <stdio.h>
#include <stdlib.h>

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
long init_grad[1024];
int finv(int x){
    long key = (x >> 13) & ((1ll<<10) - 1);
    long diff= x & ((1<<13) -1);
    int ae = (x >>23) & ((1<<8)-1);
    int as = x >> 31;
    int e;
    // e >= 253のときは結果が非正規化数になるので考えなくていっちゃいい
    if(ae >253 ) e = 0; else  e = 253- ae;

    long a,b;
    a = init_grad[key] &  ((1ll<<13)-1);
    b = (init_grad[key]>>13) << 13 ; 
    long m_ =  b -  2 * a * diff;
    int m = m_ >> 13;
    x = (as<<31) | (e<<23) | m;
    return x;
}
int fdiv(int x, int y){
    int xs = x>>31;
    int ys = y>>31;
    int xe = (x>>23) & 0xff;
    int ye = (y>>23) & 0xff;
    int zero = xe == 0;
    long xm = (1 << 23) | (x & 0x7fffff);
    long key = (y>>13) & 0x3ff;
    long diff = y & 0x1fff;
    long init = (init_grad[key] & 0xfffffe000);
    long grad = init_grad[key] & 0x1fff;
    long ym_ = init - 2 * diff * grad;
    long ym =  (1<<23) | (ym_>>13);
    //long ym = (1l << 23) + (finv(y) & 0x7fffff);
    long m_ = xm * ym;
    long m;
    int e_ = xe - ye + 126;
    if (m_ >>47) {
        m = (m_ >> 24) & 0x7fffff;
        e_++;
    }else{
        m = (m_ >> 23) & 0x7fffff;
    }
    int e = e_ & 0xff;
    int s = xs ^ ys;
    if(zero){
        return 0;
    }else{
        return (s << 31 ) | (e<<23) | m;
    }
}
void initdiv(){
    FILE *fp;
    fp = fopen("invparam.txt", "r");
    for(int i=0; i<1024; i++){
        fscanf(fp, "%lx", &init_grad[i]);
    }
    fclose(fp);
}
int main(){
    initdiv();
    intfloat x,y;
    intfloat res,ans;
    for(int i=0; i<100; i++){
        x.i = rand();
        y.i = rand();
        res.i = fdiv(x.i, y.i);
        printf("%f %f ans:%f res:%f\n", x.f, y.f, x.f/y.f, res.f);
    }
    for(int i=0; i<10000000; i++){
        x.i = rand();
        y.i = rand();
        if(!invalid_float(x.i) && !invalid_float(y.i)){
            ans.f = x.f / y.f;
            res.i = fdiv(x.i, y.i);
            if(!invalid_float(ans.i) && abs(ans.i - res.i)>=8){
                //printf("x:%f y:%f\n", x.f, y.f);
                printf("ans:%f res:%f\n", ans.f, res.f);
            }
        }
    }

}