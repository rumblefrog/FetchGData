/**
MIT License

Copyright (c) 2017 RumbleFrog

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**/

#pragma semicolon 1
#pragma dynamic 32768

#define PLUGIN_AUTHOR "Fishy"
#define PLUGIN_VERSION "1.2.7"

#define Web_ID "FetchGData"

#include <sourcemod>
#include <sdktools>
#include <smjansson>
#include <tf2>
#include <steamtools>
#include <webcon>
#include <geoip>

#pragma newdecls required

char sModName[64];
char sIP[20];
char sDescription[64];
char sMap[64];

bool bSteamTools;

WebResponse defaultResponse;

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
	if (!Web_RegisterRequestHandler(Web_ID, OnWebRequest, "FetchGData", "Fetch a multidimensional JSON encoded array of basic game information")) {
		SetFailState("Failed to register request handler.");
	}
	
	bSteamTools = LibraryExists("SteamTools");
	
	defaultResponse = new WebStringResponse("<!DOCTYPE html>\n<html><body><h1>404 Not Found</h1></body></html>");
	
	CreateConVar("fetchgdata_version", PLUGIN_VERSION, "FetchGData", FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY);
	
	GetGameFolderName(sModName, sizeof(sModName));
	GetGameDescription(sDescription, sizeof(sDescription));
	GetCurrentMap(sMap, sizeof(sMap));
}

public void OnAllPluginsLoaded()
{
	if (!bSteamTools || !Steam_IsConnected())
		GetServerIP(sIP, sizeof(sIP));
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "SteamTools"))
	{
		bSteamTools = true;
		GetServerIP(sIP, sizeof(sIP));
	}
}

public void OnMapStart()
{
	GetCurrentMap(sMap, sizeof(sMap));
}

public bool OnWebRequest(WebConnection connection, const char[] method, const char[] url)
{
	char address[WEB_CLIENT_ADDRESS_LENGTH];
	connection.GetClientAddress(address, sizeof(address));


	if (StrEqual(url, "/")) {
		char buffer[16384];
		
		GData(buffer, sizeof(buffer));
		
		WebResponse response = new WebStringResponse(buffer);
		bool success = connection.QueueResponse(WebStatus_OK, response);
		delete response;
		
		return success;
	} 

	if (StrEqual(url, "/players")) {
		char buffer[16384];
		
		GDataPlayers(buffer, sizeof(buffer));
		
		WebResponse response = new WebStringResponse(buffer);
		bool success = connection.QueueResponse(WebStatus_OK, response);
		delete response;
		
		return success;
	}

	if (StrEqual(url, "/extensive")) {
		char buffer[32768];
		
		GDataExtensive(buffer, sizeof(buffer));
		
		WebResponse response = new WebStringResponse(buffer);
		bool success = connection.QueueResponse(WebStatus_OK, response);
		delete response;
		
		return success;
	}

	return connection.QueueResponse(WebStatus_NotFound, defaultResponse);
}

void GData(char[] sJson, int iJson)
{
	if (!StrEqual(sModName, "tf"))
	{
		return;
	}
	
	Handle jObj = json_object();
	
	Handle jInfo = json_object();
	
	json_object_set_new(jInfo, "ip", json_string(sIP));
	json_object_set_new(jInfo, "players", json_integer(GetClientCount(false)));
	json_object_set_new(jInfo, "maxplayers", json_integer(GetMaxHumanPlayers()));
	json_object_set_new(jInfo, "map", json_string(sMap));
	json_object_set_new(jInfo, "description", json_string(sDescription));
	if (bSteamTools)
		json_object_set_new(jInfo, "vac", json_boolean(Steam_IsVACEnabled()));
	
	
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
	
	json_dump(jObj, sJson, iJson, 4, false, true);
	
	CloseHandle(jObj);
	
}

