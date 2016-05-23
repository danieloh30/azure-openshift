# RedHat Openshift Enterprise cluster on Azure

## OpenShift Enterpriseのクラスタを構築
### Azure に OpenShift Enterprise をインストールするためのRed Hat Enterprise Linuxサーバ及びネットワーク環境を構築
「Deploy to Azure」をクリックすると、Azure へのデプロイを開始します。
「Visualize」をクリックすると、インストールする構成が可視化されます。

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fakubicharm%2Fazure-openshift%2F3.1%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fakubicharm%2Fazure-openshift%2F3.1%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


## OpenShiftのインストーラ(ansible)を使ってOpenShift Enterpriseをインストール

### 事前準備
- Ansible の Playbook 実行時に、パスワード入力なしで各サーバーへログインできるように、SSH Key を配置
- infranode にデプロイする Docker Registry 用の永続化ストレージとして利用するディレクトリの作成と権限の設定
※Docker RegistryはUID=1001で実行されるので、永続化ストレージとしてNFSのファイルシステムを利用する場合には、chownでディレクトリのオーナーをUID=1001に設定します。

```
[adminUsername@master]$ ssh infranode
[adminUsername@master]$ sudo mkdir /registry
[adminUsername@infranode]$ sudo chown 1001:root /registry
```

## OpenShift Enterprise のインストールの実施

Azureのインスタンスのデプロイ時にmasterサーバに作成される、openshift-install.sh と hosts ファイル (/etc/ansible/hosts) の定義に従って Ansible の Playbook  ansible の Playbook を実行します。


OpenShift Enterpriseのインストーラのパッケージである atomic-openshift-utils に、ansible と OpenShift EnterpriseをインストールするためのAnsible Playbookが含まれています。
azuredeploy.json ファイルでは、Azure上にデプロイされたRed Hat Enterprise Linuxのホスト名やIPアドレスに基づき Ansible の hosts ファイルを作成して、インストールします。

```bash
[adminUsername@master ~]$ ./openshift-install.sh
```

------

## Parameters
### Input Parameters

| Name| Type           | Description |
| ------------- | ------------- | ------------- |
| redhatUser      | String      | Red Hat Network のユーザ名 |
| redhatPassword  | String      | Red Hat Network のパスワード |
| redhatPoolId    | String      | Red Hat Subscription のPoolID |
| adminUsername  | String       | Openshift Webconsole にログインするユーザ名。インストール後に追加、変更可能 |
|  adminPassword | SecureString | OpenShift Webconsole のパスワード |
| sshKeyData     | String       | 仮想サーバへログインするための公開鍵 |
| masterDnsName  | String       | Openshift Master / Webconsole の DNS 接頭辞 |
| numberOfNodes  | Integer      | OpenShift の Node サーバー数 |


### Output Parameters

| Name| Type           | Description |
| ------------- | ------------- | ------------- |
| openshift Webconsole | String       | Openshift Webconsole のURL|
| openshift Master ssh |String | Master サーバへSSHでログインするためのパスワード |
| openshift Router Public IP | String       | OpenShiftのRouter Public IP. Wildcard DNSには、このIPアドレスを設定する |

------

## OpenShift Enterpriseのクラスタ構築 with powershell
使っていないので、オリジナル版の受け売りです。ごめんなさい。

```powershell
New-AzureRmResourceGroupDeployment -Name <DeploymentName> -ResourceGroupName <RessourceGroupName> -TemplateUri https://raw.githubusercontent.com/akubicharm/azure-openshift/3.1/azuredeploy.json
```

-------
## SSH Key Generation
インストール作業をするにあたり SSH RSA の鍵の作成は下記を参照してください。

1. Windows - https://www.digitalocean.com/community/tutorials/how-to-create-ssh-keys-with-putty-to-connect-to-a-vps
2. Linux - https://help.ubuntu.com/community/SSH/OpenSSH/Keys#Generating_RSA_Keys
3. Mac - https://help.github.com/articles/generating-ssh-keys/#platform-mac

-------
## トラブルシュート
### デプロイ実行ログ
`/var/log/azure` に、サーバのプロビジョニングと、拡張スクリプトの実行結果が保存されています。
