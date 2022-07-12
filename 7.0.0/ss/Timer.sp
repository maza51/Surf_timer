new Float:PlayerTimer[MAXPLAYERS+1] = 0.0;
new Float:PlayerTimerLvl[MAXPLAYERS+1] = 0.0;

new bool:Surfing[MAXPLAYERS+1] = false;
new bool:InLvl[MAXPLAYERS+1] = false;
new bool:Startoval[MAXPLAYERS+1] = false;

new LvlZone[MAXPLAYERS+1];

public OnStartTouch(const String:output[], caller, activator, Float:delay)
{
	//PrintToChatAll("-=HOOK=-");
	if(!IsActiveCl(activator))
		return;
	if(!IsClientInGame(activator))
		return;
	if(!IsPlayer(activator))
		return;
	if (!EnableSurfTimerMap)
		return;
	if(EnableStage[activator])
		return;
	
	for (new cp = 1; cp < MAX_CP; cp++)
	{
		if (trigger[cp] != -1)
		{
			if (caller == trigger[cp])
			{
				if (cp == 1) //////////////////////////////////////////////////////////////////////////////////////////////////////////////// * START MAP *
				{
					Surfing[activator] = false;
					PlayerTimer[activator] = GetEngineTime();
					LvlZone[activator] = 1;
					Startoval[activator] = true;
					if (SurfLevel) { decl String:Buf[16]; Format(Buf, 16, "[stage %i] -  ", LvlZone[activator]); CS_SetClientClanTag(activator, Buf); }
				}
				else if (cp == 2 && Startoval[activator]) /////////////////////////////////////////////////////////////////////////////////// * FINISH MAP *
				{
					PrintHintText(activator, "- Finish -");
					Surfing[activator] = false;
					Startoval[activator] = false;
					
					if (SurfLevel) { DbRun(activator, LvlZone[activator] + 1, GetEngineTime() - PlayerTimerLvl[activator]); }
					EndMapItog(activator, GetEngineTime() - PlayerTimer[activator]);
					if (SurfLevel) { decl String:Buf[16]; Format(Buf, 16, "[Finish] -  "); CS_SetClientClanTag(activator, Buf); }
				}
				else
				{
					if (LvlZone[activator] == cp - 2 && Startoval[activator] && !EnabBonus[activator]) /////////////////////////////////////// * LVL ZONE *
					{
						DbRun(activator, cp - 1, GetEngineTime() - PlayerTimerLvl[activator]);
					}
					InLvl[activator] = true;
					LvlZone[activator] = cp - 1;
					if (SurfLevel) { decl String:Buf[16]; Format(Buf, 16, "[stage %i] -  ", LvlZone[activator]); CS_SetClientClanTag(activator, Buf); }
				}
			}
		}
	}
	for (new cp = 51; cp < MAX_CP_B; cp++)
	{
		if (triggerB[cp] != -1)
		{
			if (caller == triggerB[cp])
			{
				
				if (cp == 51) /////////////////////////////////////////////////////////////////////////////////////////////////////////////// * START BONUS *
				{
					Surfing[activator] = false;
					Startoval[activator] = false;
					EnabBonus[activator] = true;
					PrintHintText(activator, "- START ZONE BONUS -");
					PlayerTimer[activator] = 0.0;
					PlayerTimerLvl[activator] = 0.0;
					decl String:Buf[16]; Format(Buf, 16, "[Bonus] -  "); CS_SetClientClanTag(activator, Buf);
				}
				else if (cp == 52 && EnabBonus[activator]) ////////////////////////////////////////////////////////////////////////////////// * FINISH BONUS *
				{
					Surfing[activator] = false;
					Startoval[activator] = false;
					EnabBonus[activator] = false;
					PrintHintText(activator, "- FINISH BONUS -");
					decl String:Time[16]; Format_Time(GetEngineTime() - PlayerTimer[activator], Time)
					PrintToChatAll("Complete in %s", Time);
				}
			}
		}
	}
}

