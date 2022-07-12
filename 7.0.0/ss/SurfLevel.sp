

public SQL_ProcessProverkaLVL(Handle:owner, Handle:hndl, const String:error[], any:pack) 
{ 
	if (hndl == INVALID_HANDLE) { LogError("TIMERRRRRRRRRRRRRRR SQL_ProcessProverkaLVL Error: %s", error); return; }
	
	ResetPack(pack);
	new client = ReadPackCell(pack);
	new stage = ReadPackCell(pack);
	new Float:FinishTimeClient = ReadPackFloat(pack);
	
	decl String:query[320];
	decl String:steamId[30];
	decl String:Name[32];
	decl String:safe_uname[32];
	new Float:recordtimelvl;
	
	GetClientAuthString(client, steamId, sizeof(steamId));
	GetClientName(client, Name, sizeof(Name));
	SQL_EscapeString(DB, Name, safe_uname, sizeof(safe_uname));
	
	decl String:Time[12];
	Format_Time(FinishTimeClient, Time);
	
	if (SQL_GetRowCount(hndl)) 
	{
		while (SQL_FetchRow(hndl)) { recordtimelvl = SQL_FetchFloat(hndl, 3); }
		
		if (recordtimelvl > FinishTimeClient)
		{
			Format(query, sizeof(query), "UPDATE 'lvl' SET runtime = '%f', time = '%s', name = '%s' WHERE map = '%s' AND steamid = '%s' AND lvl = %i ;", FinishTimeClient, Time, safe_uname, currentMap, steamId, stage); SQL_TQuery(DB, SQLErrorCheckCallback, query);
			BestStageMe[client][stage-1] = Time;
		}
		
		if (FinishTimeClient < BestStageTime[stage-1])
		{
			CPrintToChat(client, "%t", "StageComplete", stage-1, Time);
			Format(BestStage[stage-1], 44, "%s (%s)", Time, Name);
			BestStageTime[stage-1] = FinishTimeClient;
		}
		else
		{
			decl String:timeNehvat[20];
			Format_Time(FinishTimeClient - BestStageTime[stage-1], timeNehvat);
			
			CPrintToChat(client, "%t", "StageComplete2", stage-1, Time, timeNehvat);
		}
	}
	else 
	{
		Format(query, sizeof(query), "INSERT INTO 'lvl' (map, steamid, lvl, runtime, time, name) VALUES ('%s', '%s', %i, '%f', '%s', '%s');", currentMap, steamId, stage, FinishTimeClient, Time, safe_uname); SQL_TQuery(DB, SQLErrorCheckCallback, query);
		Format(query, sizeof(query), "UPDATE 'Rank' SET points = points +%i WHERE steamid = '%s';", tier, steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
		
		BestStageMe[client][stage-1] = Time;
		
		if (FinishTimeClient < BestStageTime[stage-1])
		{
			CPrintToChat(client, "%t", "StageCompleteFrist", stage-1, Time, tier);
			Format(BestStage[stage-1], 44, "%s (%s)", Time, Name);
			BestStageTime[stage-1] = FinishTimeClient;
		}
		else
		{
			decl String:timeNehvat[20];
			Format_Time(FinishTimeClient - BestStageTime[stage-1], timeNehvat);
			
			CPrintToChat(client, "%t", "StageCompleteFrist2", stage-1, Time, timeNehvat, tier);
		}
	}
}

public VivodRecordLvl()
{
	decl String:query[256];
	for (new stage = 1; stage <= MAX_CP; stage++)
	{
		Format(BestStage[stage - 1], 44, "None");
		BestStageTime[stage - 1] = 999999.0;
		
		Format(query, sizeof(query), "SELECT * FROM 'lvl' WHERE map ='%s' AND lvl =%i AND runtime < 9999.0 ORDER BY runtime LIMIT 0, 1", currentMap, stage);
		SQL_TQuery(DB, SQL_ProcessVivodRecordLvl_test, query); 
	}
}

public SQL_ProcessVivodRecordLvl_test(Handle:owner, Handle:hndl, const String:error[], any:pack) 
{ 
	if (hndl == INVALID_HANDLE) { LogError("TIMERRRRRRRRRRRRRR SQL_ProcessVivodRecordLvl_test Error: %s", error); return; }
	
	if (SQL_GetRowCount(hndl)) 
	{
		new Float:RecordtimeF;
		new Stage;
		new String:Recordname[32];
		new String:Recordtime[32];
		
		while(SQL_FetchRow(hndl))
		{
			Stage = SQL_FetchInt(hndl, 2) - 1;
			RecordtimeF = SQL_FetchFloat(hndl, 3);
			SQL_FetchString(hndl, 4, Recordtime, 32);
			SQL_FetchString(hndl, 5, Recordname, 32);
			Format(BestStage[Stage], 44, "%s (%s)", Recordtime, Recordname);
			BestStageTime[Stage] = RecordtimeF;
		}
	}
}

public SQL_ProcessVivodRecordLvl_Me(Handle:owner, Handle:hndl, const String:error[], any:client) 
{ 
	if (hndl == INVALID_HANDLE)
	{
		LogError("TIMERRRRRRRRRRR SQL_ProcessVivodRecordLvl_Me Error: %s", error);
		return;
	}
	
	if (SQL_GetRowCount(hndl)) 
	{
		while (SQL_FetchRow(hndl))
		{
			new Stage = SQL_FetchInt(hndl, 2) - 1;
			SQL_FetchString(hndl, 4, BestStageMe[client][Stage], 12);
		}
	}
}