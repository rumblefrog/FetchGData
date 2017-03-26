# FetchPData [![Build Status](https://travis-ci.org/RumbleFrog/FetchGData.svg?branch=master)](https://travis-ci.org/RumbleFrog/FetchGData)
Return to console a JSON encoded array of SteamID64 and name pairs

# Usage
sm_gdata

sm_gdatatf (TF2 Only)

# Prerequisite

- SMJansson Extension (https://forums.alliedmods.net/showthread.php?t=184604)

# Example Outputs

### sm_gdata

```
{"76561198114606863":"Fishy | MaxDB.NET"}
```

### sm_gdatatf

```
{
    "scores": {
        "blue": 1,
        "red": 0
    },
    "teams": {
        "unassigned": {
            "76561198114606863": "Fishy | MaxDB.NET"
        },
        "blue": {},
        "red": {},
        "spectator": {}
    }
}
```


# Download 

Download the latest version from the [release](https://github.com/RumbleFrog/FetchGData/releases) page

# License
MIT
