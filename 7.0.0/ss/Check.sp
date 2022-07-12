new Float:maxb[3] = {100.0, 100.0, 100.0}; 
new Float:minb[3] = {-100.0, -100.0, -0.0};
new Float:cpsetEcords[3]; 
new BeamSpriteFollow;

new trigger[MAX_CP] = -1;
new triggerB[MAX_CP_B] = -1;


public Action:CpSetTimer(Handle:timer, any:client)
{
	if(client != 0 && IsClientInGame(client))
	{
		GetClientAbsOrigin(client,cpsetEcords);
		
		decl Float:leftbottomfront[3]; 
		leftbottomfront[0] = cpsetEcords[0] + maxb[0]; 
		leftbottomfront[1] = cpsetEcords[1] + maxb[1]; 
		leftbottomfront[2] = cpsetEcords[2] + minb[2];
		decl Float:rightbottomfront[3]; 
		rightbottomfront[0] = cpsetEcords[0] + minb[0]; 
		rightbottomfront[1] = cpsetEcords[1] + maxb[1]; 
		rightbottomfront[2] = cpsetEcords[2] + minb[2];
		
		decl Float:leftbottomback[3]; 
		leftbottomback[0] = cpsetEcords[0] + maxb[0]; 
		leftbottomback[1] = cpsetEcords[1] + minb[1]; 
		leftbottomback[2] = cpsetEcords[2] + minb[2];
		decl Float:rightbottomback[3]; 
		rightbottomback[0] = cpsetEcords[0] + minb[0]; 
		rightbottomback[1] = cpsetEcords[1] + minb[1]; 
		rightbottomback[2] = cpsetEcords[2] + minb[2];
		
		
		decl Float:lefttopfront[3]; 
		lefttopfront[0] = cpsetEcords[0] + maxb[0]; 
		lefttopfront[1] = cpsetEcords[1] + maxb[1]; 
		lefttopfront[2] = cpsetEcords[2] + maxb[2];
		decl Float:righttopfront[3]; 
		righttopfront[0] = cpsetEcords[0] + minb[0]; 
		righttopfront[1] = cpsetEcords[1] + maxb[1]; 
		righttopfront[2] = cpsetEcords[2] + maxb[2];
		
		decl Float:lefttopback[3]; 
		lefttopback[0] = cpsetEcords[0] + maxb[0]; 
		lefttopback[1] = cpsetEcords[1] + minb[1]; 
		lefttopback[2] = cpsetEcords[2] + maxb[2];
		decl Float:righttopback[3]; 
		righttopback[0] = cpsetEcords[0] + minb[0]; 
		righttopback[1] = cpsetEcords[1] + minb[1]; 
		righttopback[2] = cpsetEcords[2] + maxb[2];
		

		TE_SetupBeamPoints(leftbottomfront,rightbottomfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(leftbottomfront,leftbottomback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(leftbottomfront,lefttopfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		
		TE_SetupBeamPoints(lefttopfront,righttopfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(lefttopfront,lefttopback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(righttopback,lefttopback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(righttopback,righttopfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		
		TE_SetupBeamPoints(rightbottomback,leftbottomback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(rightbottomback,rightbottomfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(rightbottomback,righttopback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		
		TE_SetupBeamPoints(rightbottomfront,righttopfront,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
		TE_SetupBeamPoints(leftbottomback,lefttopback,BeamSpriteFollow,0,0,0,0.1,3.0,3.0,10,0.0,{50,255,0,255},0);TE_SendToAll();
	}
	else
	{
		CloseHandle(CpSetterTimer); 
		CpSetterTimer = INVALID_HANDLE;
	}
}

public Action:Create_multiple(String:name[512], Float:cp[3], Float:maxbounds[3], Float:minbounds[3], num)
{
	trigger[num] = -1; 
	trigger[num] = CreateEntityByName("trigger_multiple"); 
	if (trigger[num] != -1){
		
		DispatchKeyValueVector(trigger[num], "origin", cp ); 
		DispatchKeyValue(trigger[num], "classname", "trigger_multiple"); 
		DispatchKeyValue(trigger[num], "targetname", name); 
		DispatchKeyValue(trigger[num], "spawnflags", "1"); 
		DispatchKeyValue(trigger[num], "StartDisabled", "0");
		DispatchSpawn(trigger[num]);
		ActivateEntity(trigger[num]); 
		SetEntityModel(trigger[num], "models/player/ct_urban.mdl");
		
		SetEntPropVector(trigger[num], Prop_Send, "m_vecMins", minbounds); 
		SetEntPropVector(trigger[num], Prop_Send, "m_vecMaxs", maxbounds);
		
		SetEntProp(trigger[num], Prop_Send, "m_nSolidType", 2); 
		
		new enteffects = GetEntProp(trigger[num], Prop_Send, "m_fEffects"); 
		enteffects |= 32; 
		SetEntProp(trigger[num], Prop_Send, "m_fEffects", enteffects);
		
		new Float:vec[3];
		GetEntPropVector(trigger[num], Prop_Send, "m_vecOrigin", vec);
		PrintToServer("%f %f %f = %i = %i", vec[0],vec[1],vec[2], num, trigger[num]);
	}
}

public Action:Create_multiple_b(String:name[512], Float:cp[3], Float:maxbounds[3], Float:minbounds[3], num)
{
	triggerB[num] = -1;
	triggerB[num] = CreateEntityByName("trigger_multiple"); 
	if (triggerB[num] != -1){
		PrintToServer("Start Creat = %i", num);
		DispatchKeyValueVector(triggerB[num], "origin", cp ); 
		DispatchKeyValue(triggerB[num], "classname", "trigger_multiple"); 
		DispatchKeyValue(triggerB[num], "targetname", name); 
		DispatchKeyValue(triggerB[num], "spawnflags", "1"); 
		DispatchKeyValue(triggerB[num], "StartDisabled", "0");
		DispatchSpawn(triggerB[num]);
		ActivateEntity(triggerB[num]); 
		SetEntityModel(triggerB[num], "models/player/ct_urban.mdl");
		
		SetEntPropVector(triggerB[num], Prop_Send, "m_vecMins", minbounds); 
		SetEntPropVector(triggerB[num], Prop_Send, "m_vecMaxs", maxbounds);
		
		SetEntProp(triggerB[num], Prop_Send, "m_nSolidType", 2); 
		
		new enteffects = GetEntProp(triggerB[num], Prop_Send, "m_fEffects"); 
		enteffects |= 32; 
		SetEntProp(triggerB[num], Prop_Send, "m_fEffects", enteffects);
		
		new Float:vec[3];
		GetEntPropVector(triggerB[num], Prop_Send, "m_vecOrigin", vec);
		PrintToServer("%f %f %f = %i = %i", vec[0],vec[1],vec[2], num, triggerB[num]);
	}
}