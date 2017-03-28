# FetchGData [![Build Status](https://travis-ci.org/RumbleFrog/FetchGData.svg?branch=master)](https://travis-ci.org/RumbleFrog/FetchGData)
An engine-independent web server that returns multidimensional JSON encoded arrays of basic game information. The limit is only your imagination.

# Endpoints
**/**

**/players**

**/extensive**

# Usage

1. Visit ServerIP:Port/FetchGData in your browser
2. Append any endpoints to the end of that URL

# Prerequisite

- [SMJansson Extension](https://forums.alliedmods.net/showthread.php?t=184604)
- [Webcon Extension](https://builds.limetech.io/?p=webcon)
- [SteamTools Extension](https://builds.limetech.io/?p=steamtools) **(Optional but recommended)**

# Example Outputs

### /

```
{
    "teams": {
        "unassigned": {},
        "blue": {},
        "red": {},
        "spectator": {
            "76561198114606863": "Fishy | MaxDB.NET"
        }
    },
    "info": {
        "map": "tfdb_octagon",
        "ip": "208.167.243.91",
        "players": 2,
        "description": "Team Fortress"
    },
    "players": {
        "76561198114606863": "Fishy | MaxDB.NET"
    },
    "scores": {
        "blue": 0,
        "red": 0
    }
}
```

### /players

```
{"76561198114606863":"Fishy | MaxDB.NET"}
```

### /extensive

```
{
   "teams":{
      "unassigned":{},
      "blue":{},
      "red":{},
      "spectator":{
         "76561198114606863":{
            "frags":0,
            "name":"Fishy | MaxDB.NET",
            "latency":0.058590669184923172,
            "streaks":0,
            "dominations":0
         }
      }
   },
   "info":{
      "map":"tfdb_blucourt_intox",
      "ip":"208.167.243.91",
      "maxplayers":20,
      "players":2,
      "description":"Team Fortress"
   },
   "players":{
      "76561198114606863":"Fishy | MaxDB.NET"
   },
   "scores":{
      "blue":0,
      "red":0
   }
}
```

# Download 

Download the latest version from the [release](https://github.com/RumbleFrog/FetchGData/releases) page

# License

MIT
