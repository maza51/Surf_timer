
public Action:CheckTop10(client, Float:time)
{
	decl String:query[320];
	decl String:name[32];
	decl String:steamId[32];
	GetClientName(client, name, sizeof(name));
	GetClientAuthString(client, steamId, sizeof(steamId));
	
	decl String:t_Top11_Steam[11][32];
	new Float:t_Top11_Time[11];
	
	Format(query, sizeof(query), "SELECT * FROM 'Players' WHERE map ='%s' ORDER BY runtime LIMIT 0, 11", currentMap);
	new Handle:result = SQL_Query(DB, query);
	new i=0;
	while(SQL_HasResultSet(result) && SQL_FetchRow(result) && i < 11)
	{
		t_Top11_Time[i] = SQL_FetchFloat(result, 3);
		SQL_FetchString(result, 4, t_Top11_Steam[i], 32);
		//PrintToServer("%s", t_Top11_Steam[i]);
		i++;
	}
	CloseHandle(result);
	
	new str = 0;
	for (new mesto = 0; mesto <= 9; mesto++)
	{
		if (time < t_Top11_Time[mesto])
		{
			if (str == 0)
			{
				Format(query, sizeof(query), "UPDATE 'Rank' SET points = points + %i WHERE steamid = '%s';", PointsTop10[mesto], steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
				if (mesto != 10)
					CPrintToChatAll("%t", "Top10", name, mesto+1);
			}
			if(StrEqual(steamId, t_Top11_Steam[mesto], false))
			{
				Format(query, sizeof(query), "UPDATE 'Rank' SET points = points - %i WHERE steamid = '%s';", PointsTop10[mesto], steamId); SQL_TQuery(DB, SQLErrorCheckCallback, query);
				break;
			}
			else
			{
				if (!t_Top11_Time[mesto]) { break; }
				new point = PointsTop10[mesto] - PointsTop10[mesto+1];
				Format(query, sizeof(query), "UPDATE 'Rank' SET points = points - %i WHERE steamid = '%s';", point, t_Top11_Steam[mesto]); SQL_TQuery(DB, SQLErrorCheckCallback, query);
			}
			str++;
		}
	}
}