# RedHat Openshift Enterprise cluster on Azure

## OpenShift Enterpriseのクラスタを構築
### Azure に OpenShift Enterprise をインストールするためのRed Hat Enterprise Linuxサーバ及びネットワーク環境を構築
「Deploy to Azure」をクリックすると、Azure へのデプロイを開始します。
「Visualize」をクリックすると、インストールする構成が可視化されます。
<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fakubicharm%2Fazure-openshift%2Fwip%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fakubicharm%2Fazure-openshift%2Fwip%2Fazuredeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>


## OpenShiftのインストーラ(ansible)を使ってOpenShift Enterpriseをインストール
Azureのインスタンスのデプロイ時に作成される、opensift-install.shから ansible の Playbook を実行します。

OpenShift Enterpriseのインストーラのパッケージである atomic-openshift-utils に、ansible と OpenShift EnterpriseをインストールするためのAnsible Playbookが含まれています。
azuredeploy.json ファイルでは、Azure上にデプロイされたRed Hat Enterprise Linuxのホスト名やIPアドレスに基づき Ansible の hosts ファイルを作成して、インストールします。

### Terminal
サーバ環境の構築時に公開鍵をアップロードしていますので、プライベートキーを使って ssh でマスタサーバにログインします。

```bash
user@localmachine:~$ ssh -i ~/.ssh/id_rsa [マスタサーバのユーザ名]@[マスタサーバのIPアドレス]
```
Masterサーバからパスワードなしで各サーバへログインできるように、SSH RSAの鍵を全サーバにコピーします。

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

### OpenShift Enterpriseのクラスタ構築 with powershell
使っていないので、オリジナル版の受け売りです。ごめんなさい。

```powershell
New-AzureRmResourceGroupDeployment -Name <DeploymentName> -ResourceGroupName <RessourceGroupName> -TemplateUri https://raw.githubusercontent.com/akubicharm/azure-openshift/wip/azuredeploy.json
```

## SSH Key Generation
インストール作業をするにあたり SSH RSA の鍵の作成は下記を参照してください。

1. Windows - https://www.digitalocean.com/community/tutorials/how-to-create-ssh-keys-with-putty-to-connect-to-a-vps
2. Linux - https://help.ubuntu.com/community/SSH/OpenSSH/Keys#Generating_RSA_Keys
3. Mac - https://help.github.com/articles/generating-ssh-keys/#platform-mac
