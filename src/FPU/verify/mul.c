#include <stdio.h>
#include <stdlib.h>

typedef union intfloat{
    int   i;
    float f;
}intfloat;

int validfloat(int x){
    return (x>>23) != 255 && (x>>23) != 0;
}

float fmul(float a, float b){
    intfloat aa,bb;
    aa.f = a;
    bb.f = b;
    int s1,s2, s;
    s1 = aa.i>>31;
    s2 = bb.i>>31;
    s  = s1 ^ s2;


    int e1, e2, eadd, en,ep, e;
    e1 = (aa.i>>23) & 0xff;
    e2 = (bb.i>>23) & 0xff;
    eadd = e1 + e2;
    en = eadd - 127;
    ep = eadd - 126;

    long m1,m2;
    m1 = (aa.i & 0x7fffff) + 0x800000;
    m2 = (bb.i & 0x7fffff) + 0x800000;
    long mul = m1 * m2;
    int m;
    if(mul>>47) {
        if ((ep>>8) & 3 == 3) {
            e = 0;
        }else if((ep>>8) == 0) {
            e = ep;
        }else {
            e = 255;
        }
        m = (mul>>24) & 0x7fffff;
    } else {
        if ((en>>8) & 3 == 3) {
            e = 0;
        }else if((en>>8) == 0) {
            e = en;
        }else {
            e = 255;
        }
        m = (mul>>23) & 0x7fffff;
    }
    intfloat ans;
    ans.i = (s<<31) + (e<<23) + m;
    return ans.f;

}

int main(){
    intfloat a,b;
    intfloat res,est;
    int maxerr =0;
    float erra,errb,errans, errest;
    erra = 0;
    errb = 0;
    errans = 0;
    errest = 0;
    for(int i=0; i<10000000; i++){
            int ea,eb;
            ea = rand() %255;
            eb = rand() %255;
            int ma,mb;
            ma = rand() % ((1<<23) -1);
            mb = rand() % ((1<<23) -1);
            a.i = (ea << 23) + ma;
            b.i = (eb << 23) + mb;
            res.f = a.f * b.f;
            est.f = fmul(a.f, b.f);
            if( validfloat(a.i) && validfloat(b.i) && validfloat(res.i)){
                //printf("%e %e\n", res.f, est.f);
                if(abs(res.i-est.i) > maxerr) {
                    erra = a.f;
                    errb = b.f;
                    errans = res.f;
                    errest = est.f;
                    maxerr = abs(res.i-est.i);
                }
            }
    }
    printf("a:%e b:%e ans:%e est:%e\n", erra, errb, errans, errest);
    printf("maxerr:%d\n", maxerr);

}