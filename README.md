# core


## プログラムローダの仕様
バイナリのバイト数 →　バイナリ

プログラムをprog.txtに書いたら
```bash
./assembler prog.txt out.bin
sudo python3 server.py (UARTのポート) -p out.bin
```
してsend.binを送りつければ良い。


参考までに
```
od -An -tx4 out.bin
```
するとバイナリが読める。

# 1st
## 祝1st完動:274[s]


## できたこと
- MMIOでのuart (lw reg 0(zero) や sw reg 0(zero)で入出力できる）
- 多分一通りパイプラインで一通り動くはず in 50Mhz
- プログラムローダー 
- FPUの検証　
- キャッシュが実機で動いた
- ライトスルーなので重め
- Branchは成立時後続2命令フラッシュ(1命令にもできそうはできそう)
- FPUを入れてシミュレータ上では動いた
- FPUクロック分割
- 各命令の動作チェック(あとjump,jalr)
- SW実装のFPU命令
- クロック分割したFPUに対してストール
## やること
- **高速化**

# 2nd
## やること
LW,SWをSIMD向けに拡張

# 実機高速化過程
1st 完動　247s (キャッシュ1024 * 4word)
