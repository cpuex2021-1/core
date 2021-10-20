# core

パイプライン作業中

src/inst.memにバイナリを書いてvivadoで
- src/top.svをdesign topに
- sim/simtop.svをsimulation top

にしてシミュレーションをすると多分動く。

./assembler in.txt out.txt
od -An -tx4 out.txt
の結果をinst.memに書くと幸せ

できたこと
- fib程度で必要な命令の動作
- MMIOでのuart (lw reg 0(r0) や sw reg 0(r0)で入出力できる）
- buggy pipeline(まだあんまり期待しないほうが良い)
- add rd ... ...→ add .. rd ..  のデータハザード対応

やること
- プログラムローダ　(命令列書くだけのはず）
- FPUの検証　等価モデル作成
- 各命令の動作チェック
- lwのデータハザード
- 制御ハザード
- 外部DDRを使えるように...
- キャッシュ........