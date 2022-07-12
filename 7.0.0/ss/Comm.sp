
public Action:Command_Say(client, args) 
{
	new String:szText[192]; GetCmdArgString(szText, sizeof(szText)); new startarg = 0; 
	if (szText[0] == '"') 
	{ 
		startarg = 1; new szTextlen = strlen(szText);  
		if (szText[szTextlen-1] == '"') { szText[szTextlen-1] = '\0'; } 
	}  
	
	if(StrEqual(szText[startarg], "!tele") || StrEqual(szText[startarg], "!teleport")) { Command_Teleport(client, args); return Plugin_Handled; }
	if(StrEqual(szText[startarg], "!goback")) { Command_Goback(client, args); }
	if(StrEqual(szText[startarg], "!restart")) { Command_Restart(client, args); return Plugin_Handled; }
	if(StrEqual(szText[startarg], "!spawn") || StrEqual(szText[startarg], "!respawn") || StrEqual(szText[startarg], "respawn")) { Command_Respawn(client, args); return Plugin_Handled; }
	if(StrEqual(szText[startarg], "!bonus")) { Command_NotFund(client, args); }
	if(StrEqual(szText[startarg], "!pc") || StrEqual(szText[startarg], "!rr")) { Command_NotFund(client, args); }
	if(StrEqual(szText[startarg], "!spec")) { Command_NotFund(client, args); }
	if(StrEqual(szText[startarg], "!sr")) { Command_SR(client, args); }
	if(StrEqual(szText[startarg], "!wr")) { PrintToChat(client, "\x05[\x04SurfTimer\x05] \x01- \x05Рекорд карты: %s", BestMap); }
	if(StrEqual(szText[startarg], "!op")) { Command_OnlinePlayers(client); }
	if(StrEqual(szText[startarg], "!help") || StrEqual(szText[startarg], "!info") || StrEqual(szText[startarg], "!surf") || StrEqual(szText[startarg], "!Info")) { Command_Help(client); }
	if(StrEqual(szText[startarg], "!hide")) { Command_HidePlayer(client); }
	if(StrEqual(szText[startarg], "!top10help")) { Command_Help_Top10Poins(client); }
	if(StrEqual(szText[startarg], "!chatranks")) { Command_Help_ChatRanks(client); }
	
	new String:szParts[2][32]; ExplodeString(szText[startarg], " ", szParts, 2, 32);
	if (strcmp(szParts[0],"bug",false) == 0) { PrintBugs(client, args); return Plugin_Handled; }
	
	//************************************************************************************************************* CHATRANKS *************************************************************
	decl String:name[32]; GetClientName(client, name, sizeof(name));
	
	if (IsPlayerAlive(client))
	{
		if (ChatRank[client] <= 5) { CPrintToChatAllEx(client,"{green}[{teamcolor}PRO{green}] {teamcolor}%s : {green}%s",name, szText[startarg]); }
		else if (ChatRank[client] > 5 && ChatRank[client] <= 10) { CPrintToChatAllEx(client,"{teamcolor}[\x05BEST{teamcolor}] {teamcolor}%s : {default}%s",name, szText[startarg]); }
		else if (ChatRank[client] > 10 && ChatRank[client] <= 20) { CPrintToChatAllEx(client,"{green}[Surfer] {teamcolor}%s : {default}%s",name, szText[startarg]); }
		else if (ChatRank[client] > 20 && ChatRank[client] <= 30) { CPrintToChatAllEx(client,"{teamcolor}[{default}Recruit{teamcolor}] {teamcolor}%s : {default}%s",name, szText[startarg]); }
		else { CPrintToChatAllEx(client,"{default}[NooB] {teamcolor}%s : {default}%s",name, szText[startarg]); }
	}
	else
	{
		if (ChatRank[client] <= 5) { CPrintToChatAllEx(client,"*DEAD*{green}[{teamcolor}PRO{green}] {teamcolor}%s : {green}%s",name, szText[startarg]); }
		else if (ChatRank[client] > 5 && ChatRank[client] <= 10) { CPrintToChatAllEx(client,"*DEAD*{teamcolor}[\x05BEST{teamcolor}] {teamcolor}%s : {default}%s",name, szText[startarg]); }
		else if (ChatRank[client] > 10 && ChatRank[client] <= 20) { CPrintToChatAllEx(client,"*DEAD*{green}[Surfer] {teamcolor}%s : {default}%s",name, szText[startarg]); }
		else if (ChatRank[client] > 20 && ChatRank[client] <= 30) { CPrintToChatAllEx(client,"*DEAD*{teamcolor}[{default}Recruit{teamcolor}] {teamcolor}%s : {default}%s",name, szText[startarg]); }
		else { CPrintToChatAllEx(client,"*DEAD*{default}[NooB] {teamcolor}%s : {default}%s",name, szText[startarg]); }
	}
	
	return Plugin_Handled;
	//************************************************************************************************************ /CHATRANKS *************************************************************
}

