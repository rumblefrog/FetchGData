/**
MIT License

Copyright (c) 2017 RumbleFrog

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**/

#pragma semicolon 1

#define PLUGIN_AUTHOR "Fishy"
#define PLUGIN_VERSION "1.0.0"

#include <sourcemod>
#include <sdktools>
#include <smjansson>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "FetchPData",
	author = PLUGIN_AUTHOR,
	description = "Fetch player data",
	version = PLUGIN_VERSION,
	url = "https://keybase.io/rumblefrog"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_pdata", PData, 0, "Fetch player data");
}

public Action PData(int client, int args)
{
	Handle jObj = json_object();
	char sJson[4096];
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			char ID[64];
			char Player_Name[MAX_NAME_LENGTH];
			
			GetClientAuthId(i, AuthId_SteamID64, ID, sizeof(ID));
			GetClientName(i, Player_Name, sizeof(Player_Name));
			
			json_object_set_new(jObj, ID, json_string(Player_Name));
		}
	}
	
	json_dump(jObj, sJson, sizeof(sJson));
	
	PrintToConsole(client, "%s", sJson);
	
	return Plugin_Handled;
}
