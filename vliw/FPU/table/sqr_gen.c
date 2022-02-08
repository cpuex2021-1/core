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

int main(){
    intfloat fi;
    intfloat ans;
    for(int key = 0; key<512; key++){
        for(int d=0; d<16384; d++){
            fi.i = (128 << 23) + (key << 14) + d; // 0...0 <= key <= 0111..111
            ans.f = sqrt(fi.f);
            printf("%d ", ans.i & ((1<<23)-1));
        }
        printf("\n");
    }

    for(int key = 0; key<512; key++){
        for(int d=0; d<16384; d++){
            fi.i = (127 << 23) + (key << 14) + d; // 10....00 <= key <= 111..111
            ans.f = sqrt(fi.f);
            printf("%d ", ans.i & ((1<<23)-1));
        }
        printf("\n");
    }
}