public Action:PrintBugs(client, args){ 
	new String:Print[512];
	new String:path[PLATFORM_MAX_PATH];
	new Handle:BugLog;
	new String:Name[MAX_NAME_LENGTH];
	decl String:text[192];
	decl String:message[192];
	BuildPath(Path_SM, path, sizeof(path), "logs/surf.ini");
	GetClientName(client, Name, sizeof(Name));
	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);
	strcopy(message, 192, text);
	BugLog = OpenFile(path, "a+");
	Format(Print, sizeof(Print), "%s - %s\n%s\n ", currentMap, Name, message); 
	WriteFileLine(BugLog, Print);
	CloseHandle(BugLog);
	PrintToChat(client, "Спасибо за указание ошибки!");
}

public Action:Command_NotFund(client, args)
{
	CPrintToChat(client, "%t", "NotFund");
}

public Action:Command_OnlinePlayers(client) //********************************** ONLINE PLAYERS **********************
{
	decl String:name[512];
	new Handle:Zone2 = CreateMenu(MenuO);
	SetMenuTitle(Zone2, "%t", "OnlinePlayers");
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
		{
			GetClientName(i, name, sizeof(name)); AddMenuItem(Zone2, name, name);
		}
	}
	DisplayMenu(Zone2, client, 15);
}

public MenuO(Handle:Zone2, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		decl String:info[512];
		GetMenuItem(Zone2, param2, info, sizeof(info));
		
		new tar = FindTarget(0, info, true);
		new Handle:pack = CreateDataPack(); WritePackCell(pack, param1); WritePackCell(pack, tar);
		decl String:query[200]; Format(query, sizeof(query), "SELECT * FROM 'Rank' WHERE points >= 0 ORDER BY points DESC"); SQL_TQuery(DB, SQL_ProcessQuery_OnlineRank, query, pack);
	}
}

public Action:Command_RankPlayer(client, args) //****************************** RANK SEARCH **********************
{ 
	if (!args) { Command_Rank(client, client); return Plugin_Handled; }
		
	decl String:arg1[32]; GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH]; new target_list[MAXPLAYERS], target_count; new bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString( arg1, 0, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0) { ReplyToCommand(client, "No players found..."); return Plugin_Handled; }
	
	for (new i = 0; i < target_count; i++)
	{
		if (!IsFakeClient(target_list[i]))
		{
			Command_Rank(client, target_list[i]);
		}
	}
	return Plugin_Handled;
}

public Action:Command_PrPlayer(client, args) //********************************** PR SEARCH **********************
{ 
	if (!args) { Command_PR(client, client); return Plugin_Handled; }
	
	decl String:arg1[32]; GetCmdArg(1, arg1, sizeof(arg1));
	new String:target_name[MAX_TARGET_LENGTH]; new target_list[MAXPLAYERS], target_count; new bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString( arg1, 0, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) <= 0) { ReplyToCommand(client, "No players found..."); return Plugin_Handled; }
	
	for (new i = 0; i < target_count; i++)
	{
		if (!IsFakeClient(target_list[i]))
			Command_PR(client, target_list[i]);
	}
	return Plugin_Handled;
}

