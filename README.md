---
title: 'プラグインなしでVimを使うテクニック'
emoji: "⛳"
type: "tech"
topics: ["vim", "neovim"]
publication_name: "vim_jp"
published: true
---

プラグインなしでVimを使うテクニックについて説明します。
vimrcも複雑な設定は無しです。

# TL;DR

*  ファイル検索は `:edit`と`:find`
*  一度開いたファイルは `:buffer`
*  最近開いたファイルは `:browse oldfiles`
*  ファイラーは `netrw`
*  文字列検索は `:vimgrep`
*  ビルドのエラー表示は `:make`
*  LSP を使う(neovim限定)

# モチベーション

先日、[Youtubeでプラグインの90%をただのVimを使う動画](https://www.youtube.com/watch?v=XA2WjJbmmoM)に感銘を受けまして、
今回はそれを掻い摘みつつ、自分なりにプラグインがない環境でVimを使う方法をまとめます。

と言っても、Vimのハック的な方法を使うことはなく、純粋にVimの機能に詳しくなりましょうというのが目的です。
途中から、LSPが出てきてNeovimでしか動作しなくなっちゃうので、その点は注意してください。

# ファイルの検索には :edit を使う

`:e` は実はすごく高機能です。ファイル名を全部書く必要はありません。`*`で上手に補完することで素早くファイルに辿り着けます。
例えば、現在のフォルダ内でphpファイル を再帰的(フォルダの中の全てのファイル)に検索したい場合は、`:e **/*.php<C-d>` です。
ここで、`<C-d>`の代わりに`<Tab>`を押してはいけません。まずは`<C-d>`で検索結果を見ましょう。
そこで多ければ、さらに絞るために、`*`と絞るための文字列を組み合わせて入力します。
例えば、`:e **/*Repository.php<C-d>`で〜リポジトリを検索します。
ここでももちろん、`<C-d>`です。候補が少なくなれば、`<Tab>`と`<S-Tab>`でファイルを選びましょう。
`*`を使っていない部分は`<C-l>`で候補結果を見て最長一致するところまで補完してくれます。
また、一度`<Tab>`を押すと`<C-n>`と`<C-p>` でも上下移動できます。`<C-w>`を押すと１単語消してくれます。

# ファイル数が多いプロジェクトのファイルの検索には :find を使う

`:fin[d]` は簡単に言えば、`:e[dit]` の強化版です。
`:e` との違いは`path`オプションから検索してくれることです。
`:e` で再帰的に検索すると`vendor`や`node_modules`のような大量のファイルがあるとめちゃくちゃパフォーマンスが悪くなりますので、
`set path+=src/**,lib/**` などプロジェクトによって適宜変えて`:fin`を使います。
`path`にライブラリなどの別のパスを指定することもできますが、定義ジャンプから開く方が早いと思いますのでここでは触れません。

例えば、現在のフォルダ内でphpファイル を検索したい場合は、`:fin *.php<C-d>` です。
`**`は`path`に指定していれば不要です。
`:e` の`sp[lit]` や `vs[plit]`、`tabe[dit]` 同様に `:sfin[nd]` や `:vert[ical] sfin[ind]` 、`tabf[ind]`で分割ウィンドウや新しいタブで開くこともできます。

現在開いてるファイルと同じディレクトリのファイルを開きたいときは、`:e %:h<C-d>`とするといいでしょう。
`%`が今のファイルで`:h`がそのディレクトリという意味です。もう一つ上の階層に行きたい場合は、もう一つ`:h`をつけて`:e %:h:h<C-d>`と入力します。

## 一度開いたファイルは、:buffer を使う

Vimではタブを使うよりバッファを使う方が早いです。
新しいファイルを開くとき、今ファイルは気軽に閉じちゃいましょう。

バッファを見るとき、いちいち`:ls` でファイル名や番号を確認する必要はありません。
`:b <C-d>` で開いたファイルを表示して、先ほど同様に`<C-d>`と`<C-l>`で表示、補完しながら絞っていきます。
ただ、`:e`や`:find`と違って、`*`はなくても部分一致で検索に引っ掛かります。
引っかかるファイルが分かっていれば早々に、`<Tab>`を押して補完してしまいましょう。

例えば、`~/.config.nvim/init.vim` を開き直したい場合は、`:b ini<Tab><CR>` で開けます。
１個前のファイルとかなら、`:b[p]revious`を使います。

新しいwindowsで開く場合は、`:sb`、`:vert sb`です。

## 過去に開いたファイルは、:browse oldfiles を使う

バッファは一度Vimを閉じると全て消えちゃいますので、
Vimを新しく開いあとは`v:oldfiles`からファイルを探します。
`echo v:oldfiles` で配列が返ってきますが、そこからファイルを選びたい場合は、
`:browse`を組み合わせて使うと良いでしょう。


ここまでをまとめると、ファイルを探すときは、まずは`:b <C-d>`、次に`:bro old`、
その次に`:e <C-d>`、`:fin <C-d>`の順番で考えましょう。

# ファイラーにnetrwを使う

`netrw` はVimに標準で含まれているプラグインになります。
`:Explore` か、`:E` でファイラを開けます。左側に開きたい場合は、`:Vexplore`しましょう。

`<CR>` でディレクトリを開閉かファイルを開けます。
`t` で新しいタブで開き、`o` や `v` で上下左右に分割して開きます。
ツリーにするには以下の設定をしときましょう。
```vimscript
let g:netrw_liststyle = 3
```

`%` でファイル作れて`D`で消せます。`d`でフォルダ作れるけど消すのは空じゃないとできません。
`%<Tab>` で今のディレクトリを補完できますので、`:rm! -rf %<Tab>/xxx` で補完して消すのがおすすめです。
ファイル開いてから、そのファイルで `:E` すれば、そのファイルのフォルダで開けます。
逆にルートから開き直したい場合は、`:E .` としましょう。

他のEから始まるコマンドと競合する場合は以下の設定をしておきましょう。
```vimscript
command! -nargs=? E Explore <args>
```

# ファイル・文字列検索

## フォルダ内の文字列検索には :vimgrep を使う

`:vim` で使えます。
src フォルダ内を検索したい場合は、`:vim hello src/** | cw` とすると、`quickfix window` が開いて、そのままクリックするだけで開けます。
`:cc` で現在のエラー、`:cn` で次のエラー、`:cnf`で次のファイルのエラー、`:cp` で前のエラーに飛びます。
`@:` で前に実行したコマンドが打てて、一度`@:`を押すとマクロ同様に`@@`で繰り返せます。


# 診断・ビルドのエラー表示とジャンプ

## :makeを使う

`:make` で `make` を実行できます。C/C++専用のビルドツールという印象があるかと思いますが、
単にシェルを実行するツールとして利用できます。
Makefile にコマンドを設定して、`:mak lint` で `quickfix window` に出します。

```Makefile
lint:
	eslint --ext=js,ts -f unix --fix .
build:
	go build ./...
```

または、`set makeprog=eslint\ -f\ unix` で `make`コマンドを使わずに直接実行したいプログラムを指定することも可能です。
コマンド実行時に返される文字列のフォーマットは`errorformat`で設定できますが、ちょっとめんどくさいです。。


# LSP を使う(neovim限定)

[LSP](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/) はざっと以下の機能を持つ開発に必須のツールです。

* 定義ジャンプ、参照ジャンプ
* ハイライト
* ドキュメント表示
* コード補完
* エラー診断
* コードアクション(修正してくれるやつ）
* フォーマット
* 名前変更

残念ながらプラグイン無しだとNeovimしか対応していませんので注意してください。
設定方法は、`:h vim.lsp` を見ましょう。
goplsの場合は、以下のように設定します。

```lua
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*.go",
  callback = function()
    vim.lsp.start({
      name = 'gopls',
      cmd = {'gopls'},
      root_dir = vim.fs.dirname(vim.fs.find({'go.mod'}, { upward = true })[1]),
    })
  end
})
```

さてこの設定だけで結構たくさんのことができます。

* タグジャンプの`<C-[>`が使えます。ウィンドウ分割する場合は`<C-w><C-[>`です。
`<C-w>{`でプレビューウィンドウに表示できます。

* コード補完は、`<C-x><C-o>`で使えます。変数名やメソッド名などが出てくれます。

* エラー表示

デフォルトでエラーを表示してくれますが移動はできません。移動するには`vim.diagnostic.goto_next`が有名ですが、
今回は、`:vimgrep`や`:make`で使った`quickfix window` の１つのファイル専用版である `location list` に出してみましょう。
設定は以下です。

```vimscript
augroup my-lsp-diagnostic
  au!
  " diagnostic (エラー) を location list に出す
  au DiagnosticChanged *.go,*.ts,*.tsx lua vim.diagnostic.setloclist({open = false})
augroup end
```

他の項目は、`lua vim.lsp.xxx`をそれぞれマッピングして使う必要があります。

```vimscript
" カーソル下の変数名変更
nnoremap <leader>rn :<C-u>lua vim.lsp.buf.rename('')<Left><Left>

" ファイルのフォーマット
nnoremap <leader>f <Cmd>lua vim.lsp.buf.format()<CR>

" プロジェクト内の全てのエラーを `quickfix window`に出す
nnoremap <leader>q <Cmd>lua vim.diagnostic.setqflist()<CR>
```

以上です。

本記事の設定はこちらから見れます。
https://github.com/ryicoh/config_nvim_without_plugin


Vimはプラグインがなくても割と色々できることが少しでも伝わればいいなと思います。
おしまい

