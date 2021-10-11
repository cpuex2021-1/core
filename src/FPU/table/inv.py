#python wakaran
import sys


line = []
nums = []

xsum = 8191 * 4096
x2sum = 8191 * 4096 * 5461
n = 8192

key = 0
with open('invlist.txt', 'r', encoding='utf-8') as fin:
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
        print((-int(a) >> 11) << 11)
        print((int(b) >> 23) << 23)
