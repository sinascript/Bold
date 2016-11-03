# Bold
A simple telegram bot writed in lua based on [GroupButler](https://github.com/RememberTheAir/GroupButler) and [FileManager](https://github.com/SEEDTEAM/file-manager-bot)

**Requirements**
- `libreadline-dev`
- `redis-server`
- `lua5.2`
- `liblua5.2dev`
- `libssl-dev`
- `git`
- `luasocket-http`
- `luasocket.https`
- `curl`
- `serpent`

**Installation**
```bash
# Tested on Ubuntu 14.04, Ubuntu 15.04, Debian 7, Linux Mint 17.2, Ubuntu 16.4

$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get install libreadline-dev libssl-dev lua5.2 liblua5.2-dev git redis-server curl libcurl4-gnutls-dev lua-socket lua-sec luarocks

# We are going now to install LuaRocks and the required Lua modules

$ wget http://luarocks.org/releases/luarocks-2.2.2.tar.gz
$ tar zxpf luarocks-2.2.2.tar.gz
$ cd luarocks-2.2.2
$ ./configure; sudo make bootstrap
$ sudo luarocks install luasocket
$ sudo luarocks install luasec
$ sudo luarocks install redis-lua
$ sudo luarocks install lua-term
$ sudo luarocks install serpent
$ sudo luarocks install dkjson
$ cd ..

# Clone the repository and give the launch script permissions to be executed

$ git clone https://github.com/AviraTeam/Bold.git
$ cd Bold
$ sudo chmod 777 launch.sh
```

**First of all, take a look at your bot config:**

> • Make sure inline is enabled . Send `/setinline` to [@BotFather](http://telegram.me/BotFather) to enable inline mode in your bot.

**Before you do anything else, open config.lua (in a text editor) and make the following changes:**

> • Set `bot_api_key` to the authentication token that you received from [@BotFather](http://telegram.me/BotFather) in `config.lua`.
>
> • Set `admin` telegram id in `config.lua`.

# Developer :

[Mohammad Mahdi](https://github.com/mohammadarak) ([Telegram](https://telegram.me/mohammadarak))

### Our Telegram channels:

English: [@AviraTeam](https://telegram.me/AviraTeam)