public Action:Command_PR(client, terget) //********************************** PR **********************
{
	decl String:query[320];
	decl String:buffer[200];
	decl String:steamId[32];
	decl String:Auth_receive[32];
	decl String:Time_Lvl[12];
	decl String:Name[32];
	new Handle:result;
	new Handle:menuPR = CreateMenu(menuee);
	new rank_Map;
	new rank_Stage;
	new i;
	
	GetClientAuthString(terget, steamId, sizeof(steamId));
	GetClientName(terget, Name, sizeof(Name));
	
	if (!SurfLevel) { SetMenuPagination(menuPR, MENU_NO_PAGINATION); }
	
	Format(query, sizeof(query), "SELECT steamid FROM 'Players' WHERE map ='%s' AND runtime < 9999 ORDER BY runtime", currentMap);
	result = SQL_Query(DB, query);
	
	while(SQL_HasResultSet(result) && SQL_FetchRow(result)) {
		SQL_FetchString(result, 0, Auth_receive, 32);
		rank_Map++;
		if(StrEqual(Auth_receive, steamId, false)){ break; }
	}
	
	if(StrEqual(BestMapMe[terget], "None")) { Format(buffer, sizeof(buffer), "Time %s:\n \n  [MapTime] - %s\n ", Name, BestMapMe[terget]); }
	else { Format(buffer, sizeof(buffer), "Time %s:\n \n  [MapTime] - %s - [%i/%i]\n ", Name, BestMapMe[terget], rank_Map, SQL_GetRowCount(result));  }
	
	SetMenuTitle(menuPR, buffer);
	
	if (SurfLevel)
	{
		Format(query, sizeof(query), "SELECT lvl FROM 'lvl' WHERE map ='%s' AND steamid ='%s'", currentMap, steamId);
		result = SQL_Query(DB, query);
		
		while(SQL_HasResultSet(result) && SQL_FetchRow(result))
		{
			new level = SQL_FetchInt(result, 0);
			Format(query, sizeof(query), "SELECT steamid,time FROM 'lvl' WHERE map ='%s' AND lvl =%i ORDER BY runtime", currentMap, level);
			new Handle:result_L = SQL_Query(DB, query);
			rank_Stage = 0;
			while(SQL_HasResultSet(result_L) && SQL_FetchRow(result_L))
			{
				SQL_FetchString(result_L, 0, Auth_receive, 32); 
				rank_Stage++;
				if(StrEqual(Auth_receive, steamId, false)){ SQL_FetchString(result_L, 1, Time_Lvl, sizeof(Time_Lvl)); break; }
			}
			
			Format(buffer, sizeof(buffer), "[Stage %i] - %s - [%i/%i]", level - 1, Time_Lvl, rank_Stage, SQL_GetRowCount(result_L));
			AddMenuItem(menuPR, "", buffer);
			i++;
			CloseHandle(result_L);
		}
		new numItem = NumLvl - i;
		if (numItem > 0)
		{
			for (new item = 1; item <= numItem; item++)
			{
				AddMenuItem(menuPR, "", "none", ITEMDRAW_DISABLED);
			}
		}
	}
	else { AddMenuItem(menuPR, "", "Exit"); }
	
	CloseHandle(result);
	DisplayMenu(menuPR, client, 25);
}

public Action:Command_Rank(client, target) //********************************** RANK **********************
{
	new Handle:result;
	decl String:name[32];
	decl String:Auth_receive[32];
	decl String:auth[32];
	decl String:query[200];
	new Point;
	new Rank;
	
	GetClientAuthString(target, auth, sizeof(auth));
	GetClientName(target, name, sizeof(name));
	
	new Handle:pack = CreateDataPack(); WritePackCell(pack, client); WritePackCell(pack, target);
	Format(query, sizeof(query), "SELECT * FROM 'Rank' WHERE points >= 0 ORDER BY points DESC"); SQL_TQuery(DB, SQL_ProcessQuery_OnlineRank, query, pack);
	
	Format(query, sizeof(query), "SELECT steamid,points FROM 'Rank' WHERE points >= 0 ORDER BY points DESC");
	result = SQL_Query(DB, query);
	
	while(SQL_HasResultSet(result) && SQL_FetchRow(result))
	{
		SQL_FetchString(result, 0, Auth_receive, 32);
		Rank++;
		if(StrEqual(Auth_receive, auth, false)){ Point = SQL_FetchInt(result, 1); break; }
	}
	CPrintToChatAll("%t", "RankMe", name, Rank, SQL_GetRowCount(result), Point);
	CloseHandle(result);
}