void GDataExtensive(char[] sJson, int iJson)
{
	if (!StrEqual(sModName, "tf"))
	{
		return;
	}
	
	Handle jObj = json_object();
	
	Handle jInfo = json_object();
	
	json_object_set_new(jInfo, "ip", json_string(sIP));
	json_object_set_new(jInfo, "players", json_integer(GetClientCount(false)));
	json_object_set_new(jInfo, "maxplayers", json_integer(GetMaxHumanPlayers()));
	json_object_set_new(jInfo, "map", json_string(sMap));
	json_object_set_new(jInfo, "description", json_string(sDescription));
	if (bSteamTools)
		json_object_set_new(jInfo, "vac", json_boolean(Steam_IsVACEnabled()));
	
	
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
		if (IsClientInGame(i) && !IsFakeClient(i) && IsClientConnected(i))
		{
			char ID[64];
			char Player_Name[MAX_NAME_LENGTH];
			char IP[64];
			
			char CountryFull[45];
			char Country3LC[4];
			char Country2LC[3];
			
			Handle jPlayer = json_object();
			
			GetClientAuthId(i, AuthId_SteamID64, ID, sizeof(ID));
			GetClientName(i, Player_Name, sizeof(Player_Name));
			GetClientIP(i, IP, sizeof(IP));
			
			GeoipCountry(IP, CountryFull, sizeof(CountryFull));
			GeoipCode3(IP, Country3LC);
			GeoipCode2(IP, Country2LC);
						
			json_object_set_new(jPlayer, "name", json_string(Player_Name));
			json_object_set_new(jPlayer, "frags", json_integer(GetClientFrags(i)));
			json_object_set_new(jPlayer, "deaths", json_integer(GetClientDeaths(i)));
			json_object_set_new(jPlayer, "dominations", json_integer(GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iActiveDominations", _, i)));
			json_object_set_new(jPlayer, "damage", json_integer(GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iDamage", _, i)));
			json_object_set_new(jPlayer, "latency", json_real(GetClientLatency(i, NetFlow_Both)));
			json_object_set_new(jPlayer, "streaks", json_integer(GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iStreaks", _, i)));
			json_object_set_new(jPlayer, "time", json_real(GetClientTime(i)));		
			if (bSteamTools)
				json_object_set_new(jPlayer, "f2p", json_boolean(Steam_CheckClientDLC(i, 459)));
			
			json_object_set_new(jPlayer, "Full_Country", json_string(CountryFull));
			json_object_set_new(jPlayer, "3LC_Country", json_string(Country3LC));
			json_object_set_new(jPlayer, "2LC_Country", json_string(Country2LC));
			
			
			if (GetClientTeam(i) == view_as<int>(TFTeam_Blue))
				json_object_set_new(jTeamBlue, ID, jPlayer);
				
			if (GetClientTeam(i) == view_as<int>(TFTeam_Red))
				json_object_set_new(jTeamRed, ID, jPlayer);
				
			if (GetClientTeam(i) == view_as<int>(TFTeam_Spectator))
				json_object_set_new(jTeamSpectator, ID, jPlayer);
				
			if (GetClientTeam(i) == view_as<int>(TFTeam_Unassigned))
				json_object_set_new(jTeamUnassigned, ID, jPlayer);
			
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
	
	json_dump(jObj, sJson, iJson, 4, false, true);
	
	
	CloseHandle(jObj);
}

public Action GDataPlayers(char[] sJson, int iJson)
{
	Handle jObj = json_object();
	
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
	
	json_dump(jObj, sJson, iJson, 4, false, true);
	
	CloseHandle(jObj);
}

public int Steam_SteamServersConnected()
{
	int buffer[4];
	Steam_GetPublicIP(buffer);
	Format(sIP, sizeof sIP, "%d.%d.%d.%d", buffer[0], buffer[1], buffer[2], buffer[3]);
}

public int Steam_FullyLoaded() {
	bSteamTools = true;
}

public int Steam_Shutdown() {
	bSteamTools = false;
}

stock char GetServerIP(char[] IP, int size)
{
	int pieces[4];
	int longip = GetConVarInt(FindConVar("hostip"));
	
	pieces[0] = (longip >> 24) & 0x000000FF;
	pieces[1] = (longip >> 16) & 0x000000FF;
	pieces[2] = (longip >> 8) & 0x000000FF;
	pieces[3] = longip & 0x000000FF;
	
	Format(IP, size, "%d.%d.%d.%d", pieces[0], pieces[1], pieces[2], pieces[3]);
}
