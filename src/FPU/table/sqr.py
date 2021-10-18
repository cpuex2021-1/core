
#python wakaran
import sys


line = []
nums = []

n =16384 
xsum = (n-1) * n / 2
x2sum = n * (n+1) * (2*n +1) / 6

key = 0
i=0
with open('sqrlist.txt', 'r', encoding='utf-8') as fin:
    for line in fin.readlines():
        inprod = 0
        ysum = 0
        nums = line.split(' ')
        for d in range(n):
            f = int(nums[d]) << 23
            inprod += d * f
            ysum += f
        a = (n * inprod - xsum * ysum) / (n * x2sum - xsum ** 2)
        b = (x2sum * ysum - inprod * xsum) / (n*x2sum - xsum**2)
        #print(((hex(int(a) >> 10))[2:] ))
        #print(hex(int(b)>>23)[2:] )
        ans = (int(a) >> 10) + ((int(b) >> 23) << 13)
        print("init_grad[" + str(i) + "] = 36'h" + hex(ans)[2:] + ";")
        i = i+1