public OnEndTouch(const String:output[], caller, activator, Float:delay)
{
	if(!IsActiveCl(activator))
		return;
	if(!IsPlayer(activator))
		return;
	if (!EnableSurfTimerMap)
		return;
	if(EnableStage[activator])
		return;     
	
	for (new cp = 1; cp < MAX_CP; cp++) ///////////// * MAP *
	{
		if (caller == trigger[cp])
		{
			if (cp != 2 && Startoval[activator])
			{
				if (cp == 1) { PlayerTimer[activator] = GetEngineTime(); }
				Surfing[activator] = true;
				PlayerTimerLvl[activator] = GetEngineTime();
			}
			InLvl[activator] = false;
		}
	}
	for (new cp = 1; cp < MAX_CP_B; cp++) ///////////// * BONUS *
	{
		if (caller == triggerB[cp])
		{
			if (cp != 52 && EnabBonus[activator])
			{
				PlayerTimer[activator] = GetEngineTime();
				Surfing[activator] = true;
			}
		}
	}
}

new Float:strip = 0.0;
public OnGameFrame() 
{
	if (strip<GetEngineTime()-0.3033)
	{
		strip = GetEngineTime();
		for (new client = 1; client <= MaxClients; client++)
		{
			if(IsClientInGame(client))
			{
				if (IsPlayerAlive(client)) ////////////////// * ÆÂÎÉ *
				{
					if (GetClientTeam(client) > 1)
					{
						if(EnableSurfTimerMap && !EnableStage[client])
						{
							if (Surfing[client])
							{
								decl String:Time[16]; Format_Time(GetEngineTime() - PlayerTimer[client], Time)
								Format(Time, 16, "Time: %s", Time);
								
								if (SurfLevel && !EnabBonus[client])
								{
									if(InLvl[client]) { PrintHintText(client, "%s\n\nIn Zone [Stage %i]", Time, LvlZone[client]); }
									else { PrintHintText(client, "%s\n\n- Surfing [Stage %i] -", Time, LvlZone[client]); }
								}
								else if (EnabBonus[client]) ////////////////// * BONUS *
								{
									PrintHintText(client, "%s\n\n- Surfing [Bonus] -", Time);
								}
								else { PrintHintText(client, "%t", "liney", Time); }
							}
							else
							{
								if (LvlZone[client] == 1 && Startoval[client]) { PrintHintText(client, "%t", "InsideStart"); }
							}
						}
					}
				}
				else //////////////// * SPECI *
				{
					new iSpecMode = GetEntProp(client, Prop_Send, "m_iObserverMode");
					if (iSpecMode == 4)
					{
						new iTargetUser = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
						if (iTargetUser > 0) 
						{
							decl String:Name[32];
							GetClientName(iTargetUser, Name, sizeof(Name));
							
							if(!EnableStage[iTargetUser])
							{
								if (Surfing[iTargetUser])
								{
									decl String:Time[64]; Format_Time(GetEngineTime() - PlayerTimer[iTargetUser], Time);
									Format(Time, 64, "Player: %s\nTime: %s", Name, Time);
									
									if (SurfLevel)
									{
										if(InLvl[iTargetUser]) { PrintHintText(client, "%s\n\nIn Zone [Stage %i]", Time, LvlZone[iTargetUser]); }
										else { PrintHintText(client, "%s\n\n- Surfing [Stage %i] -", Time, LvlZone[iTargetUser]); }
									}
									else { PrintHintText(client, "%t", "liney", Time); }
								}
								else
								{
									if (LvlZone[iTargetUser] == 1 && Startoval[iTargetUser]) { PrintHintText(client, "Inside Start"); }
								}
							}
						}
					}
				}
			}
		}
	}
}

