# Image Grayscale

## 環境
- Language: Swift
- Xcode version: 16.0
- 対象OS: iOS16.0以上

## 概要
Image Grayscaleは、カメラで撮影した画像をグレースケールに変換し、保存するiOSアプリです。
ユーザーはカメラのプレビューを見ながら、シャッターボタンを押して画像を撮影できます。

## 特徴
- リアルタイムプレビュー
- シャッタータイマー機能
- 撮影した画像をグレースケールに変換
- 写真ライブラリへの保存

## 使用技術
- Swift
- UIKit
- AVFoundation
- SnapKit（レイアウトライブラリ）

## ライブラリ
このプロジェクトでは、以下のライブラリをSwift Package Manager (SPM) を使用して管理しています。

   - **SnapKit**: 
     ```
     https://github.com/SnapKit/SnapKit.git
     ```

   - **SwiftLint**: 
     ```
     https://github.com/realm/SwiftLint.git
     ```

   - **SwiftFormat**: 
     ```
     https://github.com/nicklockwood/SwiftFormat.git
     ```


## インストール
1. このリポジトリをクローンします。

   ```bash
   git clone https://github.com/USER_NAME/image-grayscale.git
   ```
   
2. Xcodeでプロジェクトを開きます。
3. カメラ機能を使用するため、実機でビルドして実行します。

## 使い方
1. アプリを起動します。
2. プレビュー画面でシャッターボタンをタップします。
3. カウントダウンが終了したら、画像が撮影され、グレースケールに変換されます。
4. 変換された画像はカメラロールに保存されます。
