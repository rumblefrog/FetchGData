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
    "info": {
        "description": "Team Fortress",
        "ip": "208.167.243.91",
        "map": "tfdb_greybox",
        "maxplayers": 20,
        "players": 2,
        "vac": true
    },
    "players": {
        "76561198114606863": "Fishy | MaxDB.NET"
    },
    "scores": {
        "blue": 2,
        "red": 0
    },
    "teams": {
        "blue": {},
        "red": {},
        "spectator": {},
        "unassigned": {
            "76561198114606863": "Fishy | MaxDB.NET"
        }
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
    "info": {
        "description": "Team Fortress",
        "ip": "208.167.243.91",
        "map": "tfdb_blucourt_intox",
        "maxplayers": 20,
        "players": 2,
        "vac": true
    },
    "players": {
        "76561198114606863": "Fishy | MaxDB.NET"
    },
    "scores": {
        "blue": 0,
        "red": 0
    },
    "teams": {
        "blue": {},
        "red": {},
        "spectator": {
            "76561198114606863": {
                "2LC_Country": "US",
                "3LC_Country": "USA",
                "Full_Country": "United States",
                "damage": 0,
                "deaths": 0,
                "dominations": 0,
                "f2p": false,
                "frags": 0,
                "latency": 0.041514847427606583,
                "name": "Fishy | MaxDB.NET",
                "streaks": 0,
                "time": 149.23020935058594
            }
        },
        "unassigned": {}
    }
}

```

# Download 

Download the latest version from the [release](https://github.com/RumbleFrog/FetchGData/releases) page

# License

GPL 3.0
