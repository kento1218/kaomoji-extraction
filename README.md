# kaomoji-extraction

テキストから顔文字っぽい部分を抽出するヤツです。

## 必要なもの

* [MeCab][me] 0.98 (0.99以降では動きません!!)
* MeCab-python 0.98
* [YamCha][ym]

[me]: http://code.google.com/p/mecab/
[ym]: http://chasen.org/~taku/software/yamcha/

## 使い方

    $ cat << EOF | python mkfeature.py -r | yamcha -m data/smiley13.model | python resultview.py
    課題やってない＼(^o^)／ｵﾜﾀ
    EOF
    text: 課題やってない＼(^o^)／ｵﾜﾀ
    result: ＼(^o^)／ｵﾜﾀ

## 原理

顔文字にIOBタグをつけて、YamChaで学習させました。YamChaに入れる素性にはMeCabが生成したラティスと付与したコストを使っていろいろやってます(mkfeature.py参照)。
SVMのパラメータをいじって複数モデルを作りましたが、詳細は忘れた。

## 参考文献

田中裕紀、高村大也、奥村学「文字ベースのコミュニケーションにおける顔文字に関する研究」言語処理学会 第10回年次大会
