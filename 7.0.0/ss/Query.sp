
public SQL_ProcessQueryGetPlayers(Handle:owner, Handle:hndl, const String:error[], any:data) 
{ 
	if (hndl == INVALID_HANDLE) { LogError("TIMERRRRRRRRRRRRR SQL_ProcessQueryGetPlayers Error: %s", error); return; }
	
	if (!SQL_GetRowCount(hndl)) 
	{
		decl String:query[200];  
		EnableSurfTimerMap = true;
		
		PrintToChatAll("%s Insert Players", PERFIX);
		Format(query, sizeof(query), "INSERT INTO 'Players' (map) VALUES ('%s');", currentMap); SQL_TQuery(DB, SQLErrorCheckCallback, query);
		
		ServerCommand("changelevel %s", currentMap);
		return;
	}
	
	decl String:recordname[32];
	decl String:finishtime[12];
	
	while (SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 1, recordname, sizeof(recordname));
		SQL_FetchString(hndl, 2, finishtime, sizeof(finishtime));
		BestTime = SQL_FetchFloat(hndl, 3);
		SQL_FetchString(hndl, 4, BestMapSteam, sizeof(BestMapSteam));
	}
	
	if(StrEqual( finishtime, "None",false)) { Format(BestMap, 44, "None"); }
	else { Format(BestMap, 44, "%s (%s)", finishtime, recordname); }
}

