new Handle:Timer_Advert = INVALID_HANDLE;
new numAdvert = 1;

public Command_Advert()
{
	if(Timer_Advert != INVALID_HANDLE) { KillTimer(Timer_Advert); Timer_Advert = INVALID_HANDLE; }
	Timer_Advert = CreateTimer(30.0, SetTimer_TimerAdvert, _, TIMER_REPEAT);
}

public Action:SetTimer_TimerAdvert(Handle:timer)
{
	if (numAdvert > 5) { numAdvert = 1; }
	switch (numAdvert)
	{
		case (1): { CPrintToChatAll("%t", "Advert1"); }
		case (2): { CPrintToChatAll("%t", "Advert2"); }
		case (3): { PrintToChatAll("\x04[SurfTimer] \x01- \x05Текущая карта: %s", currentMap); }
		case (4): { CPrintToChatAll("%t", "Advert3"); }
		case (5): { CPrintToChatAll("%t", "Advert4"); }
	}
	numAdvert++;
}