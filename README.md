# FetchPData [![Build Status](https://travis-ci.org/RumbleFrog/FetchPData.svg?branch=master)](https://travis-ci.org/RumbleFrog/FetchPData)
Return to console a JSON encoded array of SteamID64 and name pairs

# Usage
sm_pdata

sm_pdatatf (TF2 Only)

# Prerequisite

- SMJansson Extension (https://forums.alliedmods.net/showthread.php?t=184604)

# Example Outputs

### sm_pdata

```
{"76561198114606863":"Fishy | MaxDB.NET"}
```

### sm_pdatatf

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

Download the latest version from the [release](https://github.com/RumbleFrog/FetchPData/releases) page

# License
MIT
