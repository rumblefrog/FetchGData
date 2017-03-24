#pragma semicolon 1

#define PLUGIN_AUTHOR "Fishy"
#define PLUGIN_VERSION "1.00"

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
