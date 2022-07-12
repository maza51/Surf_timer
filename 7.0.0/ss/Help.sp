
public Action:Command_Help(client){
	new Handle:main = CreateMenu(menuee);
	decl String:buffer[512];
	SetMenuTitle(main,"Инфо:\n------------------------------");
	Format(buffer, sizeof(buffer), "%T", "Help_tele", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_stage", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_goback", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_rest", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_respawn", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_op", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_hide", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_pr", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_rank", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_top", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_surftop", client);
	AddMenuItem(main, "", buffer);
	Format(buffer, sizeof(buffer), "%T", "Help_mtop", client);
	AddMenuItem(main, "", buffer);
	AddMenuItem(main, "", "!chatranks\nChat Rank\n ");
	AddMenuItem(main, "", "!wr\n Показывает рекорд карты.\n ");
	DisplayMenu(main, client, 30);
}

public Action:Command_Help_Top10Poins(client){
	new Handle:panel = CreatePanel();
	decl String:buffer[200];
	Format(buffer, sizeof(buffer), "%T", "HelpTop10", client);
	SetPanelTitle(panel, buffer);
	DrawPanelText(panel, "Место 1       [+150]");
	DrawPanelText(panel, "Место 2       [+93]");
	DrawPanelText(panel, "Место 3       [+66]");
	DrawPanelText(panel, "Место 4       [+49]");
	DrawPanelText(panel, "Место 5       [+40]");
	DrawPanelText(panel, "Место 6       [+33]");
	DrawPanelText(panel, "Место 7       [+27]");
	DrawPanelText(panel, "Место 8       [+22]");
	DrawPanelText(panel, "Место 9       [+18]");
	DrawPanelText(panel, "Место 10     [+15]\n ");
	DrawPanelItem(panel, "Закрыть");
	SendPanelToClient(panel, client, PanelHandlerNothing, 30);
}

public Action:Command_Help_ChatRanks(client){
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Chat Ranks\n ");
	DrawPanelText(panel, "Rank [1 - 5]  -  [PRO]");
	DrawPanelText(panel, "Rank [6 - 10]  -  [BEST]");
	DrawPanelText(panel, "Rank [11 - 20]  -  [Surfer]");
	DrawPanelText(panel, "Rank [21 - 30]  -  [Recruit]");
	DrawPanelText(panel, "Rank [30 < ]  -  [NooB]");
	DrawPanelItem(panel, "Закрыть");
	SendPanelToClient(panel, client, PanelHandlerNothing, 30);
}

public Command_Help_KSF(client){
	new Handle:panel = CreatePanel();
	SetPanelTitle(panel, "Welcome to our server!");
	DrawPanelText(panel, "------------------------------------");
	DrawPanelText(panel, "The original idea of ​​a server:\n ");
	DrawPanelText(panel, "KSFclan SurfTimer Server!");
	DrawPanelText(panel, "------------------------------------");
	DrawPanelText(panel, "   ");
	DrawPanelItem(panel, "close");
	SendPanelToClient(panel, client, PanelHandlerNothing, 30);
}

public Action:PlaySongLeader(){
	//EmitSoundToAll(sound3);
	EmitSoundToAll(sound3, _, _, SNDLEVEL_DRYER, _, SNDVOL_NORMAL, _, _, _, _, _, _); 
	CreateTimer(1.3,PlaySongLeader_part2, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:PlaySongLeader_part2(Handle:timer)
{
	EmitSoundToAll(sound4);
}

public Command_WelcomeMesage(client){
	new Handle:panelWelcome = CreatePanel();
	decl String:buffer[512];
	SetPanelTitle(panelWelcome, "Welcome to our server!");
	DrawPanelText(panelWelcome, "------------------------------------");
	Format(buffer, sizeof(buffer), "%T", "Welcome_mesage", client);
	DrawPanelText(panelWelcome, buffer);
	DrawPanelText(panelWelcome, "------------------------------------");
	DrawPanelText(panelWelcome, "   ");
	if (!IsPlayerAlive(client) && GetClientTeam(client) > 1) { DrawPanelItem(panelWelcome, "Respawn"); }
	else { DrawPanelItem(panelWelcome, "Respawn", ITEMDRAW_DISABLED); }
	DrawPanelItem(panelWelcome, "Help");
	DrawPanelText(panelWelcome, "   ");
	DrawPanelItem(panelWelcome, "close");
	SendPanelToClient(panelWelcome, client, WelcomePanelItem, 30);
}

public WelcomePanelItem(Handle:panelWelcome, MenuAction:action, param1, param2)
{
	if (IsClientConnected(param1))
	{
		if (action == MenuAction_Select)
		{
			if (param2==1)
				Command_Respawn(param1, param1);
			else if (param2==2)
				Command_Help(param1);
		}
	}
}