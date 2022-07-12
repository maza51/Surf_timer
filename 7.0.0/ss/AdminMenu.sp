new Handle:g_AdminMenu;

public Action:Command_AdminMenu(client, args)
{
	Clear_All(client);
	EnableStage[client] = true;
	DisplayMenu(g_AdminMenu, client, 1000);
}

Handle:AdminMenu()
{
	new Handle:Zone = CreateMenu(Menu);
	SetMenuTitle(Zone, "Твое меню =):\n ");
	AddMenuItem(Zone, "tri", "Показать тригер.");
	AddMenuItem(Zone, "9", "Принт.\n ");
	AddMenuItem(Zone, "1", "+ Поднять верх");
	AddMenuItem(Zone, "2", "- Опустить верх");
	AddMenuItem(Zone, "3", "+ Поднять низ");
	AddMenuItem(Zone, "4", "- Опустить низ");
	AddMenuItem(Zone, "", ".", ITEMDRAW_DISABLED);
	AddMenuItem(Zone, "9", "Принт.\n ");
	AddMenuItem(Zone, "5", "+ Шире");
	AddMenuItem(Zone, "6", "- Уже");
	AddMenuItem(Zone, "7", "+ Длиннее");
	AddMenuItem(Zone, "8", "- Короче");
	AddMenuItem(Zone, "", ".", ITEMDRAW_DISABLED);
	AddMenuItem(Zone, "", ".", ITEMDRAW_DISABLED);
	AddMenuItem(Zone, "Lvl1t", "Лвл 1 tele");
	AddMenuItem(Zone, "Lvl2t", "Лвл 2 tele");
	AddMenuItem(Zone, "Lvl3t", "Лвл 3 tele");
	AddMenuItem(Zone, "Lvl4t", "Лвл 4 tele");
	AddMenuItem(Zone, "Lvl5t", "Лвл 5 tele");
	AddMenuItem(Zone, "Lvl6t", "Лвл 6 tele");
	AddMenuItem(Zone, "Lvl7t", "Лвл 7 tele");
	AddMenuItem(Zone, "Lvl8t", "Лвл 8 tele");
	AddMenuItem(Zone, "Lvl9t", "Лвл 9 tele");
	AddMenuItem(Zone, "Lvl10t", "Лвл 10 tele");
	return Zone;
}

public Menu(Handle:Zone, MenuAction:action, param1, param2)
{
	//new pos = GetMenuSelectionPosition();
	if (action == MenuAction_Select)
	{
		new pos = GetMenuSelectionPosition();
		new String:info[32];
		GetMenuItem(Zone, param2, info, sizeof(info));
		
		if (StrEqual(info,"tri")) { CpSetterTimer = CreateTimer(0.1, CpSetTimer, param1, TIMER_REPEAT); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"Lvl1t")) { SetTeleport(param1, "101"); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"Lvl2t")) { SetTeleport(param1, "102"); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"Lvl3t")) { SetTeleport(param1, "103"); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"Lvl4t")) { SetTeleport(param1, "104"); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"Lvl5t")) { SetTeleport(param1, "105"); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"Lvl6t")) { SetTeleport(param1, "106"); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"Lvl7t")) { SetTeleport(param1, "107"); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"Lvl8t")) { SetTeleport(param1, "108"); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"Lvl9t")) { SetTeleport(param1, "109"); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"Lvl10t")) { SetTeleport(param1, "110"); DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"1")) { maxb[2] =  maxb[2] + 50.0; DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"2")) { maxb[2] =  maxb[2] - 50.0; DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"3")) { minb[2] =  minb[2] + 50.0; DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"4")) { minb[2] =  minb[2] - 50.0; DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"5")) { maxb[1] =  maxb[1] + 25.0; minb[1] =  minb[1] - 25.0; DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"6")) { maxb[1] =  maxb[1] - 25.0; minb[1] =  minb[1] + 25.0; DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"7")) { maxb[0] =  maxb[0] + 25.0; minb[0] =  minb[0] - 25.0; DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"8")) { maxb[0] =  maxb[0] - 25.0; minb[0] =  minb[0] + 25.0; DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); }
		if (StrEqual(info,"9")) 
		{
			DisplayMenuAtItem(g_AdminMenu, param1, pos, 1000); 
			new String:buff[512];
			Format(buff, sizeof(buff), "\"targetname\" \"CpLvl_2\" \"cp\" \"%f:%f:%f\" \"minmax\" \"%f:%f:%f:%f:%f:%f\"", cpsetEcords[0], cpsetEcords[1], cpsetEcords[2], minb[0], minb[1], minb[2], maxb[0], maxb[1], maxb[2]);
			PrintToChatAll("%s", buff);
			CloseHandle(CpSetterTimer); CpSetterTimer = INVALID_HANDLE;
		}
	}
}