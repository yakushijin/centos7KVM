# 概要

## 目的

- とにかくすぐに KVM の環境をさくっと構築する用
- 無理やりシェルスクリプトでごりごり実行している
- 破壊と創造を繰り返す人向け

## 環境

- centos7 系（本手順は 7.7 で実施、8 系 でも多分いけるはず）
- BIOS の設定で CPU の仮想化支援機能を有効済み

## OS セットアップ情報

### パーティション

- 手動設定の標準
  - boot 1G
  - swap 4G
  - / 残りすべて

### ソフトウエアの選択

- サーバー（GUI 使用）

# 構築

## セットアップ

※root ユーザで実行

1. script/server.conf を個別の環境に合わせて設定する
1. script フォルダを任意の場所に置く
1. 実行権限を付ける

   ```sh
   chmod 700 script/*
   ```

1. OS のセットアップを実行

   ```sh
   ./OSinit.sh
   ```

1. KVM のセットアップを実行

   ```sh
   ./KVM.sh
   ```

## 動作確認

- ISO ファイル（ここでは CentOS8.2.iso）を以下フォルダに指定した名称にて格納する

  > /var/lib/libvirt/images/iso/CentOS8.2.iso

- iso ファイルからイメージを作成する

  ```sh
  virt-install \
  --name centos7_init \
  --hvm \
  --virt-type kvm \
  --ram 4096 \
  --vcpus 2 \
  --arch x86_64 \
  --os-type linux \
  --os-variant rhel7 \
  --network network=host-bridge \
  --graphics vnc,listen=0.0.0.0 \
  --noautoconsole \
  --disk path=/var/lib/libvirt/images/data/centos7_init.qcow2,format=qcow2,size=20,sparse=true \
  --cdrom /var/lib/libvirt/images/iso/CentOS8.2.iso
  ```

- 確認

  ```sh
  virsh list --all
  ```

GUI 上から仮想マシンマネージャを起動すると作成したイメージが表示されているので適宜セットアップを開始する
