# 適応信号モデルに基づくフィンガープリンティング手法を用いた自律移動ロボット統合型動的無線屋内位置推定

Ren C. Luo, Fellow, IEEE, and Tung Jung Hsiao $\textcircled{1}$

要旨: 受信信号強度（RSS）に基づく屋内位置推定は、環境が変化すると精度が低下する。本論文では、動的環境向けの適応型無線屋内位置推定システム（ILS）を開発する。このシステムは、データベース自動更新処理と、adaptive signal model fingerprinting（ASMF）と呼ぶ新しいフィンガープリンティングアルゴリズムの 2 要素から構成される。ILS では、自己位置推定可能な移動ロボットを配置し、位置推定空間内で RSS 測定データを継続的に収集して、フィンガープリントデータベースを自律的に更新する。ASMF は、データベース更新に必要な時間と RSS データ量を削減するよう設計されている。ASMF における信号フィンガープリントは、ビーコン位置と 3 つの信号モデルにより構成され、回帰および最適化アルゴリズムに基づいて適切に補正できる。さらに、静的環境および動的環境におけるターゲット位置推定実験を提案し、ASMF アルゴリズムを従来の三辺測量法および k 近傍法フィンガープリンティングと比較する。実験結果は、ASMF ベースの ILS が静的環境・動的環境の両方で大幅に優れた性能を示し、自律更新される ASMF データベースによって位置推定精度を実際に維持できることを示している。

索引語: 適応データベース、適応信号モデル、動的フィンガープリンティング、屋内位置推定。

# I. はじめに

社会の近代化に伴い、人々は 1 日の半分以上を屋内で過ごしている。屋内位置ベースサービス（LBS）は、最も成長可能性の高い商用産業の一つとなっている。さらに、屋内 LBS の中核技術である屋内位置推定は大きな注目を集めている [1]。全地球測位システムは世界で最も普及した無線位置推定技術であるが、屋内環境では性能が低い。これまでに、屋内位置推定の実現に向けて、視覚 [2]、Kinect [3]、RFID [4]–[6]、超音波 [7], [8]、Wi-Fi [9]–[11] など、多様なセンサが文献で提案されてきた。しかし、装置コストと導入の容易さを考慮すると、受信信号強度（RSS）を用いる無線周波数センサが、依然として屋内位置推定システム（ILS）で最も一般的な選択肢である。RSS ベース ILS には、大きく分けて幾何学的手法とフィンガープリンティング手法の 2 つがある。幾何学的手法は、ターゲットとビーコンの幾何関係に基づいて位置を決定する。幾何学ベース ILS は実装が容易だが、非見通し（NLOS）の影響を強く受けるため、位置精度が低くなる。一方、フィンガープリンティング手法は、特定の参照点（RP）に対応する信号フィンガープリントを記録した既存データベースに基づいてターゲットを推定する。静的環境では、NLOS の RSS 測定値もフィンガープリンティングデータベース構築時に考慮できるため、この手法は NLOS の影響を緩和し、より高い精度を得られる [31], [32]。しかし、信号データ取得に時間がかかること、信頼できる特徴抽出の前処理負荷が重いこと、データベースの柔軟性が低いことから、フィンガープリンティングベース ILS の実装は容易ではない。

一般に、動的環境におけるフィンガープリンティングベース ILS には、次の 3 つの共通課題がある。

1) 障害物の遮蔽によって生じる位置推定誤差をどう減らすか。  
2) ビーコン位置が変化した場合にデータベースをどう調整するか。  
3) 動的環境で精度をどう維持するか。

静的環境における第 1 の問題は NLOS に起因するものであり、これに対処する多くの手法が提案されている。たとえば統計的手法として、二変量ガウス混合モデル（GMM）を用いて NLOS が引き起こす距離誤差の影響を打ち消す方法がある [12]。統計的手法は有効かつ簡便だが、障害物が移動して学習済みモデルが無効になるため、動的環境には不向きである。動的環境において可変障害物の干渉を軽減するには、移動障害物の検出が重要となる。[13], [14] では、異常な信号減衰の変化量を計算することで未知物体を検出し、デバイスを持たないターゲットの位置推定を行うために、ラジオトモグラフィ法が用いられている。さらに、位置推定空間全体の異常減衰をラジオトモグラフィ法でマッピングでき、その結果を動的環境における第 1 の問題への対処に利用できる。第 2 の問題では、最も本質的なのはビーコン位置を継続的に取得する方法である。これは、作業空間内の未知ビーコンを継続的に位置推定する問題とみなせる。最も一般的な方法は、個体または複数の移動ロボットに未知ビーコンからの信号データを収集させることである。この信号データとロボットの計測姿勢を組み合わせれば、未知ビーコンの位置推定が可能となる [15], [16]。第 3 の問題に対しては、複数のフィンガープリンティングシステムから得られる空間相関を動的に融合してターゲットを位置推定する動的フィンガープリンティング結合法が提案されている [17]。また、修正ベイズ回帰アルゴリズムに基づいて詳細な無線マップを動的に推定・較正する新しいクライアント/サーバ型システムも提案されている [18]。多くの動的フィンガープリンティングアルゴリズムが提案されているが、変化するパラメータ更新の計算コストは依然として大きい。そこで本論文では、動的環境で ILS を実現するため、自律的なデータベース更新処理と新しいフィンガープリンティング手法を提案する。本論文の貢献は以下のとおりである。

1) adaptive signal model fingerprinting（ASMF）と呼ぶ新しいアルゴリズムに基づく ILS を構築した。この ILS はターゲット位置推定とデータベース更新を同時に行え、動的環境へ適応可能である。  
2) 自己位置推定可能なロボットを位置推定エリア巡回用に配置した。ロボットは RSS 測定データを継続的に収集し、エリアの地図を作成する。RSS 測定値と地図を用いてデータベースを構築・更新する。  
3) 動的データベース構築のために ASMF アルゴリズムを開発した。ASMF データベース中のフィンガープリントは信号モデルとビーコン位置によって決まり、信号モデルを補正することで容易に調整できる。ASMF は従来手法より短時間でフィンガープリンティングデータベースを再構築できる。  
4) 信号雑音、異常信号減衰の分布、および RSS と距離の関係に対して 3 つの信号モデルを設計した。  
5) パスロスモデルと信号雑音のフィッティングに回帰法を用い、従来の対数パスロスモデルや白色ガウス雑音より高い位置推定精度を得た。  
6) シャドーイングモデルを設計して、位置推定空間における異常信号減衰をマッピングし、障害物の遮蔽による信号電力損失を補償した。  
7) 実験結果により、提案 ILS は静的環境・動的環境の両方で、三辺測量ベース ILS および k 近傍法フィンガープリンティング（KNNF）ベース ILS より高性能であることを示した。

本論文の構成は以下のとおりである。第 II 章ではシステム構成を示す。第 III 章では ASMF で用いる信号モデルを説明する。第 IV 章では ASMF データベースの構築・更新とターゲット位置推定の流れを示す。第 V 章では、提案 ILS と他の一般的手法を比較する実験を行う。第 VI 章で結論を述べる。

![](images/6471b2549a6031d635f30d84b6404be0a966bf0afa960dff940e03c326282808.jpg)  
図 1. ASMF ベース ILS の構成。

![](images/33b2d86976075395aeda6b95771a2c8528cb3c1d30dd4180ecd319670bfddcf6.jpg)  
図 2. Kangaroo ロボット。

# II. システム構成

ILS 全体構成を図 1 に示す。システムは、ビーコン、ターゲット、ロボット、コンピュータの 4 区分から成る。まず、ILS で用いるビーコンは IEEE 802.15.4 プロトコルに準拠した ZigBee 開発ボードである。ビーコン群は $2 0 \ \mathrm { H z }$ の送信周波数で周期的にターゲットとロボットへ信号を送信する。次にターゲットは、人が携行する ZigBee ボードであり、ビーコンからの信号を受信して RSS 測定データをコンピュータに送信する。第三に、図 2 に示すように、“Kangaroo” と呼ぶロボットは本研究室で設計・開発された。ロボットには ZigBee ボードと Hokuyo レーザレンジファインダ（LRF）が搭載されている。ロボットは LRF とオドメトリに基づき、同時自己位置推定地図作成（SLAM）アルゴリズム [19], [20] により自己位置推定とエリア地図作成を行う。ロボット上のボードは、$0 . 5 \ : \mathrm { s }$ ごとに RSS 測定データとロボット位置をコンピュータへ送信する設定である。最後にコンピュータ側で、ターゲットとロボットの位置推定、および必要に応じたデータベース更新を行う。ASMF ベース ILS の処理は、図 3 および図 4 に示すように、オフライン段階とオンライン段階の 2 段階に分けられる。オフライン段階では、ロボットが位置推定エリア内を移動し、RP においてビーコンからの RSS 測定データを記録する。続いて、ビーコン位置と 3 種類の信号モデル、すなわちフェージングモデル、シャドーイングモデル、フィッティングパスロスモデルを含む初期 ASMF データベースを導出する。オンライン段階では、ILS はターゲットとロボットの位置推定を行い、データベース中の不適切なパラメータを補正する。図 4 の右側では、ターゲットから送られる RSS 測定データと ASMF データベースに基づいてターゲット位置を推定する。同時に、ロボットが 1 周の巡回を終えるたびに、ロボットから記録された RSS 測定データとデータベース中のフィンガープリントを比較する。その後、ILS は環境変化を認識し、データベース中のモデルを補正する。更新データベース処理は図 4 左側に示す。

