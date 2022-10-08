# Arma 3 Server
Based on Linux Game Server Manager, with the required packages for extdb3...

```shell
git clone https://github.com/felbinger/arma3server.git /tmp
mv /tmp/arma3server/app arma3server
rm -rf /tmp/arma3server/
```
```yaml
version: '3.9'

services:
  arma3:
    #image: ghcr.io/felbinger/arma3server
    build: arma3server
    restart: always
    environment:
      - "STEAM_USER="
      - "STEAM_PASS="
    ports:
      - '2302:2302/udp'    # Arma 3 + voice over network
      - '2303:2303/udp'    # Steam Query
      - '2304:2304/udp'    # Steam Master
      - '2305:2305/udp'    # old Voice over Network
      - '2306:2306/udp'    # BattleEye
    volumes:
      - '/srv/arma3:/home/linuxgsm'
```