public SQL_ProcessProverka(Handle:owner, Handle:hndl, const String:error[], any:pack) 
{ 
	if (hndl == INVALID_HANDLE) { LogError("TIMERRRRRRRRRRRRR SQL_ProcessProverka Error: %s", error); return; }
	
	decl String:Time[12];
	decl String:timeNehvat[12];
	decl String:Name[32];
	decl String:safe_uname[32];
	decl String:query[320];
	decl String:steamId[32];
	
	ResetPack(pack);
	new client = ReadPackCell(pack);
	new Float:FinishTimeClient = ReadPackFloat(pack);
	ReadPackString(pack, Time, sizeof(Time));
	ReadPackString(pack, timeNehvat, sizeof(timeNehvat));
	
	GetClientName(client, Name, sizeof(Name));
	SQL_EscapeString(DB, Name, safe_uname, sizeof(safe_uname));
	GetClientAuthString(client, steamId, sizeof(steamId));
	
	if(!SQL_GetRowCount(hndl))  //////////////////////////////////////////////////// * НЕПРОХОДИЛ КАРТУ *
	{
		Format(query, sizeof(query), "INSERT INTO 'Players' (map, name, time, runtime, steamid) VALUES ('%s', '%s', '%s', '%f', '%s');", currentMap, safe_uname, Time, FinishTimeClient, steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
		Format(query, sizeof(query), "UPDATE 'Rank' SET points = points +%i WHERE steamid = '%s';", tier*10, steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
		
		CPrintToChat(client, "%t", "MapFristTime", tier*10);
		
		if(FinishTimeClient <= BestTime)    ////////////////////////////////////////////////////// * WR!!! *
		{
			BestTime = FinishTimeClient; Format(BestMap, 44, "%s (%s)", Time, Name);
	
			Format(query, sizeof(query), "UPDATE 'Rank' SET wr = wr -1 WHERE steamid = '%s';",  BestMapSteam); SQL_TQuery(DB, SQLErrorCheckCallback, query);
			Format(query, sizeof(query), "UPDATE 'Rank' SET wr = wr +1 WHERE steamid = '%s';", steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
			
			CPrintToChatAll("%t", "MapTimeWR", Name, Time);
				
			BestMapSteam = steamId;
			PlaySongLeader();
		}
		else { CPrintToChatAll("%t", "MapTime", Name, Time, timeNehvat); EmitSoundToAll(sound2); }
		
		BestMapMe[client] = Time;
		CheckTop10(client, FinishTimeClient);
	}
	else //////////////////////////////////////////////////// * ПРОХОДИЛ КАРТУ *
	{
		new Float:PersonalRecordFloat = SQL_FetchFloat(hndl, 3);
		if (FinishTimeClient < PersonalRecordFloat) //////////////////////////////////////////////////// * УЛУЧШИЛ *
		{
			decl String:timeProsh[12];
			Format_Time(PersonalRecordFloat, timeProsh);
				
			if(FinishTimeClient <= BestTime)    ////////////////////////////////////////////////////// * WR!!! *
			{
				BestTime = FinishTimeClient; Format(BestMap, 44, "%s (%s)", Time, Name); BestMapMe[client] = Time;
		
				if(strcmp(BestMapSteam, steamId) != 0) ///////////////////////////////////////////////////////////////////////////////////// * УЛУЧШИЛ НЕ СВОЙ WR *
				{
					Format(query, sizeof(query), "UPDATE 'Rank' SET wr = wr -1 WHERE steamid = '%s';",  BestMapSteam); SQL_TQuery(DB, SQLErrorCheckCallback, query);
					Format(query, sizeof(query), "UPDATE 'Rank' SET wr = wr +1 WHERE steamid = '%s';", steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
					
					BestMapSteam = steamId;
				}
				CPrintToChatAll("%t", "MapTime2", Name, Time, timeProsh);
				PlaySongLeader();
			}
			else   //////////////////////////////////////////////////// * НЕ WR *
			{
				CPrintToChatAll("%t", "MapTime3", Name, Time, timeNehvat, timeProsh);
				EmitSoundToAll(sound2);
			}
			
			Format(query, sizeof(query), "UPDATE 'Players' SET name = '%s', time = '%s', runtime = '%f' WHERE map = '%s' AND steamid = '%s';",  safe_uname, Time, FinishTimeClient, currentMap, steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
			
			BestMapMe[client] = Time;
			CheckTop10(client, FinishTimeClient);
		}
		else { CPrintToChatAll("%t", "MapTime", Name, Time, timeNehvat); EmitSoundToAll(sound); } ////////////////// * НЕ УЛУЧШИЛ *
	}
}

public SQL_ProcessQuery_GetMTop(Handle:owner, Handle:hndl, const String:error[], any:client) 
{ 
	if (hndl == INVALID_HANDLE) { LogError("TIMERRRRRRRRRRR SQL_ProcessQuery_GetMTop Error: %s", error); return; }
	
	//decl String:Toptime[30];
	decl String:Topname[32];
	decl String:buffer[68];
	new Mesto=1;
	
	new Float:seconds;
	new minutes;
	decl String:Time[32];
	
	new Handle:panel = CreateMenu(menuee);
	SetMenuTitle(panel, "Лучшие результаты уровня:\n---Rank--------Time--------Name----");
	while(SQL_FetchRow(hndl)) {
		SQL_FetchString(hndl, 5, Topname, sizeof(Topname));
		new Float:TimeFloat = SQL_FetchFloat(hndl, 3);
		minutes = RoundToZero(TimeFloat/60); seconds = TimeFloat  - (minutes * 60);
		if(minutes < 10) { if(seconds < 10.0) { Format(Time, 32, "0%d:0%.4f", minutes, seconds); } else { Format(Time, 32, "0%d:%.4f", minutes, seconds); } }
		else { if(seconds < 10.0) { Format(Time, 32, "%d:0%.4f", minutes, seconds); } else { Format(Time, 32, "%d:%.4f", minutes, seconds); } }
		Format(buffer, sizeof(buffer), "Rank %i - [%s] - %s", Mesto++, Time, Topname);
		AddMenuItem(panel, "", buffer);
	}
	DisplayMenu(panel, client, 20);
}

public SQL_ProcessStartBestRecord(Handle:owner, Handle:hndl, const String:error[], any:client)   
{ 
	if (hndl == INVALID_HANDLE) { LogError("TIMERRRRRRRRRR SQL_ProcessStartBestRecord Error: %s", error); return; }
	
	if (SurfLevel)
	{
		decl String:query[200];
		decl String:steamId[32];
		GetClientAuthString(client, steamId, sizeof(steamId));
		
		for (new stage = 1; stage <= MAX_CP; stage++)
		{
			Format(BestStageMe[client][stage - 1], 12, "None");
			
			Format(query, sizeof(query), "SELECT * FROM 'lvl' WHERE map ='%s' AND lvl =%i AND steamid ='%s'", currentMap, stage - 1, steamId);
			SQL_TQuery(DB, SQL_ProcessVivodRecordLvl_Me, query, client); 
		}
	}
	if (!SQL_GetRowCount(hndl)) { Format(BestMapMe[client], 12, "None"); return; }
	while (SQL_FetchRow(hndl)) { SQL_FetchString(hndl, 2, BestMapMe[client], 12); }
}

public SQL_ProcessQuery_GetSurfTop(Handle:owner, Handle:hndl, const String:error[], any:client) 
{ 
	if (hndl == INVALID_HANDLE) { LogError("TIMERRRRRRRRRRRRRR SQL_ProcessQuery_GetSurfTop Error: %s", error); return; }
	
	new String:TopPoint[30];
	new String:Topname[32];
	new String:buffer[68];
	new i = 0;
	new M=1;
	
	new Handle:main = CreateMenu(menuee);
	SetMenuTitle(main,"Топ игроков:");
	while(SQL_FetchRow(hndl)) {
		SQL_FetchString(hndl, 0, Topname, sizeof(Topname));
		SQL_FetchString(hndl, 2, TopPoint, sizeof(TopPoint));
		Format(buffer, sizeof(buffer), "Rank:%i. %s - %s points", M++, Topname, TopPoint);
		AddMenuItem(main, "", buffer);
		i++;
	}
	DisplayMenu(main, client, 25);
}

public menuee(Handle:menu,MenuAction:action,client,selection)
{
	
}

public SQL_ProcessQuery_OnlineRank(Handle:owner, Handle:hndl, const String:error[], any:pack) 
{ 
	if (hndl == INVALID_HANDLE) { LogError("TIMERRRRRRRRRRRRRR SQL_ProcessQuery_OnlineRank Error: %s", error); return; }
	
	decl String:Name[32];
	decl String:ip[16];
	decl String:city[45];
	decl String:region[45];
	decl String:country[45];
	decl String:ccode[3];
	decl String:ccode3[4];
	new String:Auth_receive[32];
	new String:auth[32];
	new String:buffer[512];
	decl String:query[512];	
	new maps = 0;
	
	ResetPack(pack);
	new param1 = ReadPackCell(pack);
	new tar = ReadPackCell(pack);
	GetClientName(tar, Name, sizeof(Name));
	GetClientIP(tar, ip, sizeof(ip));
	
	GeoipGetRecord(ip, city, region, country, ccode, ccode3)
	GetClientAuthString(tar, auth, 32);
	
	Format(query, sizeof(query), "SELECT DISTINCT map FROM 'Players' WHERE steamid ='%s'", auth);        
	new Handle:result = SQL_Query(DB, query);
	while(SQL_HasResultSet(result) && SQL_FetchRow(result))
	{
		maps++;
	}
	CloseHandle(result);
	
	new i=1;
	while(SQL_HasResultSet(hndl) && SQL_FetchRow(hndl))
	{
		SQL_FetchString(hndl, 1, Auth_receive,32);
			
		if(StrEqual(Auth_receive,auth,false)) {
			new Point = SQL_FetchInt(hndl,2);
			new wr = SQL_FetchInt(hndl,4);
			Format(buffer, sizeof(buffer), "Player: %s\n \nRank:      [%i/%i]\nPoints:    [%i]\nWR:        [%i]\nTop10:    [%i]\nWRCP:    [%i]\nMaps completed: [%i]\n \nCountry: %s\nCity: %s\n ", Name, i, SQL_GetRowCount(hndl), Point, wr, GetNumTop10(tar), GetNumWrcp(tar), maps, country, city);
			break;
		}
		i++;
	} 
	
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "---------------------------------------");
	DrawPanelText(panel, buffer);
	DrawPanelText(panel, "---------------------------------------");
	DrawPanelItem(panel, "Закрыть");
	SendPanelToClient(panel, param1, PanelHandlerNothing, 25);
	CloseHandle(panel);
}

public Action:Command_GetMap()
{
	new Handle:kv;
	new String:file[512];
	kv = CreateKeyValues("ChecPoint");
	BuildPath(Path_SM, file, sizeof(file), "configs/surftimer/maps/%s.cfg", currentMap); 
	FileToKeyValues(kv, file); 
	
	for (new i = 1; i < MAX_CP; i++)
	{
		new String:targetname[512];
		new Float:cp[3];
		new Float:min[3];
		new Float:max[3];
	
		new String:numcp[32];
		IntToString(i, numcp, sizeof(numcp))
		if(KvJumpToKey(kv, numcp))
		{
			decl String:buff[512];
			decl String:cbuff[6][255];
			KvGetString(kv, "targetname", targetname, sizeof(targetname), "noname");
			KvGetString(kv, "cp", buff, sizeof(buff), "0.0:0.0:0.0");
			ExplodeString(buff, ":", cbuff, 3, 255);
			cp[0] = StringToFloat(cbuff[0]); cp[1] = StringToFloat(cbuff[1]); cp[2] = StringToFloat(cbuff[2]);
			KvGetString(kv, "minmax", buff, sizeof(buff), "0.0:0.0:0.0:0.0:0.0:0.0");
			ExplodeString(buff, ":", cbuff, 6, 255);
			min[0] = StringToFloat(cbuff[0]); min[1] = StringToFloat(cbuff[1]); min[2] = StringToFloat(cbuff[2]);
			max[0] = StringToFloat(cbuff[3]); max[1] = StringToFloat(cbuff[4]); max[2] = StringToFloat(cbuff[5]);
			EnableSurfTimerMap = true;
		}
		else { break; }
		if (i>=3) { SurfLevel = true; }
		else { SurfLevel = false; }
		KvRewind(kv);
		Create_multiple(targetname, cp, max, min, i);
	}
	CloseHandle(kv);
	PrintToServer("End Get Setting");
}

public SQLErrorCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(!StrEqual("", error))
	{
		PrintToServer("Last Connect SQL Error: %s", error);
	}
}

public Rname_In_Database(client)    /////////////////////////////////////////////////// * RENAME_DB_NAME_PLAYER *
{
	decl String:query[320];
	decl String:Name[32];
	decl String:safe_uname[32];
	decl String:reserve_Name[32];
	decl String:steamId[32];
	GetClientAuthString(client, steamId, sizeof(steamId));
	GetClientName(client, Name, sizeof(Name));
	SQL_EscapeString(DB, Name, safe_uname, sizeof(safe_uname));
	
	Format(query, sizeof(query), "SELECT name FROM 'Rank' WHERE steamid ='%s'", steamId);
	new Handle:result = SQL_Query(DB, query);
	if(SQL_FetchRow(result)) {
		SQL_FetchString(result, 0, reserve_Name, 32);
		if(!StrEqual(reserve_Name, Name, false)) {
			Format(query, sizeof(query), "UPDATE 'Rank' SET name = '%s' WHERE steamid = '%s';", safe_uname, steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
		}
	}
	
	Format(query, sizeof(query), "SELECT name FROM 'Players' WHERE steamid ='%s'", steamId);
	result = SQL_Query(DB, query);
	while(SQL_HasResultSet(result) && SQL_FetchRow(result)) {
		SQL_FetchString(result, 0, reserve_Name, 32);
		if(!StrEqual(reserve_Name, Name, false)) {
			Format(query, sizeof(query), "UPDATE 'Players' SET name = '%s' WHERE steamid = '%s';", safe_uname, steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
			break;
		}
	}
	
	Format(query, sizeof(query), "SELECT name FROM 'lvl' WHERE steamid ='%s'", steamId);
	result = SQL_Query(DB, query);
	while(SQL_HasResultSet(result) && SQL_FetchRow(result)) {
		SQL_FetchString(result, 0, reserve_Name, 32);
		if(!StrEqual(reserve_Name, Name, false)) {
			Format(query, sizeof(query), "UPDATE 'lvl' SET name = '%s' WHERE steamid = '%s';", safe_uname, steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
			break;
		}
	}
	CloseHandle(result);
}

stock GetNumTop10(client)     //////////////////////////////////////////////////////////// * KOLI4ESTVO TOP10 *
{
	decl String:query[320];
	decl String:MapName[64];
	decl String:steamId[32];
	decl String:steamId_resrv[32];
	new num_top10;
	
	GetClientAuthString(client, steamId, sizeof(steamId));
	
	Format(query, sizeof(query), "SELECT DISTINCT map FROM 'Players'");
	new Handle:result = SQL_Query(DB, query);
	
	while(SQL_HasResultSet(result) && SQL_FetchRow(result)) {
		SQL_FetchString(result, 0, MapName, 64);
		
		Format(query, sizeof(query), "SELECT steamid FROM 'Players' WHERE map ='%s' AND runtime < 9999 ORDER BY runtime LIMIT 0, 10", MapName);
		new Handle:result2 = SQL_Query(DB, query);
		
		while(SQL_FetchRow(result2)) {
			SQL_FetchString(result2, 0, steamId_resrv, 32);
			
			if(StrEqual(steamId_resrv, steamId)) { num_top10++; }
		}
		CloseHandle(result2);
	}
	CloseHandle(result);
	
	return num_top10;
}

stock GetNumWrcp(client)     //////////////////////////////////////////////////////////////// * KOLI4ESTVO WRCP *
{
	decl String:query[320];
	decl String:MapName[64];
	decl String:steamId[32];
	decl String:steamId_resrv[32];
	new num_wrcp;
	
	GetClientAuthString(client, steamId, sizeof(steamId));
	
	Format(query, sizeof(query), "SELECT DISTINCT map FROM 'Players'");
	new Handle:result = SQL_Query(DB, query);
	
	while(SQL_HasResultSet(result) && SQL_FetchRow(result)) {
		SQL_FetchString(result, 0, MapName, 64);
		
		Format(query, sizeof(query), "SELECT lvl FROM 'lvl' WHERE map ='%s' AND steamid = '%s'", MapName, steamId);
		new Handle:result2 = SQL_Query(DB, query);
		
		while(SQL_HasResultSet(result2) && SQL_FetchRow(result2)) {
			new level = SQL_FetchInt(result2, 0);
			
			Format(query, sizeof(query), "SELECT steamid FROM 'lvl' WHERE map ='%s' AND lvl = %i AND runtime < 9999 ORDER BY runtime LIMIT 0, 1", MapName, level);
			new Handle:result3 = SQL_Query(DB, query);
			
			while(SQL_FetchRow(result3)) {
				SQL_FetchString(result3, 0, steamId_resrv, 32);
			
				if(StrEqual(steamId_resrv, steamId)) { num_wrcp++; }
			}
			CloseHandle(result3);
		}
		
		CloseHandle(result2);
	}
	CloseHandle(result);
	
	return num_wrcp;
}