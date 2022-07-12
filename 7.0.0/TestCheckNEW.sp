#include <sourcemod>  
#include <sdktools>      
#include <sdkhooks>      
#include <cstrike>              
#include <surftimer>                   
#include <colors> 
#include <geoipcity>  

#define PERFIX "\x05[\x04SurfTimer\x05] \x01 -"     
#define MAX_CP 20
#define MAX_CP_B 55               
#define PLUGIN_VERSION "6.0.1.6"  // + multilanguage    

new Handle:DB = INVALID_HANDLE;
new Handle:CpSetterTimer = INVALID_HANDLE;     
new Handle:Hand_RightHudTimer = INVALID_HANDLE;

new String:Model_Police[PLATFORM_MAX_PATH] = "models/police.mdl";

new String:currentMap[64];
new String:sound[PLATFORM_MAX_PATH] = "ambient/tones/elev1.wav";
new String:sound2[PLATFORM_MAX_PATH] = "bot/whos_the_man.wav";
new String:sound3[PLATFORM_MAX_PATH] = "ui/achievement_earned.wav";
new String:sound4[PLATFORM_MAX_PATH] = "bot/very_nice.wav";
new String:sound5[PLATFORM_MAX_PATH] = "bot/oh_man.wav";
new String:sound6[PLATFORM_MAX_PATH] = "bot/oh_yea2.wav";   

new String:BestMap[44];               
new Float:BestTime; 
new String:BestMapSteam[32]; 
new String:BestMapMe[MAXPLAYERS+1][12];

new String:BestStage[MAX_CP][44];
new String:BestStageMe[MAXPLAYERS+1][MAX_CP][12];
new Float:BestStageTime[MAX_CP] = 999999.0;  

new bool:EnableSurfTimerMap = false;    
new bool:SurfLevel = false;
new bool:SurfBonus = false;
new bool:EnableStage[MAXPLAYERS+1] = false;    
new bool:HidePlayers[MAXPLAYERS+1] = false;   

new ChatRank[MAXPLAYERS+1] = { 1000, ... };
new tier;      
new PointsTop10[11] = { 150, 93, 66, 49, 40, 33, 27, 22, 18, 15, 0 };  
new String:BanList[2][32] = { "STEAM_0:1:20108081", "STEAM_0:1:16812" }

new Timeleft; 

#include "ss/Check.sp"
#include "ss/AdminMenu.sp"     
#include "ss/SurfLevel.sp"
#include "ss/Bonus.sp"      
#include "ss/Timer.sp"
#include "ss/Tele.sp"
#include "ss/Query.sp"             
#include "ss/Comm.sp"    
#include "ss/Advert.sp"
#include "ss/Top10.sp"
#include "ss/Help.sp"
#include "ss/Adminka.sp"          

public Plugin:myinfo = 
{ 
	name = "SurfTimer",
	author = "InC",
	description = "Surf timer for cs:source",
	version = PLUGIN_VERSION,
	url = "http://***/"                 
}  

public OnPluginStart(){ 
	CreateConVar("sm_surftimer_version", PLUGIN_VERSION, "SurfTimer Version!", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	HookEntityOutput("trigger_multiple","OnStartTouch",OnStartTouch);    
	HookEntityOutput("trigger_multiple","OnEndTouch",OnEndTouch);  
	
	RegAdminCmd("sm_menusurf", Command_AdminMenu, ADMFLAG_ROOT);
	RegAdminCmd("sm_noclipme", Command_Noclip, ADMFLAG_ROOT);
	RegAdminCmd("sm_changemap", Command_ChangeMap, ADMFLAG_ROOT);
	RegAdminCmd("sm_reload", Command_Reload, ADMFLAG_ROOT);
	RegAdminCmd("sm_fix", Command_fix, ADMFLAG_ROOT);
	RegAdminCmd("sm_extend", Command_PreVoteExtend, ADMFLAG_ROOT);
	
	HookEvent("round_end",  EventClear_Timer, EventHookMode_Pre);
	HookEvent("player_death",  EventClear_Timer, EventHookMode_Pre);
	HookEvent("player_disconnect", EventClear_Timer, EventHookMode_Pre);
	HookEvent("player_connect", Event_player_connect, EventHookMode_Pre);
	HookEvent("player_spawn", Event_player_spawn);
	HookEvent("round_start",  Event_Round_Start, EventHookMode_Post);
	
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say);
	RegConsoleCmd("sm_pr", Command_PrPlayer);
	RegConsoleCmd("sm_rank", Command_RankPlayer);
	RegConsoleCmd("sm_stage", Command_Stage);   
	RegConsoleCmd("sm_top", Command_Top); 
	RegConsoleCmd("sm_top10", Command_Top); 
	RegConsoleCmd("sm_mtop", Command_Mtop);
	RegConsoleCmd("sm_surftop", Command_Surftop);
	RegConsoleCmd("joinclass", Command_AutoRespawn);  
	
	g_AdminMenu = AdminMenu();

	creat_DB();                   
	
	LoadTranslations("common.phrases");
	LoadTranslations("surftimer.phrases");     
}

