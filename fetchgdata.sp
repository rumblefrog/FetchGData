/**
MIT License

Copyright (c) 2017 RumbleFrog

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**/

#pragma semicolon 1

#define PLUGIN_AUTHOR "Fishy"
#define PLUGIN_VERSION "1.1.0"

#include <sourcemod>
#include <sdktools>
#include <smjansson>
#tryinclude <tf2>

#pragma newdecls required

char sModName[64];

public Plugin myinfo = 
{
	name = "FetchGData",
	author = PLUGIN_AUTHOR,
	description = "Fetch player data",
	version = PLUGIN_VERSION,
	url = "https://keybase.io/rumblefrog"
};

public void OnPluginStart()
{
	RegAdminCmd("sm_gdata", GData, 0, "Fetch player data");
	RegAdminCmd("sm_gdatatf", GDataTF, 0, "Fetch team and player data for team fortress 2");
	
	GetGameFolderName(sModName, sizeof(sModName));
}

public Action GData(int client, int args)
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
	
	CloseHandle(jObj);
	
	return Plugin_Handled;
}

public Action GDataTF(int client, int args)
{
	if (!StrEqual(sModName, "tf"))
	{
		ReplyToCommand(client, "Unsupported Game");
		return Plugin_Handled;
	}
	
	Handle jObj = json_object();
	char sJson[4096];
	
	Handle jScore = json_object();
	json_object_set_new(jScore, "blue", json_integer(GetTeamScore(view_as<int>(TFTeam_Blue))));
	json_object_set_new(jScore, "red", json_integer(GetTeamScore(view_as<int>(TFTeam_Red))));
	
	Handle jTeams = json_object();
	
	Handle jTeamBlue = json_object();
	Handle jTeamRed = json_object();
	Handle jTeamSpectator = json_object();
	Handle jTeamUnassigned = json_object();
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			char ID[64];
			char Player_Name[MAX_NAME_LENGTH];
			
			GetClientAuthId(i, AuthId_SteamID64, ID, sizeof(ID));
			GetClientName(i, Player_Name, sizeof(Player_Name));
			
			if (GetClientTeam(i) == view_as<int>(TFTeam_Blue))
				json_object_set_new(jTeamBlue, ID, json_string(Player_Name));
				
			if (GetClientTeam(i) == view_as<int>(TFTeam_Red))
				json_object_set_new(jTeamRed, ID, json_string(Player_Name));
				
			if (GetClientTeam(i) == view_as<int>(TFTeam_Spectator))
				json_object_set_new(jTeamSpectator, ID, json_string(Player_Name));
				
			if (GetClientTeam(i) == view_as<int>(TFTeam_Unassigned))
				json_object_set_new(jTeamUnassigned, ID, json_string(Player_Name));
		}
	}
	
	json_object_set_new(jObj, "scores", jScore);
	json_object_set_new(jTeams, "blue", jTeamBlue);
	json_object_set_new(jTeams, "red", jTeamRed);
	json_object_set_new(jTeams, "spectator", jTeamSpectator);
	json_object_set_new(jTeams, "unassigned", jTeamUnassigned);
	json_object_set_new(jObj, "teams", jTeams);
	
	json_dump(jObj, sJson, sizeof(sJson));
	
	PrintToConsole(client, "%s", sJson);
	
	CloseHandle(jObj);
	
	return Plugin_Handled;
}
