new bool:EnabBonus[MAXPLAYERS+1] = false;

public SQL_ProcessProverkaBonus(Handle:owner, Handle:hndl, const String:error[], any:pack) 
{ 
	if (hndl == INVALID_HANDLE) { LogError("TIMERRRRRRRRRRRRRRR SQL_ProcessProverkaBonus Error: %s", error); return; }
	
	ResetPack(pack);
	new client = ReadPackCell(pack);
	new bonus = ReadPackCell(pack);
	new Float:FinishTimeClient = ReadPackFloat(pack);
	
	decl String:query[200];
	decl String:steamId[30];
	decl String:Name[140];
	decl String:safe_uname[140];
	new Float:recordtimeB;
	
	GetClientAuthString(client, steamId, sizeof(steamId));
	GetClientName(client, Name, sizeof(Name));
	SQL_EscapeString(DB, Name, safe_uname, sizeof(safe_uname));
	
	decl String:Time[16];
	new minutes = RoundToZero(FinishTimeClient/60); 
	new Float:seconds = FinishTimeClient - (minutes * 60);
	if(minutes < 10) { if(seconds < 10.0) { Format(Time, 32, "0%d:0%.2f", minutes, seconds); } else { Format(Time, 32, "0%d:%.2f", minutes, seconds); } }
	else { if(seconds < 10.0) { Format(Time, 32, "%d:0%.2f", minutes, seconds); } else { Format(Time, 32, "%d:%.2f", minutes, seconds); } }
	
	if (SQL_GetRowCount(hndl)) 
	{
		while (SQL_FetchRow(hndl)) { recordtimeB = SQL_FetchFloat(hndl, 3); }
		
		if (recordtimeB > FinishTimeClient)
		{
			Format(query, sizeof(query), "UPDATE 'bonus' SET runtime = '%f', time = '%s', name = '%s' WHERE map = '%s' AND steamid = '%s' AND bonus = %i ;", FinishTimeClient, Time, safe_uname, currentMap, steamId, bonus); SQL_TQuery(DB, SQLErrorCheckCallback, query);
		}
		PrintToChatAll("\x05[\x04SurfTimer\x05] \x01- %s \x05Завершил \x01'Bonus %i'\x05 за \x04%s", Name, bonus, Time);
	}
	else 
	{
		Format(query, sizeof(query), "INSERT INTO 'bonus' (map, steamid, bonus, runtime, time, name) VALUES ('%s', '%s', %i, '%f', '%s', '%s');", currentMap, steamId, bonus, FinishTimeClient, Time, safe_uname); SQL_TQuery(DB, SQLErrorCheckCallback, query);
		
		Format(query, sizeof(query), "UPDATE 'bonus' SET points = points +%i WHERE steamid = '%s';", 15, steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
		PrintToChatAll("\x05[\x04SurfTimer\x05] \x01- %s \x05Завершил \x01'Bonus %i'\x05 за \x04%s", Name, bonus, Time);
	}
}

public Action:Command_GetMapBonus()
{
	new Handle:kv;
	new String:file[512];
	kv = CreateKeyValues("ChecPoint");
	BuildPath(Path_SM, file, sizeof(file), "configs/surftimer/maps/%s.cfg", currentMap); 
	FileToKeyValues(kv, file); 
	
	for (new i = 51; i < MAX_CP_B; i++)
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
		}
		else { break; }
		if (i>=51) { SurfBonus = true; }
		else { SurfBonus = false; }
		KvRewind(kv);
		Create_multiple_b(targetname, cp, max, min, i);
	}
	CloseHandle(kv);
	PrintToServer("End Get Setting Bonus");
}