# Arma 3 Server
Based on Linux Game Server Manager, with the required packages for extdb3...

```yaml
  arma3:
    image: arma3server
    restart: always
    ports:
      - '2302:2302/udp'    # Arma 3 + voice over network
      - '2303:2303/udp'    # Steam Query
      - '2304:2304/udp'    # Steam Master
      - '2305:2305/udp'    # old Voice over Network
      - '2306:2306/udp'    # BattleEye
    volumes:
      - '/srv/games/arma3:/home/lgsm'
```
