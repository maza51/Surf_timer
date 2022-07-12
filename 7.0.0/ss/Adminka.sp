new Vote_Yes = 0;
new Vote_No = 0;
new VoteTime = 0;
new Handle:TimerVoteExtend = INVALID_HANDLE;
new bool:ActiveVotePlayer[MAXPLAYERS+1] = false;

public Action:Command_PreVoteExtend(client, args)
{
	VoteTime = 15;
	Vote_Yes = 0;
	Vote_No = 0;
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			ActiveVotePlayer[i] = true;
		}
	}
	
	if (TimerVoteExtend != INVALID_HANDLE) {
		KillTimer(TimerVoteExtend);
		TimerVoteExtend = INVALID_HANDLE;
	}
	
	TimerVoteExtend = CreateTimer(1.0, SetTimerVote, _, TIMER_REPEAT);
}

public Action:SetTimerVote(Handle:timer)
{
	if (VoteTime < 1) { 
		if (TimerVoteExtend != INVALID_HANDLE) {
			KillTimer(TimerVoteExtend);
			TimerVoteExtend = INVALID_HANDLE;
		}
		ItogGolosovanieExtend(); 
		return; 
	}
	VoteTime--;
	Command_VoteExtend();
}

public Action:ItogGolosovanieExtend()
{
	if (Vote_Yes > Vote_No)
		ExtendMapTimeLimit(600);
}

public Action:Command_VoteExtend()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			new Handle:panel = CreatePanel();
			decl String:buffer[512];
			SetPanelTitle(panel, "Extend the map \nfor 10 minutes?\n ");
			DrawPanelText(panel, " ");
			Format(buffer, sizeof(buffer), "Yes = %i\nNo  = %i", Vote_Yes, Vote_No);
			DrawPanelText(panel, buffer);
			DrawPanelText(panel, " ");
			Format(buffer, sizeof(buffer), "%i.s", VoteTime);
			DrawPanelText(panel, buffer);
			DrawPanelText(panel, " ");
			if (ActiveVotePlayer[client]) {
				DrawPanelItem(panel, "Yes");
				DrawPanelItem(panel, "No");
			}
			SendPanelToClient(panel, client, VoteExt, 1);
			CloseHandle(panel);
		}
	}
}

public VoteExt(Handle:panel, MenuAction:action, param1, param2)
{
	if (IsClientConnected(param1))
	{
		if (action == MenuAction_Select)
		{
			if (param2==1)
				Vote_Yes++;
			else if (param2==2)
				Vote_No++;
			ActiveVotePlayer[param1] = false;
		}
	}
}