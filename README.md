Dota Picker
===========
This project is designed to help you pick heros during Dota captain's mode.

Setup
-----
[Get your WebAPI key for Dota 2.](http://dev.dota2.com/showthread.php?t=47115)
The [API wrapper in Ruby](https://github.com/nashby/dota) might be useful.

Data References
---------------

### History details
"lobby_type":
0	all pick, all random
4 	bot
7	ranked
8 	1v1 solo mid


### Match details
"game_mode":
1: all pick
2: captains mode
18: ability draft
20: all random deathmatch