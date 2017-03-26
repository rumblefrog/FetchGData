# FetchGData [![Build Status](https://travis-ci.org/RumbleFrog/FetchGData.svg?branch=master)](https://travis-ci.org/RumbleFrog/FetchGData)
Return to console a multidimensional JSON encoded array of basic game information. Perfect for basic server listing on web end.

# Usage
sm_gdata

sm_gdata_players

# Prerequisite

- [SMJansson Extension](https://forums.alliedmods.net/showthread.php?t=184604)
- [SteamTools Extension](https://builds.limetech.io/?p=steamtools) (Optional but recommended)

# Example Outputs

### sm_gdata

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

### sm_gdata_players

```
{"76561198114606863":"Fishy | MaxDB.NET"}
```


# Download 

Download the latest version from the [release](https://github.com/RumbleFrog/FetchGData/releases) page

# License

MIT
