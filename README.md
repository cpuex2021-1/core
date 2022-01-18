# core

今はキャッシュ動作確認のためにプログラムローダ方式じゃないので注意

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

## (vivadoのシミュレータで）動いたプログラム
fib.ml
ack.ml
sum.ml
sum-tail.ml
join_reg.ml
join_reg2.ml
join_stack.ml
join_stack2.ml
join_stack3.ml

## 実機で動いたプログラム
```
fib.ml
ack.ml
gcd.ml
```


## できたこと
- 
- MMIOでのuart (lw reg 0(zero) や sw reg 0(zero)で入出力できる）
- 多分一通りパイプラインで一通り動くはず in 50Mhz
- プログラムローダー 
- FPUの検証　
- キャッシュが実機で動いた
- ライトスルーなので重め
- Branchは成立時後続2命令フラッシュ(1命令にもできそうはできそう)
- FPUを入れてシミュレータ上では動いた
- FPUクロック分割

## やること
- 各命令の動作チェック(あとjump,jalr)
- SW実装のFPU命令
- クロック分割したFPUに対してストール
- **高速化**