![](images/58d0030e25a039d4624327146c9c66334cf6d631c0141fad48fa64f31f99121d.jpg)  
図 3. オフライン段階における ASMF ベース ILS のフローチャート。

![](images/cd64b0f2e1e4297cabe62176be51c22c20149cb305ac3cbc59a00722688b2eec.jpg)  
図 4. オンライン段階における ASMF ベース ILS のフローチャート。

# III. ASMF 信号モデル

式 (1) で表される対数距離パスロスモデルは、伝送距離と RSS の関係を記述する最も一般的なモデルである。ここで、$V ( d )$ は伝送距離 $d$ に対応する RSS、$V _ { d _ { o } }$ は基準伝送距離 $d _ { o }$ に対応する基準 RSS、$\gamma$ は電力減衰係数、$\textstyle { \mathcal { N } } ( 0 , \sigma ^ { 2 } )$ は標準偏差（SD）$\sigma$ をもつ平均 0 のガウス分布である信号雑音を表す。距離の単位はメートル（m）、RSS の単位は dBm である。しかし、このモデルは単純すぎ、複雑な環境で正確な距離を得るには不十分である。そこで本論文では、式 (2) で表す、より適切な信号モデルを提案する。ここで、$N _ { F } ( d )$ は測定誤差とマルチパス効果による雑音、$S ( \mathbf { p } _ { t } , \mathbf { p } _ { b } )$ は送信機と受信機がそれぞれ $\mathbf { p } _ { t }$、$\mathbf { p } _ { b }$ にあるときの遮蔽効果による追加信号減衰、$V _ { F } ( d )$ は伝送距離と RSS の変換関数である。

![](images/af84d4f3ced32902c9c791052587620dc883ed7a74f838266a4deb4fba3413bc.jpg)  
図 5. フェージングモデル学習に用いた RSS データセットの標準偏差。

RSS 値

$$
\begin{array} { l } { { V ( d ) = V _ { d _ { o } } - 1 0 \gamma \log \left( d / d _ { o } \right) + N ( 0 , \sigma ^ { 2 } ) } } \\ { { V ( d ) = V _ { F } ( d ) - S ( \mathbf { p } _ { t } , \mathbf { p } _ { b } ) + N _ { F } ( d ) . } } \end{array}
$$

# A. フェージングモデル

ASMF では、無線信号の測定雑音とマルチパス効果による雑音を推定するためにフェージングモデルを用いる。先行研究によれば、GMM は無線信号雑音の分布を表す適切なモデルである [12], [21]。そこで本研究では、異なる 2 つの標準偏差を持つ平均 0 の 2 つのガウス分布からフェージングモデルを構成する。モデルは次式で表される。

$$
N _ { F } ( d ) \sim \phi _ { 1 } ( d ) { \bf \cal N } ( 0 , \sigma _ { 1 } ^ { 2 } ) + \phi _ { 2 } ( d ) { \bf \cal N } ( 0 , \sigma _ { 2 } ^ { 2 } )
$$

ここで、$\phi _ { 1 } ( d )$ は第 1 ガウス分布の重み、$\phi _ { 2 } ( d ) = 1 - \phi _ { 1 } ( d )$ は第 2 ガウス分布の重み、$\sigma _ { 1 }$ と $\sigma _ { 2 }$ は標準偏差である。混乱を避けるため、$\sigma _ { 1 } < \sigma _ { 2 }$ とし、第 1 ガウス分布が常に低分散成分になるようにする。フェージングモデル中のパラメータを決めるため、実環境のリンク測定統計に基づいて RSS 雑音の統計を調査した。研究室内に 10 個のビーコンを設置し、40 の異なる位置で RSS 測定データを収集した。合計 400 セットの RSS 測定データが得られ、各位置で各ビーコンから約 $1 1 0 0 ~ \mathrm { R S S }$ 値を取得した。次に、RSS 測定データの標準偏差を、計測点とビーコン間の伝送距離に応じて 22 セットに分けた。距離は 0.75 m から $1 1 . 2 5 \mathrm { m }$ までで、間隔は $0 . 5 \mathrm { m }$ である。異なる伝送距離における標準偏差分布を図 5 に示す。$\sigma _ { 1 }$ と $\sigma _ { 2 }$ を求めるため、各データセット内の標準偏差を期待値最大化法 [22] により 2 クラスタに分離した。2 つの分布に対する各データ点の確率を計算し、低 SD 分布に対する確率が高いデータ点数の全データ点数に対する比を重み $\phi _ { 1 }$ とする。たとえば、伝送距離 2 m のデータセットのクラスタリング結果を図 6 に示す。これにより、$l$ 番目データセットにおける第 1・第 2 ガウス分布の SD である $\sigma _ { 1 , l }$、$\sigma _ { 2 , l }$ を得る。$\sigma _ { 1 }$ と $\sigma _ { 2 }$ は、それぞれ $\sigma _ { 1 , l }$ と $\sigma _ { 2 , l }$ の平均として計算する。ここで $l = 1 , . . . , L$、$L=22$ である。重み $\phi _ { 1 } ( d )$ は、式 (4) の線形独立関数と仮定する。$\phi _ { 1 } ( d )$ と第 1 ガウス分布の重みとの二乗誤差和は式 (5) で与えられる。ここで $d _ { l }$ は $l$ 番目データセットに対応する伝送距離、$\phi _ { 1 , l }$ は第 1 ガウス分布の重みである。さらに式 (5) を式 (6)、(7) に書き換え、二乗誤差和を最小にする最適な $\hat { \alpha }$ を式 (8) で計算する。

![](images/f2b184aef901d258301384089aac3ca4b2556bca4ffff1a93e3678fc005b0ee4.jpg)  
図 6. RSS 測定標準偏差に対する GMM。

![](images/84ec0b3dfbc540cf9890f0104068aeb37d6e3f61d90090c5ed24a77899ff784f.jpg)  
図 7. 第 1 ガウス分布の重みと重み関数。

$$
\begin{array} { c c } { { \displaystyle \phi _ { 1 } ( d ) = a _ { 0 } + a _ { 1 } d + a _ { 2 } d ^ { 2 } } } & { { ( 4 ) } } \\ { { { \displaystyle \sum _ { l = 1 } ^ { L } \varepsilon _ { k } = \sum _ { l = 1 } ^ { L } [ \phi _ { 1 , l } - \phi _ { 1 } \left( d _ { l } \right) ] ^ { 2 } } } } & { { ( 5 ) } } \\ { { \varphi _ { 1 } = { \bf D } \alpha + \varepsilon } } & { { ( 6 ) } } \\ { { \varphi _ { 1 } = { \left[ \begin{array} { l } { { \phi _ { 1 , 1 } } } \\ { { \vdots } } \\ { { \phi _ { 1 , L } } } \end{array} \right] } { \bf D } = { \left[ \begin{array} { l l l } { { 1 } } & { { d _ { 1 } } } & { { d _ { 1 } ^ { 2 } } } \\ { { \vdots } } & { { \ddots } } & { { \vdots } } \\ { { 1 } } & { { d _ { L } } } & { { d _ { L } ^ { 2 } } } \end{array} \right] } \alpha = { \left[ \begin{array} { l } { { a _ { 0 } } } \\ { { a _ { 1 } } } \\ { { a _ { 2 } } } \end{array} \right] } \varepsilon = { \left[ \begin{array} { l } { { \varepsilon _ { 1 } } } \\ { { \vdots } } \\ { { \varepsilon _ { L } } } \end{array} \right] } } } \end{array}
$$

$$
\begin{array} { r } { \hat { \alpha } = \left( \mathbf { D } ^ { \mathbf { T } } \mathbf { D } \right) ^ { - 1 } \mathbf { D } ^ { \mathbf { T } } \varphi _ { 1 } . } \end{array}
$$

図 7 は、各データセットにおける第 1 ガウス分布の重みと $\phi _ { 1 } ( d )$ による推定値を示す。$\phi _ { 1 } ( d )$ は減少関数であり、伝送距離が短いほど RSS 測定分布がより集中していることを表している。図 8 は、3 つの異なる伝送距離における RSS 測定分布と推定分布を示す。推定分布は実際の RSS 測定分布によく一致している。