public OnPluginEnd()
{
	UnhookEntityOutput("trigger_multiple","OnStartTouch",OnStartTouch);
	UnhookEntityOutput("trigger_multiple","OnEndTouch",OnEndTouch);
}

public OnMapStart(){
	GetCurrentMap(currentMap, sizeof(currentMap));            
	
	BeamSpriteFollow = PrecacheModel("materials/sprites/laserbeam.vmt");
	PrecacheModel(Model_Police, true); 
	PrecacheSound(sound, true);
	PrecacheSound(sound2, true);
	PrecacheSound(sound3, true);       
	PrecacheSound(sound4, true);           
	PrecacheSound(sound5, true);       
	PrecacheSound(sound6, true);                        
	
	for (new cpr = 0; cpr < MAX_CP; cpr++) 
	{
		trigger[cpr] = -1;      
	}
	
	NumLvl = 1;
	strip = 0.0;  
	
	Command_GetPlayers();
	Command_GetTeleport();
	Command_GetMapUroven();
	Command_Advert();   
	VivodRecordLvl();
	
	//Authentication();                 
	
	if(Hand_RightHudTimer != INVALID_HANDLE) { KillTimer(Hand_RightHudTimer); Hand_RightHudTimer = INVALID_HANDLE; }
	Hand_RightHudTimer = CreateTimer(2.5, RightHudTimer, _, TIMER_REPEAT);
}

public OnMapEnd(){ 
	if(Hand_RightHudTimer != INVALID_HANDLE) { KillTimer(Hand_RightHudTimer); Hand_RightHudTimer = INVALID_HANDLE; }
}

public creat_DB()
{
	new String:error[255];
	DB = SQLite_UseDatabase("surftimer_v_5063", error, sizeof(error));            
	
	if (DB == INVALID_HANDLE) { PrintToServer("TIMER Creat Base Error: %s", error); }   
	else 
	{  
		SQL_LockDatabase(DB);   
		SQL_FastQuery(DB, "CREATE TABLE IF NOT EXISTS 'Players' (map TEXT, name TEXT DEFAULT 'None', time TEXT DEFAULT 'None', runtime float NOT NULL DEFAULT 999999.0, steamid TEXT DEFAULT 'STEAM_0:0:000000');");
		SQL_FastQuery(DB, "CREATE TABLE IF NOT EXISTS 'Rank' (name TEXT DEFAULT '-----', steamid TEXT DEFAULT 'STEAM_0:0:000000', points int(12) NOT NULL DEFAULT 0, country TEXT DEFAULT 'unknown', wr int(12) NOT NULL DEFAULT 0, top10 int(12) NOT NULL DEFAULT 0);");
		SQL_FastQuery(DB, "CREATE TABLE IF NOT EXISTS 'lvl' (map TEXT, steamid TEXT DEFAULT 'STEAM_0:0:000000', lvl int(12) NOT NULL DEFAULT 0, runtime float NOT NULL DEFAULT 999999.0, time TEXT DEFAULT '-----', name TEXT DEFAULT '-----');"); 
		SQL_UnlockDatabase(DB); 
	} 
}

