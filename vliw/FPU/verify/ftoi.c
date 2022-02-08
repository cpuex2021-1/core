#include <stdio.h>
#include <stdlib.h>

typedef union intfloat{
    int   i;
    float f;
}intfloat;

int validfloat(int x){
    return (x>>23) != 255 && (x>>23) != 0;
}

int ftoi(int a){
    int s = a>>31;
    int e = (a>>23) & 0xff;
    long m = ((a & 0x7fffff) + (1l<<23) ) << 8;
    int zero = e < 126;
    int one  = e == 126;
    int over = e>157;
    int pos = (158 - e) & 0x3f;
    int mn = (m >> pos ) ;
    int mp = mn + 1;
    int cm ;
    if((m>>(pos-1))&1) cm = mp; else cm = mn;
    int res ;
    if(zero) res = 0;
    else if (one) res = 1;
    else if (over) res = 0x80000000;
    else res = cm;
    if(s) return ~res + 1;
    else return res;
}

int main(){
    intfloat input;
    intfloat ans,res;
    for(unsigned int i=0x80000000; ; i++){
        if(i==0xffffffff)break;
        input.i =  i;
        res.i = ftoi(input.i);
        if(input.f > 0.0) ans.i = (int)(input.f + 0.5);
        else ans.i = (int)(input.f - 0.5);
        if(ans.i != res.i){
        printf("f: %fans:%d, res:%d\n", input.f ,ans.i, res.i);
        }
    }
}