public Action:Command_Top(client, args) //****************************************** TOP **********************
{
	decl String:arg1[64];
	if (!args) 
	{
		arg1 = currentMap;
	}
	else { GetCmdArg(1, arg1, sizeof(arg1)); }
	
	decl String:query[200];
	decl String:Topname[32];
	decl String:buffer[68];
	new Handle:result;
	new Mesto=1;
	new Float:seconds;
	new minutes;
	decl String:Time[32];
	
	Format(query, sizeof(query), "SELECT * FROM 'Players' WHERE map ='%s' AND runtime < 9999 ORDER BY runtime LIMIT 0, 10", arg1);
	result = SQL_Query(DB, query);
	
	new Handle:panel = CreatePanel();
	Format(buffer, sizeof(buffer), "Top10 maps: %s\n----------------------------------", arg1);
	SetPanelTitle(panel, buffer);
	while(SQL_FetchRow(result)) {
		SQL_FetchString(result, 1, Topname, sizeof(Topname));
		
		new Float:TimeFloat = SQL_FetchFloat(result, 3);
		minutes = RoundToZero(TimeFloat/60); seconds = TimeFloat  - (minutes * 60);
		if(minutes < 10) { if(seconds < 10.0) { Format(Time, 32, "0%d:0%.4f", minutes, seconds); } else { Format(Time, 32, "0%d:%.4f", minutes, seconds); } }
		else { if(seconds < 10.0) { Format(Time, 32, "%d:0%.4f", minutes, seconds); } else { Format(Time, 32, "%d:%.4f", minutes, seconds); } }
		Format(buffer, sizeof(buffer), "Rank %i - [%s] - %s", Mesto++, Time, Topname);
		DrawPanelText(panel, buffer);
	}
	DrawPanelText(panel, "----------------------------------");
	DrawPanelItem(panel, "Закрыть");
	SendPanelToClient(panel, client, PanelHandlerNothing, 15);
	CloseHandle(panel);
}

public Action:Command_Teleport(client, args) //***************************** TELEPORT **********************
{
	if (EnableStage[client]) { CPrintToChat(client, "%t", "Error"); return; }
	if (lvl_Tele[LvlZone[client]][0] == 0.0) { PrintToChat(client, "\x05[\x04SurfTimer\x05] \x01- \x05Not CP"); return; }
	decl Float:vec[3] = {0.0, ...}; TeleportEntity(client, lvl_Tele[LvlZone[client]], NULL_VECTOR, vec);
}

public Action:Command_Goback(client, args) //******************************** GOBACK **********************
{
	Command_TeleportGoback(client);
	return Plugin_Continue;
}

