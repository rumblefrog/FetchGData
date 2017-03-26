/**
MIT License

Copyright (c) 2017 RumbleFrog

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**/

#pragma semicolon 1

#define PLUGIN_AUTHOR "Fishy"
#define PLUGIN_VERSION "1.1.2"

#include <sourcemod>
#include <sdktools>
#include <smjansson>
#tryinclude <tf2>
#tryinclude <steamtools>

#pragma newdecls required

char sModName[64];
char sIP[20];
char sDescription[64];
char sMap[64];

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
	RegAdminCmd("sm_gdata", GData, 0, "Fetch team and player data for team fortress 2");
	RegAdminCmd("sm_gdata_players", GDataPlayers, 0, "Fetch player data");
	
	GetGameFolderName(sModName, sizeof(sModName));
	GetServerIP(sIP, sizeof(sIP));
	GetGameDescription(sDescription, sizeof(sDescription));
	GetCurrentMap(sMap, sizeof(sMap));
}

public Action GData(int client, int args)
{
	if (!StrEqual(sModName, "tf"))
	{
		ReplyToCommand(client, "Unsupported Game");
		return Plugin_Handled;
	}
	
	Handle jObj = json_object();
	char sJson[8192];
	
	Handle jInfo = json_object();
	
	json_object_set_new(jInfo, "ip", json_string(sIP));
	json_object_set_new(jInfo, "players", json_integer(GetClientCount(false)));
	json_object_set_new(jInfo, "map", json_string(sMap));
	json_object_set_new(jInfo, "description", json_string(sDescription));
	
	
	Handle jScore = json_object();
	json_object_set_new(jScore, "blue", json_integer(GetTeamScore(view_as<int>(TFTeam_Blue))));
	json_object_set_new(jScore, "red", json_integer(GetTeamScore(view_as<int>(TFTeam_Red))));
	
	Handle jTeams = json_object();
	
	Handle jTeamBlue = json_object();
	Handle jTeamRed = json_object();
	Handle jTeamSpectator = json_object();
	Handle jTeamUnassigned = json_object();
	
	Handle jPlayers = json_object();
	
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
			
			json_object_set_new(jPlayers, ID, json_string(Player_Name));
		}
	}
	
	json_object_set_new(jObj, "info", jInfo);
	json_object_set_new(jObj, "scores", jScore);
	json_object_set_new(jTeams, "blue", jTeamBlue);
	json_object_set_new(jTeams, "red", jTeamRed);
	json_object_set_new(jTeams, "spectator", jTeamSpectator);
	json_object_set_new(jTeams, "unassigned", jTeamUnassigned);
	json_object_set_new(jObj, "teams", jTeams);
	json_object_set_new(jObj, "players", jPlayers);
	
	json_dump(jObj, sJson, sizeof(sJson));
	
	PrintToConsole(client, "%s", sJson);
	
	CloseHandle(jObj);
	
	return Plugin_Handled;
}

public Action GDataPlayers(int client, int args)
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

stock char GetServerIP(char[] IP, int size)
{
	if (LibraryExists("steamtools"))
	{
		int buffer[4];
		Steam_GetPublicIP(buffer);
		Format(IP, size, "%d.%d.%d.%d", buffer[0], buffer[1], buffer[2], buffer[3]);
	} else {

		int pieces[4];
		int longip = GetConVarInt(FindConVar("hostip"));
	
		pieces[0] = (longip >> 24) & 0x000000FF;
		pieces[1] = (longip >> 16) & 0x000000FF;
		pieces[2] = (longip >> 8) & 0x000000FF;
		pieces[3] = longip & 0x000000FF;
	
		Format(IP, size, "%d.%d.%d.%d", pieces[0], pieces[1], pieces[2], pieces[3]);
	}
}