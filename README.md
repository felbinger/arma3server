# Arma 3 Server
Based on Linux Game Server Manager, with the required packages for extdb2 / extdb3...

## Setup Instructions: Arma 3 Exile Mod (extDB2)
1. Install Docker and unzip `apt install -y unzip`
2. Add `docker-compose.yml` in `/home/admin/arma3`:
    ```yaml
    version: '3.9'

    services:
      arma3:
        image: ghcr.io/felbinger/arma3server
        restart: always
        environment:
          # will be stored on filesystem (/srv/aram3/lgsm/config-lgsm/arma3server/arma3server.cfg) during installation
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
          
      mysql:
        image: mysql:5.7
        restart: always
        environment:
          - "MARIADB_RANDOM_ROOT_PASSWORD=true"
          - "MARIADB_USER=arma3"
          - "MARIADB_PASSWORD=S3cr3T"
          - "MARIADB_DATABASE=exile"
        volumes:
          - "/srv/arma3-mariadb:/var/lib/mysql"
    ```

3. Adjust permission for `/srv/arma3`:
    ```shell
    mkdir /srv/arma3
    chown 1000:1000 /srv/arma3
    ```

4. Start the arma3 container (`docker compose up -d arma3`) to perform the installation.

5. Add your mods to `/srv/arma3/serverfiles/`:
    ```shell
    cd /srv/arma3/serverfiles/
    
    wget http://exilemod.com/ExileServer-1.0.4a.zip
    unzip ExileServer-1.0.4a.zip 
    rm ExileServer-1.0.4a.zip
    
    # TODO upload ExileMod from client which pulled it from steam workshop  
    
    # move the extracted files into the correct locations
    cp -r /srv/arma3/serverfiles/Arma\ 3\ Server/* /srv/arma3/serverfiles/

    # create tables on database using provided database schema
    dc -f /root/docker-compose.yml exec -T mysql mysql -uarma3 -pS3cr3T exile < /srv/arma3/serverfiles/MySQL/exile.sql
    
    # adjust extdb2 configuration
    sed -i 's/^IP = 127.0.0.1/IP = mysql/' /srv/arma3/serverfiles/@ExileServer/extdb-conf.ini
    sed -i 's/^Username = changeme/Username = arma3/' /srv/arma3/serverfiles/@ExileServer/extdb-conf.ini
    sed -i 's/^Password = /Password = S3cr3T/' /srv/arma3/serverfiles/@ExileServer/extdb-conf.ini

    # arma 3 server configs
    mv /srv/arma3/serverfiles/@ExileServer/basic.cfg /srv/arma3/serverfiles/cfg/arma3server.network.cfg
    mv /srv/arma3/serverfiles/@ExileServer/config.cfg /srv/arma3/serverfiles/cfg/arma3server.server.cfg 

    # add mods to server startup configuration
    cat <<_EOF >> /srv/arma3/lgsm/config-lgsm/arma3server/arma3server.cfg
    
    # mods="@Exile;@Extended_Base_Mod;@AdminToolkitServer"
    mods="@Exile"
    servermods="@ExileServer"
    
    # extDB2 is only for 32-bit - think about changing to extDB3 which supports 64-bit!
    executable="./arma3server"
    _EOF

    # delete remaining extracted files from exile-server
    rm -r /srv/arma3/serverfiles/Arma\ 3\ Server/
    rm -r /srv/arma3/serverfiles/MySQL
    
    # adjust permissions
    chown -R 1000:1000 /srv/arma3
    ```

6. Restart the arma3 container to start the server (`docker compose down && docker compose up -d`)

7. Debug your way through using `docker compose exec arma3 arma3server console`

### Extended Base Mod
* see readme.html file in workshop content for installation instructions

### AdminToolkit
* unpack server cfg pbo
* fix admin uids
* repack server cfg pbo
* adjust mission
* can be opened with F2
