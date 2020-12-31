# docker-ezgo-vdi

這是一個執行 *[ezgo](http://ezgo.westart.tw/)* 的容器，使用作為遠端桌面。目前版本為 14.1，如果您想要使用 13 位置在[這裡](https://github.com/leejoneshane/docker-ezgo-vdi/tree/13).

這個容器是使用 ubuntu 20.04 打造的，與 EZGO 官方所採用的 ubuntu 18.04 略有不同，除系統差異外，還新增以下應用程式：

* scratux: 這是將 scratch 3 打包為 Linux 套件，以方便安裝。
* google chrome: Google 瀏覽器最新版本，只能以非沙盒模式執行。經測試執行穩定，不會當機，請安心使用。
* 未如官方建議移除 XMind，因此也未提供 freeMind。留待以後更新。

由於 ezgo 提供相當多影音剪輯和播放軟體，如果您想聽到聲音，請務必使用微軟遠端桌面程式（RDP Client）連線。vnc 以及 noVnc（
    網頁）不支援聲音頻道。


*網頁連線*

請以底下指令啟動容器，並開啟 80 埠
```
docker run -p 80:80 -d leejoneshane/ezgo-vdi
```
使用瀏覽器打開 http://localhost ，若詢問密碼請輸入 __ezgo__。

*使用 VNC 連線*

如果要啟用 VNC 連線，則必須開啟 5900 埠
```
docker run -p 5900:5900 -d leejoneshane/ezgo-vdi
```
然後，您可以使用 VNC 用戶端程式進行連線。如果您使用 Mac 電腦， macos 系統內建的 VNC 連線工具並不支援非安全連線。請改用其它程式或者使用瀏覽器中的 VNC 插件即可。

*使用微軟遠端桌面連線*

如果要啟用微軟遠端桌面連線，則必須開啟 3389 埠
```
docker run -p 3389:3389 -d leejoneshane/ezgo-vdi
```
在您的 Windows 命令列模式輸入 mstsc 開啟連線程式。
如果是蘋果電腦，請從 App 商店下載安裝 Microsoft Remote Desktop。

*使用 Swarm 部署*

使用 Swarm 部署可以一次啟用多個容器，數量可以自行調節。
可透過 traefik 進行 HTTPS 保護，並自動取得金鑰。
建議 80、3389、5900 三個埠都打開，以便提供多元服務。

請修改 docker-compose.yml 檔案內的參數，以適應貴校所建置的 docker 叢集系統。
