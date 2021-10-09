# core

シングルサイクルでそれっぽくなった気はする。
ただしまだほとんどの命令をチェックしていないので動かなかったら許して

src/inst.memにバイナリを書いてvivadoで
- src/top.svをdesign topに
- sim/simtop.svをsimulation top

にしてシミュレーションをすると多分動く。


やること
- uartのloopback
- uartの組み合わせ(LWでできるように）
- 各命令の動作チェック
- マルチサイクル化
- 外部DDRを使えるように...
- キャッシュ........
- パイプライン化