public Action:Command_fix(client, args)  
{
	decl String:query[200];
	decl String:steamId[32];
	Format(query, sizeof(query), "SELECT * FROM 'lvl' WHERE map = '%s' AND lvl = %i AND runtime < 9999.0 ORDER BY runtime LIMIT 0, 1;", currentMap, LvlZone[client]+1);        
	new Handle:result = SQL_Query(DB, query);
	if(SQL_FetchRow(result)) {   
		SQL_FetchString(result,1,steamId,32);
		Format(query, sizeof(query), "UPDATE 'lvl' SET runtime = '5500.0', time = '99:00.00' WHERE map = '%s' AND steamid = '%s' AND lvl = %i;", currentMap, steamId, LvlZone[client]+1);
		SQL_TQuery(DB, SQLErrorCheckCallback, query);
		PrintToChat(client, "%s", query);
	}
	CloseHandle(result);
} 

public Action:Command_Noclip(client, args)     
{
	new MoveType:movetype = GetEntityMoveType(client);   
	if (movetype != MOVETYPE_NOCLIP) { SetEntityMoveType(client, MOVETYPE_NOCLIP); PrintCenterText(client, "on"); }
	else { SetEntityMoveType(client, MOVETYPE_WALK); PrintCenterText(client, "off"); }
	return Plugin_Handled;
}

public Action:Command_Reload(client, args)       
{
	ServerCommand("sm plugins reload TestCheckNEW");   
}

public Action:Command_ChangeMap(client, args)       
{
	ServerCommand("changelevel %s", currentMap);
}

public Action:Command_GetMapUroven() 
{
	new Handle:kv;             
	new String:file[512];
	kv = CreateKeyValues("test_ept");
	BuildPath(Path_SM, file, sizeof(file), "configs/surftimer/tier.ini"); 
	FileToKeyValues(kv, file);
	if(KvJumpToKey(kv, currentMap)) { tier = KvGetNum(kv, "tier"); }
	else { tier = 3; }
	if (!tier) { tier = 3; }
	CloseHandle(kv);
}

public Action:Command_GetPlayers()   
{
	new String:query[512];   
	Format(query, sizeof(query), "SELECT * FROM 'Players' WHERE map ='%s' ORDER BY runtime LIMIT 0, 1", currentMap);
	SQL_TQuery(DB, SQL_ProcessQueryGetPlayers, query);
}

public Action:Command_GetTeleport()
{
	ProcessTele();
}

public Action:EventClear_Timer(Handle:event, const String:name[], bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));    
	Clear_All(client);
	return Plugin_Continue; 
}  

public Clear_All(client)        
{
	Startoval[client] = false;
	InLvl[client] = false;
	Surfing[client] = false;
	LvlZone[client] = 1;
	EnableStage[client] = false;
	EnabBonus[client] = false;
}

public Action:Event_player_spawn(Handle:event, const String:name[], bool:dontBroadcast){
	new client = GetClientOfUserId(GetEventInt(event, "userid"));     
	if (EnableSurfTimerMap)
	{  
		Clear_All(client);
	}
	new ent = GetPlayerWeaponSlot(client, 0);  
	if(ent > 0) { RemovePlayerItem(client, ent); }
	ent = GetPlayerWeaponSlot(client, 1);
	if(ent > 0) { RemovePlayerItem(client, ent); }  
	ent = GetPlayerWeaponSlot(client, 2);
	if(ent > 0) { RemovePlayerItem(client, ent); }   
	
	if (ChatRank[client] == 1) SetEntityModel(client, Model_Police);  
	
	return Plugin_Continue;
}

