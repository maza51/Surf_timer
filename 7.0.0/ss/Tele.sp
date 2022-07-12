
new Float:lvl_Tele[MAX_CP][3];

new NumLvl = 1;

new Handle:MenuTele = INVALID_HANDLE;

public ProcessTele() 
{ 
	new Handle:kvGetTele;
	new String:file[512];
	kvGetTele = CreateKeyValues("ChecPoint");
	BuildPath(Path_SM, file, sizeof(file), "configs/surftimer/maps/%s.cfg", currentMap); 
	FileToKeyValues(kvGetTele, file);
	
	for (new i = 101; i < MAX_CP+100; i++)
	{
		new String:numcp[32];
		IntToString(i, numcp, sizeof(numcp))
		if(KvJumpToKey(kvGetTele, numcp))
		{
			decl String:buff[512];
			decl String:cbuff[3][255];
			KvGetString(kvGetTele, "cp", buff, sizeof(buff), "0.0:0.0:0.0");
			ExplodeString(buff, ":", cbuff, 3, 255);
			lvl_Tele[NumLvl][0] = StringToFloat(cbuff[0]); lvl_Tele[NumLvl][1] = StringToFloat(cbuff[1]); lvl_Tele[NumLvl][2] = StringToFloat(cbuff[2]);
			NumLvl++;
		}
		else { NumLvl--; break; }
		KvRewind(kvGetTele);
	}
	CloseHandle(kvGetTele);
}

public Action:SetTeleport(client, String:level[])
{
	new Float:cp[3];
	decl String:cordstele[255];
	GetClientAbsOrigin(client,cp);
	Format(cordstele, 255, "%f:%f:%f",cp[0],cp[1],cp[2]);
	
	new String:Print[512];
	new String:path[PLATFORM_MAX_PATH];
	new Handle:SetTele;
	
	BuildPath(Path_SM, path, sizeof(path), "configs/surftimer/maps/%s_temp.ini", currentMap);
	
	SetTele = OpenFile(path, "a+");
	
	Format(Print, sizeof(Print), "	\"%s\" { \"cp\" \"%s\" }", level, cordstele);
	WriteFileLine(SetTele, Print);
	CloseHandle(SetTele);
	PrintToChat(client,"%s", level);
}

public Action:Command_Stage(client, args) /////////////////////////STAGE
{
	if (!SurfLevel) { PrintToChat(client, "\x05[\x04SurfTimer\x05] Тут нету уровней."); EnableStage[client] = false; return; }
	
	decl String:arg1[32]; GetCmdArg(1, arg1, sizeof(arg1)); new numInt = StringToInt(arg1);
	if (numInt > NumLvl) { PrintToChat(client, "\x05[\x04SurfTimer\x05]\x01 - \x05Нету такого уровня!"); return; }
	if (numInt) { TeleportEntity(client, lvl_Tele[numInt], NULL_VECTOR, NULL_VECTOR); Clear_All(client); EnableStage[client] = true; decl String:Buf[32]; Format(Buf, 32, "[practik mode] -  "); CS_SetClientClanTag(client, Buf); return; }
	
	MenuTele = CreateMenu(MenuHandlerstafe);
	SetMenuTitle(MenuTele, "-=Выберете уровень=-"); 
	AddMenuItem(MenuTele, "1", "Stage 1", ITEMDRAW_DISABLED);
	
	if (NumLvl > 1) { AddMenuItem(MenuTele, "2", "Stage 2"); }
	if (NumLvl > 2) { AddMenuItem(MenuTele, "3", "Stage 3"); }
	if (NumLvl > 3) { AddMenuItem(MenuTele, "4", "Stage 4"); }
	if (NumLvl > 4) { AddMenuItem(MenuTele, "5", "Stage 5"); }
	if (NumLvl > 5) { AddMenuItem(MenuTele, "6", "Stage 6"); }
	if (NumLvl > 6) { AddMenuItem(MenuTele, "7", "Stage 7"); }
	if (NumLvl > 7) { AddMenuItem(MenuTele, "8", "Stage 8"); }
	if (NumLvl > 8) { AddMenuItem(MenuTele, "9", "Stage 9"); }
	if (NumLvl > 9) { AddMenuItem(MenuTele, "10", "Stage 10"); }
	if (NumLvl > 10) { AddMenuItem(MenuTele, "11", "Stage 11"); }
	if (NumLvl > 11) { AddMenuItem(MenuTele, "12", "Stage 12"); }
	if (NumLvl > 12) { AddMenuItem(MenuTele, "13", "Stage 13"); }
	if (NumLvl > 13) { AddMenuItem(MenuTele, "14", "Stage 14"); }
	if (NumLvl > 14) { AddMenuItem(MenuTele, "15", "Stage 15"); }
	
	SetMenuExitButton(MenuTele, true); 
	DisplayMenu(MenuTele, client, 20); 
}

public MenuHandlerstafe(Handle:menu, MenuAction:action, param1, param2) 
{ 
	if(action == MenuAction_Select) 
	{
		{
			decl Float:vec[3] = {0.0, ...}; TeleportEntity(param1, lvl_Tele[param2 + 1], NULL_VECTOR, vec);
			MenuTele = INVALID_HANDLE;
		}
		Clear_All(param1);
		EnableStage[param1] = true;
		PrintHintText(param1, "-=Practik Mode=-");
		if (SurfLevel) { decl String:Buf[32]; Format(Buf, 32, "[practik mode] -  "); CS_SetClientClanTag(param1, Buf); }
	} 
	else if(action == MenuAction_End) 
	{ 
		if (MenuTele != INVALID_HANDLE)
		{
			CloseHandle(MenuTele); 
			MenuTele = INVALID_HANDLE;
		}
	} 
}

public Action:Command_TeleportGoback(client) /////////////////////////GOBACK
{
	if (!SurfLevel) { PrintToChat(client, "\x05[\x04SurfTimer\x05] \x01- \x05Тут нету уровней."); EnableStage[client] = false; return; }
	if (LvlZone[client] ==1) { PrintToChat(client, "\x05[\x04SurfTimer\x05] \x01- \x05Дальше некуда."); return; }
	if (InLvl[client]) { decl Float:vec[3] = {15000.0, -15000.0, 15000.0}; TeleportEntity(client, vec, NULL_VECTOR, NULL_VECTOR); }
	LvlZone[client]--; 
	CreateTimer(0.1, RunTele, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:RunTele(Handle:timer,any:client)
{
	decl Float:vec[3] = {0.0, ...}; TeleportEntity(client, lvl_Tele[LvlZone[client]], NULL_VECTOR, vec);
}