# B. シャドーイングモデル

信号が急激に減衰する主因は、障害物による遮蔽効果である。そこで、遮蔽の影響を緩和するため、位置推定空間における異常信号減衰を写像するシャドーイングモデルを構築する。まず、壁や大型家具などの障害物を無線信号が通過するときに異常信号減衰が発生すると仮定する。障害物配置は、ロボットが LRF で取得した位置推定エリア地図から得られる。しかし、図 9(a) に示す元の地図から障害物の正確な位置を直接決めるのは難しい。これは、1) LRF が障害物表面しか検出できないこと、2) 他の障害物の背後にある表面を検出できないことに起因する。そのため、完全な障害物形状を持つ地図を得るために、画像二値化、膨張、収縮、穴埋めアルゴリズム [23] を含む画像処理手法を適用する。処理後の地図を図 9(b) に示す。さらに、計算コスト削減のため、地図を $I \times J$ のグリッド地図に分割する。各グリッドは $M \times N$ 画素を持ち、信号がそのグリッドを通過した際の異常信号減衰を表すシャドーイング値 $s _ { i , j }$ を持つ。位置推定空間全体のシャドーイング値は、式 (9)、(10) の $( I * J ) \times 1$ ベクトルとして表される。ここで、$H _ { \mathrm { s } }$ はグリッドに障害物があるかを判定する閾値であり、$h ( m , n )$ はグリッド内画素のグレースケール値、$0 { \not - } 4 ~ \mathrm { d B m }$ は各グリッドのシャドーイング値の上限で、[24] によれば一般的な屋内障害物による電力減衰の通常範囲を表す。位置推定空間のシャドーイングモデルを構築した後、$\mathbf { p } _ { b }$ にあるビーコンから $\mathbf { p } _ { t }$ にあるターゲットまでのリンクの異常信号減衰は、リンクが通過するグリッドのシャドーイング値を加算して求める。さらに [25] に基づき、無線信号リンクの形状は楕円で近似できる。通過グリッドは式 (11)、(12) で決定される。ここで、$w _ { \mathrm { e l l i p s e } }$ はリンク楕円の幅、$\mathbf { p } _ { g _ { i } , j }$ はグリッド $g _ { i , j }$ の中心位置である。最後に、$\mathbf { p } _ { b }$ のビーコンと $\mathbf { p } _ { t }$ のターゲット間の総異常信号減衰を式 (13) で計算する。図 10 はリンクの総異常電力減衰計算例を示す。

$$
\mathbf { S } = [ s _ { 1 , 1 } , s _ { 1 , 2 } , \ldots , s _ { 1 , J } , s _ { 2 , 1 } , \ldots , s _ { I , J - 1 } , s _ { I , J } ] ^ { \mathrm { T } }
$$

