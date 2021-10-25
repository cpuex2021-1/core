# core

現状プログラムローダに読ませる方式

## プログラムローダの仕様
命令数(1byte) →　バイナリ

プログラムをprog.txtに書いたら
```bash
./assembler prog.txt out.bin
xxd -p out.bin | sed 1s/^/(16進で命令数)/ | xxd -p -r send.bin
```
してsend.binを送りつければ良い。
命令数の部分は15命令だったら```sed 1s/^/0f/```みたいな感じ

参考までに
```
od -An -tx4 out.bin
```
するとバイナリが読める。



## できたこと
- fib程度で必要な命令の動作
- MMIOでのuart (lw reg 0(r0) や sw reg 0(r0)で入出力できる）
- 多分一通りパイプラインで一通り動くはず in 100Mhz
- プログラムローダー 
- FPUの検証　等価モデル作成(add,sub以外)

## やること
- 各命令の動作チェック
- 外部DDRを使えるように...
- キャッシュ........
- LWでストールするようにして高速化する

