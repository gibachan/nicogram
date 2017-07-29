# nicogram

ニコニコ動画ダウンロードツール written in Swift

## コンパイル

```
git clone git@github.com:gibachan/Nicogram.git
cd Nicogram
swift build
```

## テスト

```
swift test
```

## 使い方

ニコニコ動画の動画URLと、アカウントのメールアドレス、パスワードを指定して実行します。

```
.build/debug/Nicogram http://www.nicovideo.jp/watch/sm15630734 --email xxxxx@example.com --password xxxxx
```

動画ファイルがカレントディレクトリに保存されます。