$$
\begin{array} { r l } & { \qquad s _ { i , j } = \left\{ \begin{array} { l l } { 0 - 4 , } & { \sum _ { m = 1 } ^ { M } \sum _ { n = 1 } ^ { N } h \left( m , n \right) \geq H _ { S } } \\ { 0 , } & { \mathrm { e l s e } } \end{array} \right. } \\ & { \qquad u _ { i , j } \left( \mathbf { p } _ { t } , \mathbf { p } _ { b } \right) = \left\{ \begin{array} { l l } { 1 , } & { \left| \mathbf { p } _ { t } - \mathbf { p } _ { g _ { i , j } } \right| + \left| \mathbf { p } _ { b } - \mathbf { p } _ { g _ { i , j } } \right| } \\ { ~ < \left| \mathbf { p } _ { t } - \mathbf { p } _ { b } \right| + w _ { \mathrm { e l l i p s e } } } \end{array} \right. } \\ & { \qquad \mathbf { U } ( \mathbf { p } _ { t } , \mathbf { p } _ { b } ) = \left[ u _ { 1 , 1 } \dots u _ { I , J } \right] } \\ & { \qquad S ( \mathbf { p } _ { t } , \mathbf { p } _ { b } ) = \mathbf { U } ( \mathbf { p } _ { t } , \mathbf { p } _ { b } ) \mathbf { S } . } \end{array}
$$

# C. フィッティングパスロスモデル

一般に、RSS と距離の関係を表す最も一般的なモデルは対数距離パスロスモデルである。しかし、屋内環境が複雑な場合、このモデルの単純な指数形状が実際の信号伝搬と一致しないことがあり、距離推定が不正確になる可能性がある。そこで本論文では、実際の信号パスロスを表現するためにフィッティングパスロスモデルを提案する。このモデルは複数の独立な基本関数から構成され、その係数は、モデルと実際の RSS 測定値の誤差を最小にする最適化手法によって決定される。最適な近似曲線を見つけるため、4 種類の曲線関数を用意する。すなわち、線形独立関数（F1）、非線形関数（F2）、および異なるパラメータを持つ 2 種類の対数距離パスロスモデル関数（F3, F4）である。関数の詳細を表 I に示す。F1 の最適パラメータは最小二乗方程式を解くことで求める。F2、F3、F4 は非線形関数で閉形式解を持たないため、最急降下単体法（amoeba アルゴリズム）を用いて最適パラメータを求める。F3 では、$d _ { o }$、$V _ { d _ { o } }$、$n$ を最適化で求める。F4 では $d _ { o }$ と $V _ { d _ { o } }$ は既知とし、$n$ のみを求める。このアルゴリズムは、幾何学的関係に基づいて高次元空間内で点の単体を移動させ、関数最小値を探索する [26]。

![](images/852d70917bd90a213d38d5c7e559809a92056a3f02dc80ba9c94336a13b6bc11.jpg)  
図 8. RSS 測定値ヒストグラムと推定分布。推定分布は $\phi _ { 1 } ( d ) \pmb { \mathscr { N } } ( V , \sigma _ { 1 } ^ { 2 } ) +$ $\phi _ { 2 } \left( d \right) \mathcal { N } ( V , \sigma _ { 2 } ^ { 2 } )$ で表される。ここで、$d$ は伝送距離（m）、$V$ は平均 RSS（dBm）である。(a) $d = 2 . 2 4$、$V = - 5 3 . 3 1$。(b) $d = 5 . 1 3$、$V = - 6 1 . 0 4 5 9$。(c) $d = 1 0 . 3 2$、$V = - 6 3 . 3 0 9 7$。

![](images/210707c48cfa5fdc7c50cf4fe0cbbfde74d95aab0e26c631bdb68a505a68711f.jpg)  
図 9. 位置推定エリアの 2 次元地図。(a) 元地図。(b) 画像処理後地図。

![](images/f44b09927aca83c550d4870455a285261a293592cd69792f559898cdba8ba686.jpg)

図 10. 2 つの青い星の間の異常信号減衰は 11。

<table><tr><td>表 I フィッティング曲線関数</td></tr><tr><td>関数 1 V(d) = b + d + b2d2</td></tr><tr><td>関数 2 VF(d) = ced + c2e2d</td></tr><tr><td>関数 3 VF (d) = Vd0 − n10g(d/d0 )</td></tr><tr><td>関数 4 VF (d) = Vd − n1og(d/d0 ), d0 =1</td></tr></table>

![](images/a25644545dced98eed74ef992c2df798d59ec94d3a1219c80339fcb3e4d56082.jpg)  
図 11. フィッティング曲線の比較。

![](images/871e9b28daea2e894f6017c40611b6c17ee93a6bd43259c561313fb9212511a9.jpg)  
図 12. フィッティング関数による RSS 推定値と RSS 測定値の平均誤差。

表 II フィッティング関数の平均誤差

<table><tr><td></td><td>F1</td><td>F2</td><td>F3</td><td>F4</td></tr><tr><td>平均誤差 (dBm)</td><td>4.41</td><td>4.40</td><td>4.54</td><td>4.68</td></tr></table>

どの曲線関数が最も適切かを決めるため、12 個のビーコンから 500 箇所のサンプル位置で RSS 測定データを記録し、そのデータから 4 つのフィッティング関数のパラメータを求めた。図 11 は、そのうち 1 個のビーコンに対する RSS 測定データに基づく 4 関数のフィッティング曲線を示している。対数距離パスロスモデルである F3、F4 の曲線は、他の 2 関数とは明らかに異なっている。図 12 は、12 個のビーコンについて、フィッティング関数による RSS 推定値と RSS 測定値の誤差を示している。F1 と F2 は F3、F4 より誤差が小さく、2 つの非指数関数の方が実際の RSS 測定に適していることを示している。表 II によれば、最も誤差の小さい F2 を本論文のフィッティングパスロスモデルとして採用する。

最後に、ASMF データベース内の信号フィンガープリントは、フェージングモデル、シャドーイングモデル、フィッティングパスロスモデル、およびビーコン位置に基づく確率密度関数（PDF）として定式化される。特定位置 $\mathbf { p }$ に対応する信号フィンガープリントは式 (14)、(15) で計算される。ここで、$\mathbf { p } _ { b , k }$ は $k$ 番目ビーコン位置、$N _ { \mathrm { B } }$ はビーコン数、$d = \| \mathbf p - \mathbf p _ { b , k } \|$、$V = V _ { F } ( d ) - S ( \mathbf { p } , \mathbf { p } _ { b , k } )$ である。

$$
\mathbf { V } _ { \mathrm { f i n g e r p r i n t } } ( \mathbf { p } ) = \{ V _ { \mathrm { p d f } } ( \mathbf { p } , \mathbf { p } _ { b , 1 } ) , \dots , V _ { \mathrm { p d f } } ( \mathbf { p } , \mathbf { p } _ { b , N _ { B } } ) \}
$$

$$
V _ { \mathrm { p d f } } ( \mathbf { p } , \mathbf { p } _ { b , k } ) \sim \phi _ { 1 } ( d ) \pmb { \mathcal { N } } ( V , \sigma _ { 1 } ^ { 2 } ) + \phi _ { 2 } ( d ) \pmb { \mathcal { N } } ( V , \sigma _ { 2 } ^ { 2 } ) .
$$

# IV. ASMF の動的データベースと位置推定

本章では、ASMF ベース ILS におけるデータベース更新と物体位置推定の流れを説明する。更新処理には、環境変化認識、移動したビーコン位置の推定、シャドーイングモデルの最適化が含まれる。

# A. 環境変化認識

環境変化認識では、ビーコン変動と障害物変動の 2 つの状況を仮定する。ビーコン移動時には、移動したビーコン位置を再推定し、シャドーイングモデルも再最適化する。もう一方の状況では、シャドーイングモデルのみを再最適化する。環境変化認識は、ロボットが収集した RSS 測定データと ASMF データベース中のフィンガープリントとの類似度比較に基づく。この類似度は、次式のように、ASMF データベース中のフィンガープリントが与えられたときの RSS 測定値の条件付き確率として決定される。

$$
\begin{array} { l } { { \displaystyle P ( V _ { \mathrm { r o b o t } , t } | V _ { \mathrm { f i n g e r p r i n t } } ( \mathbf { p } _ { \mathrm { r o b o t } , t } ) ) , t = 1 , . . . , T _ { \mathrm { T } } } } \\ { { \displaystyle P ( V _ { \mathrm { r o b o t } , t } | V _ { \mathrm { f i n g e r p r i n t } } ( \mathbf { p } _ { \mathrm { r o b o t } , t } ) ) } } \\ { { \displaystyle N _ { B } } } \\ { { \displaystyle = \prod _ { k = 1 } P ( V _ { \mathrm { r o b o t } , t } | V _ { \mathrm { p d f } } ( \mathbf { p } _ { \mathrm { r o b o t } , t } , \mathbf { p } _ { b , k } ) ) } } \end{array}
$$

ここで、$V _ { \mathrm { r o b o t } , t }$ は位置 $\mathbf { p } _ { \mathrm { r o b o t } , t }$ における RSS 測定平均値、$T _ { \mathrm { T } }$ は 1 回の巡回における測定点数である。式 (16) は、全ビーコンに対応するフィンガープリントが与えられたときの RSS 測定平均値の確率の積として、式 (17)、(18) に書き換えられる。ここで、$d _ { t , k }$ は $t$ 番目測定点と $k$ 番目ビーコンの距離、$V$ は式 (19) により計算される推定 RSS、$f ( V _ { \mathrm { r o b o t } , t } | V , \sigma _ { 1 } ^ { 2 } )$ および $f ( V _ { \mathrm { r o b o t } , t } | V , \sigma _ { 2 } ^ { 2 } )$ はそれぞれ式 (20)、(21) の正規分布である。

$$
\begin{array} { r l r } {  { P ( V _ { \mathrm { r o b o t } , t } | V _ { \mathrm { p d f } } ( \mathbf { p } _ { \mathrm { r o b o t } , t } , \mathbf { p } _ { b , k } ) ) } } \\ & { } & { = \phi _ { 1 } ( d _ { t , k } ) f ( V _ { \mathrm { r o b o t } , t } | V , \sigma _ { 1 } ^ { 2 } ) + \phi _ { 2 } ( d _ { t , k } ) f ( V _ { \mathrm { r o b o t } , t } | V , \sigma _ { 2 } ^ { 2 } ) } \\ & { } & { ( 1 , \cdot } \\ & { V = V _ { F } ( d _ { t , k } ) - S ( \mathbf { p } _ { \mathrm { r o b o t } , t } , \mathbf { p } _ { b , k } ) } & { ( 1 , \cdot } \\ & { } & { f ( V _ { \mathrm { r o b o t } , t } | V , \sigma _ { 1 } ^ { 2 } ) = \frac { 1 } { \sqrt { 2 \sigma _ { 1 } ^ { 2 } \pi } } e ^ { - \frac { ( V _ { \mathrm { r o b o t } , t } - V ) ^ { 2 } } { 2 \sigma _ { 1 } ^ { 2 } } } } & { ( 2 } \\ & { } & { f ( V _ { \mathrm { r o b o t } , t } | V , \sigma _ { 2 } ^ { 2 } ) = \frac { 1 } { \sqrt { 2 \sigma _ { 2 } ^ { 2 } \pi } } e ^ { - \frac { ( V _ { \mathrm { r o b o t } , t } - V ) ^ { 2 } } { 2 \sigma _ { 2 } ^ { 2 } } } . } \end{array}
$$

$P ( V _ { \mathrm { r o b o t } , t } | V _ { \mathrm { p d f } } ( \mathbf { p } _ { \mathrm { r o b o t } , t } , \mathbf { p } _ { b , k } ) )$ は、$k$ 番目ビーコンが移動している場合に低くなる。そのため、ビーコン再推定の要否は式 (22) で判定できる。ここで $H _ { 1 }$ は閾値である。最後に、障害物移動時には、式 (23) を満たす RSS 測定値のみを新しいシャドーイングモデル最適化に用いる。ここで $H _ { 2 }$ は閾値である。$H _ { 1 }$ と $H _ { 2 }$ は、フェージングモデルで得られる $\phi _ { 1 } ( d )$ と標準偏差に依存する調整可能パラメータである。たとえば、位置推定環境が複雑で RSS 分布の標準偏差が大きい場合、データベース更新頻度が過剰にならないよう $H _ { 2 }$ を低めに設定できる。ただし、$H _ { 2 }$ を低くすると、ILS がターゲットを誤った RP に位置付ける機会も増える。つまり、データベース更新頻度と位置推定精度のトレードオフである。一方、ビーコンの移動は RSS 測定値とデータベースの差を非常に大きくするため、$H _ { 1 }$ は通常低い値に設定できる。

$$
\begin{array} { r l } & { \displaystyle \frac { 1 } { T _ { \mathrm { T } } } \sum _ { t = 1 } ^ { T _ { \mathrm { T } } } P ( V _ { \mathrm { r o b o t } , t } | V _ { \mathrm { p d f } } ( \mathbf { p } _ { \mathrm { r o b o t } , t } , \mathbf { p } _ { b , k } ) ) < H _ { 1 } } \\ & { P ( V _ { \mathrm { r o b o t } , t } | V _ { \mathrm { f n g e r p r i n t } } ( \mathbf { p } _ { \mathrm { r o b o t } , t } ) ) < H _ { 2 } . } \end{array}
$$

# B. 移動したビーコンとターゲットの位置推定

パーティクルフィルタは、多峰性 PDF を扱う信号処理アルゴリズムとして有用である。さらに、カーネル密度推定（KDE）により事後 PDF を近似する kernel particle filter（KPF）[27], [28] は、元の粒子を置き換える代わりに mean shift アルゴリズム [29] で粒子状態を更新するため、粒子配置により効果的である。ASMF ベース位置推定では、移動したビーコン位置だけでなくターゲット位置の推定にも KPF を用いる。システムには、ターゲット用と移動ビーコン用の 2 つの KPF がある。まず、位置推定対象の状態を $\mathbf { \Delta } _ { \mathbf { \mathcal { X } } _ { t } }$、観測を $\mathbf { Z } _ { t } = \{ V _ { 1 } , . . . , V _ { t } \}$、対象の粒子を $\mathbf { x } _ { t } ^ { ( m ) }$ とし、KPF で用いる粒子数を $N _ { p }$ とする。ターゲットおよび移動ビーコンの運動モデルは、ともにランダムウォークモデル [30] を仮定する。ターゲットの最大速度は $1 . 5 ~ \mathrm { m / s }$、移動ビーコンの最大速度は 0.6 $\mathrm { m } / \mathrm { s }$ である。次に、対象の事後密度は式 (24) の KDE により推定される。ここで $w _ { t } ^ { ( m ) }$ は粒子 $\mathbf { x } _ { t } ^ { ( m ) }$ に対応する重みであり、帯域幅 $\kappa$ は事後密度とカーネル密度の積分平均二乗誤差を最小にするよう選ぶ。mean shift は各粒子の勾配を計算し、式 (25) で定式化される標本平均方向へ粒子を移動させる。最後に、mean shift 後の新粒子 ${ \bf x } _ { t } ^ { \prime ( m ) }$ の重みを再配分する必要がある。

$$
\hat { p } ( \pmb { x } _ { t } | \pmb { Z } _ { t } ) = \sum _ { m = 1 } ^ { N _ { P } } K _ { \kappa } ( \pmb { x } _ { t } - \mathbf { x } _ { t } ^ { ( m ) } ) w _ { t } ^ { ( m ) }
$$

$$
m ( \mathbf { x } _ { t } ^ { ( m ) } ) = \frac { \sum _ { m ^ { \prime } = 1 } ^ { N _ { p } } H _ { \kappa } ( \mathbf { x } _ { t } ^ { ( m ) } - \mathbf { x } _ { t } ^ { ( m \prime ) } ) w _ { t } ^ { ( m \prime ) } \mathbf { x } _ { t } ^ { ( m \prime ) } } { \sum _ { m ^ { \prime } = 1 } ^ { N _ { p } } H _ { \kappa } ( \mathbf { x } _ { t } ^ { ( m ) } - \mathbf { x } _ { t } ^ { ( m \prime ) } ) w _ { t } ^ { ( m \prime ) } } .
$$

# C. シャドーイングモデル最適化

更新地図において障害物を持つグリッドは、式 (26) の対角行列として表現できる。2 点間の異常信号減衰は、式 (27) のように、推定 RSS から測定 RSS を引くことで計算される。ここで、$V _ { F } ( d _ { t , k } )$ は $k$ 番目ビーコンから位置 $\mathbf { p } _ { \mathrm { r o b o t } , t }$ までの異常信号減衰を無視した推定 RSS であり、フィッティングパスロスモデルにより計算される。測定位置とビーコンを結ぶリンクの総異常信号減衰は、式 (28) の $\in \Re ^ { ( N _ { B } * T _ { T } ) \times 1 }$ ベクトルとして表される。一方、シャドーイングモデルにより計算される推定異常信号減衰は式 (29) で表される。$\mathbf { S } ^ { \prime }$ と $\hat { \bf S }$ の誤差を最小化する最適な $\mathbf { S } _ { \mathrm { o p t i m a l } }$ を求めるシャドーイングモデル最適化は、制約付き線形最小二乗問題とみなせ、式 (30) の閉形式解を持つ。

さらに、障害物移動時の更新処理における計算時間を削減するため、シャドーイングモデル最適化には式 (23) を満たすデータの一部のみを用いる。$\mathbf S$ と $A$ は、確定部分と不確定部分の 2 部分に分けられる。不確定部分に含まれるグリッドは、式 (23) を満たす RSS 測定リンクが通過するグリッドである。そこで、シャドーイングモデルを $[ \mathbf { S } _ { 1 } \mathbf { \bar { S } } _ { 2 } ] ^ { T }$ に分割し、対応する $A$ 行列を $\left[ A _ { 1 } \ A _ { 2 } \right]$ に分割する。このとき調整が必要なのは $\mathbf { S } _ { 2 }$ のシャドーイング値のみである。すると、式 (30) は式 (31) に書き換えられる。ここで ${ \cal A } _ { 1 } \mathbf { S } _ { 1 }$ は定数ベクトル $\mathbf { C }$ とみなせ、$\mathbf { S } ^ { \prime \prime }$ は $\mathbf { S } ^ { \prime }$ の部分ベクトルである。

$$
\mathbf { Q } = \left[ \begin{array} { c c c c } { q _ { 1 , 1 } } & { 0 } & { \cdots } & { 0 } \\ { 0 } & { q _ { 1 , 2 } } & & { \vdots } \\ { \vdots } & & { \ddots } & { 0 } \\ { 0 } & { \cdots } & { 0 } & { q _ { I , J } } \end{array} \right] ,
$$

$$
\left\{ \begin{array} { l l } { q _ { i , j } = 1 , } & { \mathrm { t h e ~ g r i d ~ \mathrm { { g } } } _ { i , j } \mathrm { { \ h a s ~ o b s t a c l e s } } } \\ { q _ { i , j } = 0 , } & { \mathrm { o t h e r w i s e } } \end{array} \right.
$$

$$
S ^ { \prime } ( { p } _ { \mathrm { r o b o t } , t } , { \bf p } _ { b , k } ) = V _ { F } ( d _ { t , k } ) - V _ { \mathrm { r o b o t } , t }
$$

$$
\mathbf { S } ^ { \prime } = \left[ S ^ { \prime } ( p _ { \mathrm { r o b o t , 1 } } , \mathbf { p } _ { b , 1 } ) , . . . , S ^ { \prime } ( p _ { \mathrm { r o b o t } , T _ { T } } , \mathbf { p } _ { b , N _ { B } } ) \right] ^ { T }
$$

$$
\hat { \mathbf { S } } = \left[ \begin{array} { c } { \mathbf { U } ( p _ { \mathrm { r o b o t } , 1 } , \mathbf { p } _ { b , 1 } ) } \\ { \vdots } \\ { \mathbf { U } ( p _ { \mathrm { r o b o t } , T _ { T } } , \mathbf { p } _ { b , N _ { B } } ) } \end{array} \right] \mathbf { Q } \left[ \begin{array} { c } { s _ { 1 , 1 } } \\ { \vdots } \\ { s _ { I , J } } \end{array} \right] = A \mathbf { S }
$$

$$
\mathbf { S } _ { \mathrm { o p t i m a l } } = \arg \operatorname* { m i n } _ { S } \frac { 1 } { 2 } \left\| \mathbf { S } ^ { \prime } - \hat { \mathbf { S } } \right\| _ { 2 } ^ { 2 } , \quad 0 \leq s _ { i , j } \leq 4
$$

$$
\mathbf { S } _ { 2 , \mathrm { o p t i m a l } } = \arg \operatorname* { m i n } _ { \mathbf { S } _ { 2 } } \frac { 1 } { 2 } \left\| \mathbf { S } ^ { \prime \prime } - A _ { 2 } \mathbf { S } _ { 2 } - \mathbf { C } \right\| _ { 2 } ^ { 2 } , \quad 0 \leq s _ { i , j } \leq 4 .
$$

# V. 実機実験

# A. 実験設定

実験に用いた屋内環境は、$1 4 \times 1 0 . 5 \ : \mathrm { m } ^ { 2 }$ の研究室であり、間仕切りを含む空間である。研究室の様子を図 13 に示す。ロボットの速度は $0 . 3 ~ \mathrm { m / s }$、LRF の検出範囲は 0.2 m から $4 \textrm { m }$ である。ロボットの自己位置推定誤差の平均はおよそ $0 . 1 \textrm { m }$ である。ZigBee ボードを図 14 に示す。研究室内には、参照ビーコンとして 12 枚の ZigBee ボードを配置した。研究室の平面レイアウトを図 17 に示す。ビーコンと RP の配置を図 18 に示す。緑の十字はビーコン位置、赤い円は RP を表す。RP は合計 531 点ある。オンライン段階では、図 15 に示す ZigBee ボードを持った人物をターゲットとし、ロボットは事前計画された巡回軌道に沿って移動する。ロボットの巡回軌道を図 19 に示す。軌道上には 145 個の測定点があり、各測定点でロボットは $2 \mathrm { ~ s ~ }$ 停止して RSS 測定データを収集する。

![](images/67d45cec9b6d9dda6cdbd80bb9096331be71bcfa1f542ef4687d38d1c7e10d82.jpg)  
図 13. 実験環境の外観。

![](images/a5717d54dba079f5f623c9eb194bd3b180bf1befa69f89ded504809a5ffcc966.jpg)  
図 14. ZigBee ボード。

![](images/f51a3464023501a860ab2b8d001617d338236f2b92efbf54710ea8ab39a9d815.jpg)  
図 15. ZigBee ボードを携行する人物。

![](images/a8843c5d8abfe3b3e7172fede9d4d915a5b5acbe7e046eff7ac7ab1a693122bc.jpg)  
図 16. 実験 2 で用いたキャビネットと机。

![](images/ebba8e926807a264eac4114471f6127d826d9f9cb55287e87a0e2e90620925e5.jpg)  
図 17. ロボットが作成した床面レイアウト。

![](images/9903877016eb6a520bb9db55807ec1fa91819d31699298f63c1c3accd95efb00.jpg)  
図 18. ビーコンと RP の配置。

![](images/1c6b63e02a3de1706df0183b1919c290833702c2134ff394acf471f8ed15fd2f.jpg)  
図 19. オンライン段階におけるロボットの巡回軌道。

ロボットの巡回軌道は、2 つの重要点、すなわち、環境内でターゲットが移動し得る領域に対する総マッピング被覆率の最大化と、実験環境内障害物との衝突回避に基づいて計画される。巡回軌道は、位置推定システムの精度維持に十分な RSS データを収集できるよう、ターゲット人物の移動軌跡をカバーする目的で設計される。実験では、巡回軌道の被覆は位置推定領域全体を完全には覆わない。そのため、ロボットが通らない場所のシャドーイング値は、シャドーイングモデル最適化で考慮されない。ロボット軌道の被覆が大きいほどデータベース更新により完全なデータを与えられるが、その代償として更新間隔も長くなる。衝突回避のため、実験であらかじめ配置された障害物位置を巡回軌道計画に反映し、ロボットがそれらとの衝突を避けられるようにしている。しかし、通常、環境内の人は予測不可能であり、ロボットを妨げることがある。この遮断問題に対して、2 つの反応を提案する。測定点間で遮断が起きた場合、ロボットは人を回避する。この場合、システムへの影響はほとんどない。一方、測定点上で遮断が起きた場合、ロボットは人が離れるまで停止して待機する。これにより巡回時間が増加し、データベース更新時間の増加につながる可能性がある。

実験は、ASMF、三辺測量法、KNNF に基づく ILS の性能解析を目的として実施した。ASMF ベースおよび三辺測量ベース ILS では初期ビーコン位置は既知とした。ASMF および KNNF の初期データベースは、オフライン段階で収集した RSS 測定データに基づいて構築した。実験では、位置推定領域内を任意に移動する非ターゲット人物を最大 3 人まで許可した。ただし、ターゲット人物およびロボットと衝突しないことを条件とする。異なる状況で 4 つの実験を行った。実験 1 では、オフライン段階と同じ環境でターゲット位置を推定する。実験 2 と 3 では、環境変化後にターゲットを位置推定する。実験 2 では、図 16 に示す追加のキャビネットと机を実験空間に配置した。変化後の研究室の新しい 2 次元地図を図 20 に示す。実験 3 では、図 21 に示すように 2 個のビーコン位置を変更した。実験 4 では、移動ターゲットを継続的に位置推定する。ターゲットの軌跡は図 22 に示すように事前計画した。実験 4 では、実際の移動位置を得るため、ロボット自身をターゲットとして用いた。

![](images/ed48255eacbbdfcae4940432d8e8bf0cfe959fede3fa8f21a45e10c2e5a1a960.jpg)  
図 20. 障害物変化後の床面レイアウト。

![](images/84c918cc3d51d0d493ed6dfd8d195e7e69b0e2158291ad7396d26ed43fdf8ad3.jpg)  
図 21. 実験 3 における 2 個のビーコン位置変更。

![](images/3b4f87fdf9acff876f7079a73058c41ea945acaadccfd18cba7e5253e77c52e9.jpg)  
図 22. 実験 4 における人物の移動軌跡。

![](images/ca9edd0f16dee2ad9c5eddc6f5501a61d99384eee1457e8e0ccf29ae33d69c13.jpg)  
図 23. 実験 1 における位置推定結果。

![](images/b70f1a0d2f755df4a234ffbcd3c03caa2b34b2ea183dd2bf7a464ee2fa4dd69d.jpg)  
図 24. 実験 1 における累積位置推定誤差。

表 III 位置推定結果の比較

<table><tr><td rowspan=2 colspan=1></td><td rowspan=1 colspan=2>実験 1</td><td rowspan=1 colspan=2>実験 2</td><td rowspan=1 colspan=2>実験 3</td></tr><tr><td rowspan=1 colspan=1>平均誤差 (m)</td><td rowspan=1 colspan=1>SD (m)</td><td rowspan=1 colspan=1>平均誤差 (m)</td><td rowspan=1 colspan=1>SD (m)</td><td rowspan=1 colspan=1>平均誤差 (m)</td><td rowspan=1 colspan=1>SD (m)</td></tr><tr><td rowspan=1 colspan=1>Trilateration</td><td rowspan=1 colspan=1>1.726</td><td rowspan=1 colspan=1>1.237</td><td rowspan=1 colspan=1>1.727</td><td rowspan=1 colspan=1>1.464</td><td rowspan=1 colspan=1>1.683</td><td rowspan=1 colspan=1>1.234</td></tr><tr><td rowspan=1 colspan=1>KNNF</td><td rowspan=1 colspan=1>0.939</td><td rowspan=1 colspan=1>0.550</td><td rowspan=1 colspan=1>1.281</td><td rowspan=1 colspan=1>1.259</td><td rowspan=1 colspan=1>1.975</td><td rowspan=1 colspan=1>1.373</td></tr><tr><td rowspan=1 colspan=1>ASMF1</td><td rowspan=1 colspan=1>0.712</td><td rowspan=1 colspan=1>0.426</td><td rowspan=1 colspan=1>1.007</td><td rowspan=1 colspan=1>0.600</td><td rowspan=1 colspan=1>1.621</td><td rowspan=1 colspan=1>0.888</td></tr><tr><td rowspan=1 colspan=1>ASMF2</td><td rowspan=1 colspan=1></td><td rowspan=1 colspan=1></td><td rowspan=1 colspan=1>0.763</td><td rowspan=1 colspan=1>0.562</td><td rowspan=1 colspan=1>0.840</td><td rowspan=1 colspan=1>0.586</td></tr></table>

# B. 性能評価

![](images/da298fdde686b620a8e9000bbbb6bac8f07a36135563a3d9bde004cca6af50ed.jpg)  
図 25. 実験 2 における位置推定結果。

1) 静的環境における位置推定性能: 実験 1 では、20 箇所でターゲット位置を推定した。図 23 に 3 つの位置推定手法の結果を示す。図 24 は累積位置推定誤差を示し、詳細な平均誤差と標準偏差は表 III に示す。結果によると、ASMF は静的環境実験で最も高い精度を示し、三辺測量法および KNNF と比較して、それぞれ $5 8 . 8 \%$、$2 4 . 2 \%$ の誤差低減を達成した。信頼できるデータベースが事前に構築されていれば、KNNF と ASMF のようなフィンガープリンティング手法が三辺測量法より高精度であることは明らかである。

KNNF と ASMF を比較すると、ASMF の方が優れている。RSS 測定値から直接計算した信号フィンガープリントは外れ値の影響を受けやすい。一方、ASMF によるモデルベースのフィンガープリントデータベースは、元の RSS 測定値から直接構築されるデータベースよりも、より完全な信号フィンガープリントを提供する。

![](images/8b340b708edd77414ac82db3aa8cdc754b4972c21936246c6c9fbeb6aea1bd58.jpg)  
図 26. 実験 2 における累積位置推定誤差。

さらに、フェージングモデルにおける重み関数 $\phi _ { 1 } \left( d \right)$ も、高い RSS を持ち、通常ターゲットに近く信号干渉を受けにくいビーコンからの測定に高い信頼度を与える主要因である。

2) 動的環境における位置推定性能: 動的環境実験では、障害物が変化した場合とビーコンが移動した場合の各手法の位置推定結果を解析する。また、ASMF のデータベース更新効果についても検討する。ASMF 1 は初期データベースに基づく位置推定、ASMF 2 は更新データベースに基づく位置推定を表す。障害物変化ケースである実験 2 では、更新データベースを用いた ASMF が最良の性能を示した。図 25 に各手法の位置推定結果を、図 26 に Trilateration、KNNF、ASMF 1、ASMF 2 の累積位置推定誤差を示す。実験結果より、障害物変化は実際に位置推定精度を低下させることが分かる。フィンガープリンティング手法では誤差増加がより大きい。しかし、データベース更新を行わなくても、ASMF は依然として三辺測量法や KNNF より高い精度を保っている。ASMF2 の誤差は実験 1 とほぼ同程度である。これは、自律ロボットが収集した RSS 測定値だけを用いて ASMF データベースを迅速に補正でき、ASMF ベース ILS が位置推定空間内の障害物変化に対してより頑健であることを示している。図 27、28 では、未更新データベースと更新データベースにおけるシャドーイングモデルを比較している。黒丸は障害物を含むグリッド、色付き四角は非ゼロのシャドーイング値を持つグリッドであり、色の違いはグリッドのシャドーイング値範囲の違いを表す。

実験 3 では、2 個のビーコン位置を変更した。更新データベースを用いた ASMF は、依然として最良の性能を示した。図 29 は、KPF によって推定された 2 個の移動ビーコンの新しい位置を示しており、それぞれの位置推定誤差は 1.11 m と $0 . 4 1 \mathrm { ~ m ~ }$ であった。図 30 は実験 3 の位置推定結果、図 31 は Trilateration、KNNF、ASMF 1、ASMF 2 の累積位置推定誤差を示す。まず、誤ったビーコン位置を用いた三辺測量法の平均誤差は $3 . 6 4 – \mathrm { m }$ と大きすぎて実用的ではない。三辺測量法で用いた移動後ビーコン位置は、更新 ASMF データベースで推定された位置と同一である。このとき三辺測量法の誤差は、前述の実験結果に最も近い値となった。

![](images/a1abe726015c5dba7b32f759b9ec3fe7f5ad2c38f52ac3f7ab5eacc4afb5bbc5.jpg)  
図 27. 初期データベースにおけるシャドーイングモデル。

![](images/381dbf270b4ad9f25e6905a78d6031a06eb17c27bd56d2a6369da01efc7ac0ed.jpg)  
図 28. 更新データベースにおける新しいシャドーイングモデル。

![](images/79afaa7dc6c343b653bc20ea01947c47619e2614f01f88954e69760aee3d3c39.jpg)  
図 29. 2 個の移動ビーコンの推定位置。

2 個の移動ビーコンの位置推定誤差は、三辺測量法の位置推定精度を大きく低下させるほどではない。一方、KNNF と ASMF 1 では誤差が大きく増加した。これは、ビーコンが移動するとフィンガープリンティング手法の位置推定精度が著しく低下することを示している。しかし、データベース更新により、ASMF2 は ASMF 1 と比べて $4 8 . 1 8 \%$ の誤差低減を達成した。

![](images/1419fd02ecef5c235052c8a354a4e4d0d3d5b92461b4e0d1ae89c282648a9170.jpg)  
図 30. 実験 3 における位置推定結果。

![](images/e1308518c132739d3c35056b32afd3f50f953fb24a9e7313d87b0d8a3a753826.jpg)  
図 31. 実験 3 における累積位置推定誤差。

![](images/9ee151aeabd2aa55991885fe527352210423d944123f7a328ddb64e404cd2f05.jpg)  
図 32. 実験 4 における位置推定結果。

実験 4 では、事前計画した軌道に沿って研究室内を移動するターゲットを位置推定した。移動ターゲットの真値は、LRF と SLAM により推定した。ASMF 単独および KPF を併用した ASMF の結果を図 32、33 に示す。ASMF 単独と ASMF + KPF の位置推定誤差は、それぞれ 0.85 と 0.81 であった。この結果から、KPF はターゲットの移動距離を制限することで、ILS の位置推定結果をわずかに改善できることが分かる。

3) 総合解析: 最後に、実験結果から以下の特性が観察できる。図 34 は、各実験の 145 個の測定点における $P ( V _ { \mathrm { r o b o t } , t } | V _ { \mathrm { p d f } } ( \mathbf { p } _ { \mathrm { r o b o t } , t } , \mathbf { p } _ { b , k } ) )$ を示す。ここで $V _ { \mathrm { p d f } } ( \mathbf { p } _ { \mathrm { r o b o t } , t } , \mathbf { p } _ { b , k } )$ は初期データベース中のデータである。赤線は環境変化なしで平均値 0.151、緑線は障害物変化で平均値 0.073、青線はビーコン位置変化で平均値 0.014 を示す。図 34 より、ビーコン位置変化の認識には $H _ { 1 } = 0.02$ を選べる。図 35 は、各実験における $P ( V _ { \mathrm { r o b o t } , t } | V _ { \mathrm { p d f } } ( \mathbf { p } _ { \mathrm { r o b o t } , t } , \mathbf { p } _ { b , k } ) )$ のヒストグラムを示す。環境が静的な場合、赤線で示すように、ほとんどの確率値が 0.1 より高い $( 9 1 \% )$。したがって、環境に変化がなければ、この確率の最小値は 0.1 であると仮定し、環境が変化してデータベース更新が必要かどうかの判定には $H _ { 2 } = 0.1$ を選択する。実験結果より、$P ( V _ { \mathrm { r o b o t } , t } | V _ { \mathrm { p d f } } ( \mathbf { \bar { p } } _ { \mathrm { r o b o t } , t } , \mathbf { p } _ { b , k } ) \bar { ) }$ は 3 つの実験環境で異なり、これらを環境変化認識に利用できることが明らかである。

![](images/5d449914178e8a1f0382011476321b5db035a85e8a58372996da6b747939f633.jpg)  
図 33. 実験 4 における位置推定誤差。

![](images/6e43f0ce87446d82ae62c1087ee4300ef445be4791d6d62f85ab68fdcb4d8a48.jpg)  
図 34. 実験における測定点での $P ( V _ { \mathsf { r o b o t } , t } | V _ { \mathsf { p d f } } ( \mathbf { p } _ { \mathsf { r o b o t } , t } , \mathbf { p } _ { b , k } ) )$。

![](images/af2e6b039598a4f4c873b02fd1b90150f9363654299fd70942307c83b655b4e7.jpg)  
図 35. 実験における測定点での $P ( V _ { \mathsf { r o b o t } , t } | V _ { \mathsf { p d f } } ( \mathbf { p } _ { \mathsf { r o b o t } , t } , \mathbf { p } _ { b , k } ) )$ のヒストグラム。

実験 1 の結果は、信号モデルが RSS 測定統計から直接作られたデータベースよりも適切なフィンガープリントデータベースを提供することを示している。実験 2 は、シャドーイングモデルが信号の異常電力損失を補償し、障害物干渉を緩和できることを示した。実験 3 は、ビーコンが移動しても提案 ILS が位置推定精度を維持できることを示した。最後に実験 4 は、ILS が移動ターゲットを継続的に位置推定する場合に、KPF が位置推定結果を改善できることを示した。三辺測量ベース ILS は最初の 3 実験でほぼ同じ性能を示したが、精度自体は低い。フィンガープリンティングベース手法は、障害物変化でもビーコン変化でも、環境変化後に位置推定精度が大きく低下する。静的フィンガープリントデータベースが動的環境に不適切であることは明らかである。

更新データベースを用いた AMSF ベース ILS は、実験 1、2、3 で最良の結果を示した。ビーコン位置が変わっても、位置推定空間に新しい障害物が現れても、ASMF ILS はデータベース更新により一定の精度を維持する。ASMF のデータベース更新処理は、ロボット軌道上で収集した RSS 測定データのみを用いて、実験 2、3 でシャドーイングモデルを迅速に補正し、移動ビーコン位置を再推定し、531 個の RP のフィンガープリントを再計算できる。実験 2、3 における ASMF 2 の良好な精度は、ASMF が 531 個の RP で再度 RSS 測定を行って新データベースを構築する代わりに、より少ないデータでデータベースを補正できることを示している。変更環境に ILS を適応させる時間コストは大幅に削減され、更新処理も ILS 内で自動的に実行されるため、実運用への適用が可能となる。

# VI. 結論

本論文では、自律的データベース更新処理と ASMF 手法に基づく、動的環境向けの適応型無線 ILS を提案した。ASMF では、フェージングモデルが雑音をモデル化するとともに、低 RSS 値データの影響を下げる信頼度指標を RSS 測定値に与える。シャドーイングモデルにより、ILS は環境変化に適応するためにデータベース中の少数パラメータのみを補正すればよい。非線形回帰によって構築されるフィッティングパスロスモデルは、伝送距離推定により適している。最後に、実験結果は、ASMF ベース ILS が静的環境・動的環境の両方で、三辺測量法および KNNF ベース ILS より高い位置推定精度を持ち、自律ロボットに基づく自動データベース更新が動的環境で ILS を維持するのに有効であることを示している。ただし、このデータベース更新処理は即時ではなく周期的である。処理にはロボット巡回時間に応じて数分を要する。そのため、環境が変化してからロボットが巡回を終えるまでの間、一時的に精度が低下することは避けられない。また、移動障害物の影響や、シャドーイングモデル最適化における局所最適問題など、ASMF でも回避できない限界がある。

# 参考文献

[1] Z. Deng, Y. Yu, X. Yuan, N. Wan, and L. Yang, “Situation and development tendency of indoor positioning,” China Commun., vol. 10, pp. 42–55, 2013.  
[2] W. Elloumi, A. Latoui, R. Canals, A. Chetouani, and S. Treuillet, “Indoor pedestrian localization with a smartphone: A comparison of inertial and vision-based methods,” IEEE Sens. J., vol. 16, no. 13, pp. 5376–5388, Jul. 2016.  
[3] Y. Song, S. Liu, and J. Tang, “Describing trajectory of surface patch for human action recognition on RGB and depth videos,” IEEE Signal Process. Lett., vol. 22, no. 4, pp. 426–429, Apr. 2015.  
[4] S. S. Saab and Z. S. Nakad, “A standalone RFID indoor positioning system using passive tags,” IEEE Trans. Ind. Electron., vol. 58, no. 5, pp. 1961– 1970, May 2011.  
[5] S. Park and S. Hashimoto, “Autonomous mobile robot navigation using passive RFID in indoor environment,” IEEE Trans. Ind. Electron., vol. 56, no. 7, pp. 2366–2373, Jul. 2009.  
[6] B. S. Choi, J. W. Lee, J. J. Lee, and K. T. Park, “A hierarchical algorithm for indoor mobile robot localization using RFID sensor fusion,” IEEE Trans. Ind. Electron., vol. 58, no. 6, pp. 2226–2235, Jun. 2011.  
[7] S. J. Kim and B. K. Kim, “Dynamic ultrasonic hybrid localization system for indoor mobile robots,” IEEE Trans. Ind. Electron., vol. 60, no. 10, pp. 4562–4573, Oct. 2013.  
[8] K. H. Choi, W. S. Ra, S. Y. Park, and J. B. Park, “Robust least squares approach to passive target localization using ultrasonic receiver array,” IEEE Trans. Ind. Electron., vol. 61, no. 4, pp. 1993–2002, Apr. 2014.  
[9] L. H. Chen, E. H. K. Wu, M. H. Jin, and G. H. Chen, “Intelligent fusion of Wi-Fi and inertial sensor-based positioning systems for indoor pedestrian navigation,” IEEE Sens. J., vol. 14, no. 11, pp. 4034–4042, Nov. 2014.  
[10] D. Han, S. Jung, M. Lee, and G. Yoon, “Building a practical Wi-Fi-based indoor navigation system,” Pervasive Comput., vol. 13, pp. 72–79, 2014.  
[11] C. Yang and H. R. Shao, “WiFi-based indoor positioning,” IEEE Commun. Mag., vol. 53, no. 3, pp. 150–157, Mar. 2015.  
[12] N. Chuku, A. Pal, and A. Nasipuri, “An RSSI based localization scheme for wireless sensor networks to mitigate shadowing effects,” in Proc. IEEE Conf. Southeastcon, 2013, pp. 1–6.  
[13] J. Wilson and N. Patwari, “Radio tomographic imaging with wireless networks,” IEEE Trans. Mobile Comput., vol. 9, no. 5, pp. 621–632, May 2010.  
[14] S. Nannuru, Y. Li, Y. Zeng, M. Coates, and B. Yang, “Radio-frequency tomography for passive indoor multitarget tracking,” IEEE Trans. Mobile Comput., vol. 12, no. 12, pp. 2322–2333, Dec. 2013.  
[15] W. M. Ibrahim, A. E. M. Taha, and H. S. Hassanein, “Robust wireless multihop localization using mobile anchors,” in Proc. IEEE Int. Conf. Commun., 2013, pp. 1506–1511.  
[16] S. Kuo-Feng, O. Chia-Ho, and H. C. Jiau, “Localization with mobile anchor points in wireless sensor networks,” IEEE Trans. Veh. Technol., vol. 54, no. 3, pp. 1187–1197, May 2005.  
[17] F. Shih-Hau, H. Ying-Tso, and K. Wen-Hsing, “Dynamic fingerprinting combination for improved mobile localization,” IEEE Trans. Wireless Commun., vol. 10, no. 12, pp. 4018–4022, Dec. 2011.  
[18] M. M. Atia, A. Noureldin, and M. J. Korenberg, “Dynamic onlinecalibrated radio maps for indoor positioning in wireless local area networks,” IEEE Trans. Mobile Comput., vol. 12, no. 9, pp. 1774–1787, Sep. 2013.  
[19] R. C. Luo, M. Hsiao, and C. H. Xie, “Sensor fusion based vSLAM system for 3D environment grid map construction,” in Proc. IEEE Symp. Ind. Electron., 2013, pp. 1–6.  
[20] R. C. Luo and C. C. Lai, “Multisensor fusion-based concurrent environment mapping and moving object detection for intelligent service robotics,” IEEE Trans. Ind. Electron., vol. 61, no. 8, pp. 4043–4051, Aug. 2014.  
[21] R. Bultitude, “Measurement, characterization and modeling of indoor 800/900 MHz radio channels for digital communications,” IEEE Commun. Mag., vol. 25, no. 6, pp. 5–12, Jun. 1987.  
[22] L. Xu and M. I. Jordan, “On convergence properties of the EM algorithm for Gaussian mixtures,” J. Neural Comput., vol. 8, pp. 129–151, 1996.  
[23] P. Soille, Morphological Image Analysis: Principles and Applications, 2th ed. New York, NY, USA: Springer, 2007.  
[24] M. Idoudi, H. Elkhorchani, and K. Grayaa, “Performance evaluation of wireless sensor networks based on ZigBee technology in smart home,” in Proc. IEEE Conf. Elect. Eng. Softw. Appl., 2013, pp. 1–4.  
[25] P. Agrawal and N. Patwari, “Correlated link shadow fading in multihop wireless networks,” IEEE Trans. Wireless Commun., vol. 8, no. 8, pp. 4024–4036, Aug. 2009.  
[26] H. Yuguang and W. F. McColl, “An improved simplex method for function minimization,” in Proc. IEEE Conf. Syst., Man, Cybern., 1996, vol. 3, pp. 1702–1705.  
[27] C. Cheng and R. Ansari, “Kernel particle filter: Iterative sampling for efficient visual tracking,” in Proc. IEEE Int. Conf. Image Process., 2003, vol. 2, pp. III-977–III-980.  
[28] C. Cheng and R. Ansari, “Kernel particle filter for visual tracking,” IEEE Signal Process. Lett., vol. 12, no. 3, pp. 242–245, Mar. 2005.  
[29] Y. Cheng, “Mean shift, mode seeking, and clustering,” IEEE Trans. Pattern Anal. Mach. Intell., vol. 17, no. 8, pp. 790–799, Aug. 1995.  
[30] M. H. Amri, Y. Becis, D. Aubry, and N. Ramdani, “Indoor human robot localization using robust multi-modal data fusion,” in Proc. IEEE Int. Conf. Robot. Autom., 2015, pp. 3456–3463.  
[31] Z. Xiao, H. Wen, A. Markham, N. Trigoni, P. Blunsom, and J. Frolik, “Nonline-of-sight identification and mitigation using received signal strength,” IEEE Trans. Wireless Commun., vol. 14, no. 3, pp. 1689–1702, Mar. 2015.  
[32] S. He and S.-H. G. Chan, “Wi-Fi fingerprint-based indoor positioning: Recent advances and comparisons,” IEEE Commun. Surveys Tuts., vol. 18, no. 1, pp. 466–490, First Quarter 2016.

![](images/ee5713f8c505548ae51b1845f4cd2da03486f66996ce77bd4dfa4d6463bcaa7e.jpg)

Ren C. Luo は、1979 年および 1982 年に、ドイツ・ベルリンの Technische Universitat Berlin にて電気工学の Dipl.-Ing. 学位および Dr.-Ing. 学位を取得した。

現在は Fair Friend Group の最高技術責任者、および台湾・台北の国立台湾大学の特別教授である。米国ノースカロライナ州ローリーの North Carolina State University では終身在職権付き正教授を務め、日本・東京の東京大学では Toshiba Chair Professor を務めた。また、国立中正大学の学長を 2 期務めた。国際査読付き学術誌、国際査読付き会議、国際特許を含め 500 件を超える論文等を発表している。研究分野は、知能ロボットシステム、マルチセンサ融合・統合、3D プリンティング製造である。

Dr. Luo は IEEE TRANSACTIONS ON INDUSTRIAL INFORMATICS の編集長である。IEEE Industrial Electronics Society の会長も務めた。また、台湾の経済部・科学分野の顧問、および首相官邸の技術顧問も務めた。Institution of Engineering and Technology の Fellow でもある。

![](images/19234b68ce644b0d00578b0629c25029cb4cbd99e3673895fb60b7d36f4ca3f3.jpg)

Tung Jung Hsiao は、2008 年および 2010 年に台湾・台南の National Cheng Kung University にて電気工学の学士号および修士号を取得した。現在、台湾・台北の国立台湾大学電気工学専攻で博士号取得に向けて研究中である。

現在、国立台湾大学 International Center of Excellence in Intelligent Robotics and Automation Research の研究助手である。研究分野は、無線屋内位置推定、コンピュータビジョン、知能ロボティクスである。