public Action:Command_Restart(client, args) //******************************* RESTART **********************
{
	if (lvl_Tele[1][0] == 0.0) { PrintToChat(client, "\x05[\x04SurfTimer\x05] \x01- \x05Not CP"); return; }
	if (!IsActiveCl(client)) { PrintToChat(client, "\x05[\x04SurfTimer\x05] \x01- \x05Нужно быть живым!"); return; }
	Clear_All(client);
	if (MenuTele != INVALID_HANDLE) { CloseHandle(MenuTele); MenuTele = INVALID_HANDLE; }
	
	new Float:vec[3] = {15000.0, -15000.0, 15000.0}; TeleportEntity(client, vec, NULL_VECTOR, NULL_VECTOR);
	CreateTimer(0.1, RunTeleRestart, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:RunTeleRestart(Handle:timer,any:client)
{
	decl Float:vec[3] = {0.0, ...}; TeleportEntity(client, lvl_Tele[1], NULL_VECTOR, vec);
}

public Action:Command_Respawn(client, args) //********************************** RESPAWN **********************
{
	if(IsPlayerAlive(client))  { PrintToChat(client, "\x05[\x04SurfTimer\x05] Ты живой!"); return; }
	CS_RespawnPlayer(client);
}

public Action:Command_AutoRespawn(client, args) //***************************** AUTO RESPAWN **********************
{
	CreateTimer(1.0, RunAutoRespawn, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:RunAutoRespawn(Handle:timer,any:client)
{
	//if(!IsPlayerAlive(client) && GetClientTeam(client) > 1)  { CS_RespawnPlayer(client); }
	if (IsPlayer(client)&& IsClientInGame(client)) { Command_WelcomeMesage(client); }
}

public Action:Command_Surftop(client, args) //********************************** SURFTOP **********************
{
	decl String:arg1[32]; GetCmdArg(1, arg1, sizeof(arg1)); new numInt = StringToInt(arg1);
	new target;
	if (numInt) { target = numInt; }
	else { target = 25; }
	decl String:query[200];
	Format(query, sizeof(query), "SELECT * FROM 'Rank' WHERE points >= 0 ORDER BY points DESC LIMIT 0, %i", target);
	SQL_TQuery(DB, SQL_ProcessQuery_GetSurfTop, query, client);
}

new Handle:mainMTOP = INVALID_HANDLE;
public Action:Command_Mtop(client, args) //********************************** mTOP **********************
{
	if (!SurfLevel) { CPrintToChat(client, "{green}[SurfTimer] {default} - {lightgreen}Тут нету уровней!"); return; }
	mainMTOP = CreateMenu(maineMTOP);
	if (NumLvl!=1) SetMenuTitle(mainMTOP,"Info:\n--------------------------------\n\nMap: %s\nNumber Stages: %i\nTier: %i\n ", currentMap, NumLvl, tier);
	else SetMenuTitle(mainMTOP,"Info:\n--------------------------------\n\nMap: %s\nTier: %i\n ", currentMap, tier);
	new String:buffer[512];
	new String:numcp[32];
	for (new i = 1; i < NumLvl+1; i++)
	{
		Format(buffer, sizeof(buffer), "Stage %i", i);
		IntToString(i, numcp, sizeof(numcp))
		AddMenuItem(mainMTOP, numcp, buffer);
	}
	SetMenuExitButton(mainMTOP, true); 
	DisplayMenu(mainMTOP, client, 25);
}

public maineMTOP(Handle:menu, MenuAction:action, param1, param2) 
{
	decl String:info[32];
	GetMenuItem(mainMTOP, param2, info, sizeof(info));
	if(action == MenuAction_Select) 
	{ 
		Command_mTop(param1, param2);
	} 
	else if(action == MenuAction_End) 
	{ 
		if (mainMTOP != INVALID_HANDLE) { CloseHandle(mainMTOP); mainMTOP = INVALID_HANDLE; }
	} 
}

public Action:Command_mTop(client, tar)
{
	decl String:query[200];
	Format(query, sizeof(query), "SELECT * FROM 'lvl' WHERE map ='%s' AND lvl =%i AND runtime < 9999.0 ORDER BY runtime LIMIT 0, 25", currentMap, tar+2);
	SQL_TQuery(DB, SQL_ProcessQuery_GetMTop, query, client);
}

new Handle:mainSR = INVALID_HANDLE;
public Action:Command_SR(client, args) //***************************************** SR **********************
{
	mainSR = CreateMenu(menueeSR);
	if (NumLvl!=1) SetMenuTitle(mainSR,"Info:\n--------------------------------\n\nMap: %s\nNumber Stages: %i\nTier: %i\n ", currentMap, NumLvl, tier);
	else SetMenuTitle(mainSR,"Info:\n--------------------------------\n\nMap: %s\nTier: %i\n ", currentMap, tier);
	AddMenuItem(mainSR, "1", "Top10 in Map");
	AddMenuItem(mainSR, "2", "Online Players");
	//AddMenuItem(mainSR, "3", "Personal Record");
	SetMenuExitButton(mainSR, true); 
	DisplayMenu(mainSR, client, 25);
}

public menueeSR(Handle:menu, MenuAction:action, param1, param2) 
{ 
	decl String:info[32];
	GetMenuItem(mainSR, param2, info, sizeof(info));
	if(action == MenuAction_Select) 
	{ 
		if (StrEqual(info, "1")) { Command_Top(param1, param2); }
		if (StrEqual(info, "2")) { Command_OnlinePlayers(param1); }
		//if (StrEqual(info, "3")) { Command_PR(param1, param1); }
	} 
	else if(action == MenuAction_End) 
	{ 
		if (mainSR != INVALID_HANDLE) { CloseHandle(mainSR); mainSR = INVALID_HANDLE; }
	} 
}