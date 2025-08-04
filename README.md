# Arma 3 Server
Based on Linux Game Server Manager, with the required packages for extdb2 / extdb3...

## Setup Instructions
1. Install docker 
2. Add `/home/admin/arma3/docker-compose.yml` for the Arma 3 server
    ```yaml
    services:
      arma3:
        image: ghcr.io/felbinger/arma3server
        restart: always
        env_file: .arma3.env
        ports:
          - '2302:2302/udp'    # Arma 3 + voice over network
          - '2303:2303/udp'    # Steam Query
          - '2304:2304/udp'    # Steam Master
          - '2305:2305/udp'    # old Voice over Network
          - '2306:2306/udp'    # BattleEye
        volumes:
          - '/srv/arma3:/home/linuxgsm'
    ```

3. Add `/home/admin/arma3/.arma3.env`:
    ```
    # will also be stored on filesystem (/srv/aram3/lgsm/config-lgsm/arma3server/arma3server.cfg) during installation!
    STEAM_USER=steam_username
    STEAM_PASS=steam_password
    ```

4. Adjust permission for `/srv/arma3`:
    ```shell
    mkdir /srv/arma3
    chown 1000:1000 /srv/arma3
    ```

5. Start the arma3 container (`docker compose up -d arma3`) to perform the installation.