public Action:RightHudTimer(Handle:timer)
{
	GetMapTimeLeft(Timeleft); if (Timeleft<5 && Timeleft>1) { ChangeMap(Timeleft); }
	Timeleft = Timeleft/60+1;
	for (new client = 1; client <= MaxClients; client++)
	{
		if(EnableSurfTimerMap && /*IsActiveCl(client)*/IsClientInGame(client))
		{
			if (IsPlayerAlive(client))
			{
				if (!EnableStage[client])
				{
					if (Surfing[client])
					{
						if (SurfLevel && !EnabBonus[client])
						{
							decl String:szText[512];
							Format(szText, sizeof(szText), "%T", "SurfLevel", client, Timeleft, LvlZone[client], BestStageMe[client][LvlZone[client]], BestStage[LvlZone[client]], GetMySpec(client));
							new Handle:hBuffer = StartMessageOne("KeyHintText", client); BfWriteByte(hBuffer, 1); BfWriteString(hBuffer, szText); EndMessage();					
						}
						else if (EnabBonus[client]) ////////////////// * BONUS *
						{
							decl String:szText[512];
							Format(szText, sizeof(szText), "- Surfing [Bonus] -");
							new Handle:hBuffer = StartMessageOne("KeyHintText", client); BfWriteByte(hBuffer, 1); BfWriteString(hBuffer, szText); EndMessage();		
						}
						else
						{
							decl String:szText[512];
							Format(szText, sizeof(szText), "%T", "NoSurfLevel", client, Timeleft, BestMapMe[client], BestMap, GetMySpec(client));
							new Handle:hBuffer = StartMessageOne("KeyHintText", client); BfWriteByte(hBuffer, 1); BfWriteString(hBuffer, szText); EndMessage();
						}
					}
				}
				else
				{
					decl String:szText[512];
					Format(szText, sizeof(szText), "-=Practik Mode=-");
					new Handle:hBuffer = StartMessageOne("KeyHintText", client); BfWriteByte(hBuffer, 1); BfWriteString(hBuffer, szText); EndMessage();
				}
			}
			else
			{
				decl String:szText[512];
				Format(szText, sizeof(szText), "Tupe !respawn\nto be alive!");
				new Handle:hBuffer = StartMessageOne("KeyHintText", client); BfWriteByte(hBuffer, 1); BfWriteString(hBuffer, szText); EndMessage();
			}
		}
	}
}

public Action:DbRun(client, stage, Float:FinishTimeClient) //Proshol LVL
{
	decl String:query[200];
	decl String:steamId[32];
	GetClientAuthString(client, steamId, sizeof(steamId));
	
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackCell(pack, stage);
	WritePackFloat(pack, FinishTimeClient);
	
	Format(query, sizeof(query), "SELECT * FROM 'lvl' WHERE map ='%s' AND steamid ='%s' AND lvl =%i", currentMap, steamId, stage);
	SQL_TQuery(DB, SQL_ProcessProverkaLVL, query, pack);
}

public Action:EndMapItog(client, Float:FinishTimeClient)
{
	decl String:query[200];
	decl String:safe_uname[32];
	decl String:steamId[32];
	decl String:Name[32];
	decl String:timeNehvat[12];
	decl String:Time[12];
	
	GetClientAuthString(client, steamId, sizeof(steamId));
	GetClientName(client, Name, sizeof(Name));
	SQL_EscapeString(DB, Name, safe_uname, sizeof(safe_uname));
	
	if (FinishTimeClient == BestTime) { FinishTimeClient = FinishTimeClient + 0.0001; }
	
	Format_Time(FinishTimeClient, Time);
	Format_Time(FinishTimeClient - BestTime, timeNehvat);
	
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, client);
	WritePackFloat(pack, FinishTimeClient);
	WritePackString(pack, Time);
	WritePackString(pack, timeNehvat);
	
	Format(query, sizeof(query), "SELECT * FROM 'Players' WHERE steamId ='%s' AND  map ='%s'", steamId, currentMap);
	SQL_TQuery(DB, SQL_ProcessProverka, query, pack);
}