public OnClientPostAdminCheck(client)    
{
	if (IsFakeClient(client))
		return;
	
	decl String:ip[16];   
	decl String:city[45]; 
	decl String:region[45];     
	decl String:country[45];
	decl String:ccode[3];
	decl String:ccode3[4];
	decl String:Name[32];
	decl String:safe_uname[32];  
	decl String:steamId[32];
	decl String:query[320];
	
	GetClientIP(client, ip, sizeof(ip));
	GetClientName(client, Name, sizeof(Name)); 
	SQL_EscapeString(DB, Name, safe_uname, sizeof(safe_uname));
	GetClientAuthString(client, steamId, sizeof(steamId));
	
	if (StrEqual(steamId, BanList[0]) || StrEqual(steamId, BanList[1]) || StrEqual(steamId, BanList[1])) { KickClient(client, "Sorry. But this server for noobs =)"); return; } /////////// * BANLIST *
	
	//if (StrContains(Name, "ksf", true) > -1) { KickClient(client, "Sorry. But this server for noobs =)"); return; }
	
	if(GeoipGetRecord(ip, city, region, country, ccode, ccode3)) { PrintToChatAll("\x05[\x04SurfTimer\x05] - \x01%s \x05вступает в игру \x01%s.", Name, country); }
	else { PrintToChatAll("\x05[\x04SurfTimer\x05] - \x01%s вступает в игру.", Name); }
	
	Format(query, sizeof(query), "SELECT * FROM 'Rank' WHERE steamid ='%s'", steamId);        
	new Handle:result = SQL_Query(DB, query);
	if(!SQL_FetchRow(result)) {   
		Format(query, sizeof(query), "INSERT INTO 'Rank' (name, steamid, points, country) VALUES ('%s', '%s', 0, '%s');", safe_uname, steamId, ccode3); SQL_TQuery(DB, SQLErrorCheckCallback, query);
		ChatRank[client] = 1000;
		if (SurfLevel) { for (new stage = 1; stage <= MAX_CP; stage++) { Format(BestStageMe[client][stage - 1], 12, "None"); } }
		Format(BestMapMe[client], 12, "None");
		return;
	}
	CloseHandle(result);
	
	Format(query, sizeof(query), "SELECT * FROM 'Players' WHERE map ='%s' AND steamid ='%s'", currentMap, steamId);
	SQL_TQuery(DB, SQL_ProcessStartBestRecord, query, client);
	GangleChatRank(client);
	//Command_Help(client);      
	//Command_Help_KSF(client);   
}

public OnClientDisconnect(client)
{
	Rname_In_Database(client);
}
 
public Action:GangleChatRank(client) 
{
	decl String:query[200];
	decl String:steamId[32];
	new String:Auth_receive[32];
	GetClientAuthString(client, steamId, sizeof(steamId));
	new i;
	Format(query, sizeof(query), "SELECT * FROM 'Rank' WHERE points >= 0 ORDER BY points DESC"); 
	new Handle:result = SQL_Query(DB, query);
	while(SQL_HasResultSet(result) && SQL_FetchRow(result))
	{
		i++;
		SQL_FetchString(result,1,Auth_receive,32);
		if(StrEqual(Auth_receive, steamId, false)){
			break;
		} 
	}
	ChatRank[client] = i;
	CloseHandle(result);
}

public PanelHandlerNothing(Handle:menu, MenuAction:action, param1, param2) {
	//
}

public Action:Event_player_connect(Handle:event, const String:name[], bool:dontBroadcast)
{
	//SetEventBroadcast(event, true);
}

public Action:Event_Round_Start(Handle:event, const String:name[], bool:dontBroadcast){
	PrintToServer("Start Get Setting");
	Command_GetMap();
	Command_GetMapBonus();
}

stock bool:IsPlayer(client)
{
	return (client > 0 && client <= MaxClients); 
}

stock bool:IsActiveCl(client) 
{  
	if (!IsClientInGame(client))   
		return false;
	if (!IsPlayerAlive(client))  
		return false;      
	if (GetClientTeam(client) < 1)              
		return false;
	return true;
}

public ChangeMap(Time_l)
{
	new String:NextMap[64];
	new Float:time = Time_l + 0.1;
	GetNextMap(NextMap, 64);
	PrintToChatAll("\x05[\x04SurfTimer\x05] \x01- \x05Карта закончится через \x01%i \x05секунд. Следующая карта \x01%s", Time_l, NextMap);
	CreateTimer(time, Endgametimer, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Endgametimer(Handle:timer,any:client)   
{
	ServerCommand("sm plugins reload TestCheckNEW");
	Game_End();
}

public Action:Command_HidePlayer(client){ 
	if (HidePlayers[client]) { HidePlayers[client] = false; PrintToChat(client, "\x05[\x04SurfTimer\x05] \x01- \x05Unide players"); }
	else { HidePlayers[client] = true; PrintToChat(client, "\x05[\x04SurfTimer\x05] \x01- \x05Hide players"); }
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_SetTransmit, OnTransmit);
}

public Action:OnTransmit(entity, client)
{
	if(entity != client && HidePlayers[client])
		return Plugin_Handled;
	
	return Plugin_Continue;
}