6. Customize the server, the importent configurations are:
   - `/srv/arma3/serverfiles/cfg/arma3server.server.cfg`: Server configuration, e.g. name of the server
   - `/srv/arma3/serverfiles/mpmissions`: multiplayer mission files
   - `/srv/arma3/lgsm/config-lgsm/arma3server/arma3server.cfg`: server startup parameters (e.g. which mods you'd like to load)

   If you'd like to setup an Arma 3 Exile server, checkout the instructions below.

## MySQL Setup Instructions (for extDB2 / extDB3)
1. Add `/home/admin/mysql/docker-compose.yml` for the database server:
    ```yaml
    services:
      mysql:
        image: mysql:5.7
        restart: always
        env_file: .mysql.env
        volumes:
          - "/srv/mysql:/var/lib/mysql"
    ```

2. Add `/home/admin/arma3/.mysql.env`:
    ```
    MYSQL_ROOT_PASSWORD=S3cr3T
    MYSQL_USER=arma3
    MYSQL_PASSWORD=S3cr3T
    MYSQL_DATABASE=exile
    ```

3. Start the arma3 container (`docker compose up -d mysql`) to perform the installation.

## Arma 3 ExileMod Setup Instructions

1. Setup MySQL (see last chapter)

2. Create seperate user and database for exile:
    You don't have to do this, if you already created the `arma3` user and the `exile` database using the mysql environment variables!
    ```shell
    docker-compose -f /home/admin/mysql/docker-compose.yml exec mysql mysql -uroot -pS3cr3T
    ```
    ```sql
    CREATE DATABASE IF NOT EXISTS exile;
    CREATE USER IF NOT EXSITS arma3 IDENTIFIED BY 'S3cr3T'; 
    GRANT ALL ON exile.* TO arma3;
    ```

3. Download `@ExileServer`:
    ```shell
    apt install -y unzip
    wget -O /tmp/ExileServer-1.0.4a.zip http://exilemod.com/ExileServer-1.0.4a.zip
    mkdir -p /tmp/ExileServer
    unzip /tmp/ExileServer-1.0.4a.zip -d /tmp/ExileServer
    rm /tmp/ExileServer-1.0.4a.zip

    cp -r /tmp/ExileServer/Arma\ 3\ Server/* /srv/arma3/serverfiles/
    ```

4. Create required database structure
    ```shell
    docker compose -f /home/admin/mysql/docker-compose.yml exec -T mysql mysql -uarma3 -pS3cr3T exile < /tmp/ExileServer/MySQL/exile.sql
    ```

5. Remove old artifacts
    ```shell
    rm -r /tmp/ExileServer
    ```

6. Adjust extDB2 configuration
    ```shell
    # adjust extdb2 configuration
    sed -i 's/^IP = 127.0.0.1/IP = mysql/' /srv/arma3/serverfiles/@ExileServer/extdb-conf.ini
    sed -i 's/^Username = changeme/Username = arma3/' /srv/arma3/serverfiles/@ExileServer/extdb-conf.ini
    sed -i 's/^Password = /Password = S3cr3T/' /srv/arma3/serverfiles/@ExileServer/extdb-conf.ini
    ```

7. Move `@ExileServer` configurations to the arma 3 server config folder:
    ```shell
    mv /srv/arma3/serverfiles/@ExileServer/basic.cfg /srv/arma3/serverfiles/cfg/arma3server.network.cfg
    mv /srv/arma3/serverfiles/@ExileServer/config.cfg /srv/arma3/serverfiles/cfg/arma3server.server.cfg 
    ```

8. Upload `@ExileMod` from your client (latest version can only be obtained from Steam workshop)

9. Add mods to arma 3 server startup configuration:
    ```shell
    # add mods to server startup configuration
    cat <<_EOF >> /srv/arma3/lgsm/config-lgsm/arma3server/arma3server.cfg

    # mods="@Exile;@Extended_Base_Mod;@AdminToolkitServer"
    mods="@Exile"
    servermods="@ExileServer"
    
    # extDB2 is only for 32-bit - think about changing to extDB3 which supports 64-bit!
    executable="./arma3server"
    _EOF
    ```

10. Adjust permissions
    ```
    chown -R 1000:1000 /srv/arma3
    ```

11. Restart the arma3 container to start the server
    ```shell
    docker compose -f /home/admin/arma3/docker-compose.yml down
    docker compose -f /home/admin/arma3/docker-compose.yml up -d
    ```

### [Mod: Extended Base Mod](https://steamcommunity.com/sharedfiles/filedetails/?id=647753401)
Video walkthrough from freakboy: [youtube.com/watch?v=dhT6C4PrCrQ](https://www.youtube.com/watch?v=dhT6C4PrCrQ)

* checkout readme.html file in workshop content for installation instructions

### [Mod: AdminToolkit](https://github.com/ole1986/a3-admintoolkit)
Video walkthrough from freakboy: [youtube.com/watch?v=YN7w0j-4V-4](https://www.youtube.com/watch?v=YN7w0j-4V-4)

1. Download the git repository
2. Extract the contents of the zip archive.
3. Unpack `/a3-admintoolkit-master/@AdminToolkitServer/addons/admintoolkit_servercfg.pbo` using PBO Manager ([[1]](https://github.com/SteezCram/Armaholic-Archive/tree/main/PBO_Manager), [[2]](https://native-network.net/downloads/file/6-pbo-manager-v1-4-beta/))
4. Adjust the variables in the file `config.cpp` (all vairables are in the `AdminToolkit` class which is in the `CfgSettings` class):
   - `ServerCommandPassword`
   - `AdminList`
   - `ModeratorList`
5. Repack the unpacked folder into a pbo and upload the `@AdminToolkitServer` to the `serverfiles` directory on the server..
6. Adjust mission and upload to the mpmissions directory on the server:
   - Unpack your mpmission
   - Put `/a3-admintoolkit-master/source/mission_file/atk` into the mission root folder
   - Before class `CfgExileCustomCode` paste `CfgAdminToolkitCustomMod` class with the following content:
     ```c
     class CfgAdminToolkitCustomMod {
       /* Exclude some main menu items
       * To only show the menus loaded from an extension, use:
       * 
       * ExcludeMenu[] = {"Players", "Vehicles", "Weapons" , "Other"};
       */
       ExcludeMenu[] = {};
       
       /* Load an additional sqf file as MOD */
       Extensions[] = {
         /**
         * Usage: {"<Your Mod Title>", "<YourModFile>"}
         * add a new menu entry called My Extension into main menu */
         {"My Extension", "MyExtension"}
       };

       /* 4 Quick buttons allowing to add any action you want - See example below*/
       QuickButtons[] = {
         /* send a message to everyone using the parameter text field */
         {"Restart Msg", "['messageperm', ['Server Restart in X minutes']] call AdminToolkit_doAction"},
         /* Quickly get a Helicopter */
         {"Heli", "['getvehicle', ['B_Heli_Light_01_armed_F']] call AdminToolkit_doAction"},
         /*4 button*/
         {"Empty", "['Command', ['Variable #1', 'Variable #2']] call AdminToolkit_doAction"}
       };
     };
     ```
    - Adjust description.ext:
      Add to class `CfgRemoteExec.Functions`:
      ```c
      class AdminToolkit_network_receiveRequest {
        allowedTargets = 2;
      };
      ```
    - Repack mission file and upload it to the server
7. Add `@AdminToolkitServer` as **client mod** in server startup configuration file (`/srv/arma3/lgsm/config-lgsm/arma3server/arma3server.cfg`):
    ```shell
    ...
    mods="@Exile;@AdminToolkitServer"
    servermods="@ExileServer"
    ...
    ```

8. Disable verifySignatures in `serverfiles/cfg/arma3server.server.cfg`, because this mod has no signatur.
9. Restart the arma 3 server:
    ```shell
    docker compose -f /home/admin/arma3/docker-compose.yml down
    docker compose -f /home/admin/arma3/docker-compose.yml up -d
    ```
9. Add the `@AdminToolkit` mod in the Arma 3 launcher to the mods.
10. Start you game, connect to the server and verify that it's working by pressing F2 and spawning yourself a helicoper or something like this.

### Mod: DMS with "Capture point" missions
* [youtube.com/watch?v=4syLDu9lIrM](https://www.youtube.com/watch?v=4syLDu9lIrM)
* [youtube.com/watch?v=z24natBw37c](https://www.youtube.com/watch?v=z24natBw37c)
