array<CHitmarker> g_Hitmarker;
CHitmarkerParam g_HitmarkerParam;

class CColor
{
	CColor() { };
	CColor(int iColorRed, int iColorGreen, int iColorBlue, int iColorAlpha)
	{
		iRed = iColorRed;
		iGreen = iColorGreen;
		iBlue = iColorBlue;
		iAlpha = iColorAlpha;
	};

	int iRed;
	int iGreen;
	int iBlue;
	int iAlpha;
}

class CHitmarker
{
	int iSize = 2;
	int iHitSnd = 1;
	
	//Пока что без KillSound
	int iKillSnd = 0;
	
	float fScreenFadeTime = 0.3f;
	float fScreenFadeHoldTime = 0.3f;
	CColor cScreenFadeColor(25, 0, 205, 55);
	
	float fHoldTime = 0.3f;
	float fFadeOutTime = 0.1f;
	
	CColor cHitColor(255, 255, 255, 125);
	CColor cKillColor(255, 0, 0, 125);
	
	CBasePlayer@ pPlayer = null;
	
	void ResetToDefault()
	{
		iSize = 2;
		iHitSnd = 1;
		iKillSnd = 0;
		fHoldTime = 0.3;
		fFadeOutTime = 0.1;
		fScreenFadeTime = 0.3f;
		fScreenFadeHoldTime = 0.3f;
		cScreenFadeColor = CColor(25, 0, 205, 55);
		cHitColor = CColor(255, 255, 255, 125);
		cKillColor = CColor(255, 0, 0, 125);
		@pPlayer = null;
	}
}

class CHitmarkerParam
{
	bool bIsEnabled = true;
	bool bAdminsOnly = false;
}

void MapInit() 
{
	for (uint i = 1; i <= 5; i++)
	{
		g_Game.PrecacheModel("sprites/hitmarker/hitmarker" + string(i) + ".spr");
		g_Game.PrecacheGeneric("sound/hitmarker/hitsound/hitsound" + string(i) + ".wav");
		g_SoundSystem.PrecacheSound("hitmarker/hitsound/hitsound" + string(i) + ".wav");
	}
}

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor("kek");
	g_Module.ScriptInfo.SetContactInfo("https://github.com/kekekekkek/Hitmarker");
	
	g_Hooks.RegisterHook(Hooks::Player::ClientSay, @ClientSay);
	g_Hooks.RegisterHook(Hooks::Player::ClientDisconnect, @ClientDisconnect);
	
	g_Hooks.RegisterHook(Hooks::Weapon::WeaponPrimaryAttack, @WeaponPrimaryAttack);
	g_Hooks.RegisterHook(Hooks::Weapon::WeaponSecondaryAttack, @WeaponSecondaryAttack);
	g_Hooks.RegisterHook(Hooks::Weapon::WeaponTertiaryAttack, @WeaponTertiaryAttack);
	
	g_Hitmarker.resize(g_Engine.maxClients + 1);
}

bool IsPlayerAdmin(CBasePlayer@ pPlayer)
{
	return (g_PlayerFuncs.AdminLevel(pPlayer) >= ADMIN_YES);
}

bool IsNaN(string strValue)
{
	int iPointCount = 0;

	for (uint i = 0; i < strValue.Length(); i++)
	{
		if (i == 0 && strValue[i] == '-')
			continue;
			
		if (strValue[i] == '.')
		{
			iPointCount++;
		
			if (iPointCount < 2)
				continue;
		}
	
		if (!isdigit(strValue[i]))
			return true;
	}
	
	return false;
}

void DrawHitmarker(CBasePlayer@ pPlayer, float fHoldTime, float fFadeOutTime, CColor cColor, string strFileName)
{
	HUDSpriteParams pHudSpriteParams;
	
	pHudSpriteParams.x = 0;
	pHudSpriteParams.y = 0;
	pHudSpriteParams.holdTime = fHoldTime;
	pHudSpriteParams.fadeoutTime = fFadeOutTime;
	pHudSpriteParams.spritename = strFileName;
	pHudSpriteParams.color1 = RGBA(cColor.iRed, cColor.iGreen, cColor.iBlue, cColor.iAlpha);
	pHudSpriteParams.flags = (HUD_ELEM_ABSOLUTE_Y | HUD_ELEM_SCR_CENTER_Y | HUD_ELEM_SCR_CENTER_X);
	
	g_PlayerFuncs.HudCustomSprite(pPlayer, pHudSpriteParams);
}

void MonsterTakeDamage(CBasePlayer@ pPlayer, CHitmarker lHitmarker, CHitmarkerParam lHtmarkerParam)
{
	if (!lHtmarkerParam.bIsEnabled)
		return;

	if (lHtmarkerParam.bAdminsOnly)
	{
		if (!IsPlayerAdmin(pPlayer))
			return;
	}

	for (int i = 0; i < g_Engine.maxEntities; i++)
	{
		edict_t@ pEdict = g_EntityFuncs.IndexEnt(i);
		
		if (g_EntityFuncs.IsValidEntity(pEdict))
		{
			if (g_EntityFuncs.IsValidEntity(pEdict.vars.dmg_inflictor))
			{
				string strAttacker = pEdict.vars.dmg_inflictor.vars.netname;
			
				if (strAttacker == pPlayer.pev.netname)
				{
					if (pEdict.vars.dmg_take > 0.0f)
					{
						DrawHitmarker(pPlayer, lHitmarker.fHoldTime, lHitmarker.fFadeOutTime, (pEdict.vars.health <= 1 
							? CColor(lHitmarker.cKillColor.iRed, lHitmarker.cKillColor.iGreen, lHitmarker.cKillColor.iBlue, lHitmarker.cKillColor.iAlpha) 
							: CColor(lHitmarker.cHitColor.iRed, lHitmarker.cHitColor.iGreen, lHitmarker.cHitColor.iBlue, lHitmarker.cHitColor.iAlpha)), "hitmarker/hitmarker" + lHitmarker.iSize + ".spr");
						g_SoundSystem.EmitSound(pPlayer.edict(), CHAN_AUTO, "hitmarker/hitsound/hitsound" + lHitmarker.iHitSnd + ".wav", 1.0f, ATTN_STATIC);
						
						if (pEdict.vars.deadflag == DEAD_DYING)
							g_PlayerFuncs.ScreenFade(pPlayer, Vector(lHitmarker.cScreenFadeColor.iRed, lHitmarker.cScreenFadeColor.iGreen, lHitmarker.cScreenFadeColor.iBlue), lHitmarker.fScreenFadeTime, lHitmarker.fScreenFadeHoldTime, lHitmarker.cScreenFadeColor.iAlpha, 0);

						//Вроде бы процесс игры не ломает (хотя при большом количестве игроков просаживает fps)
						g_EntityFuncs.DispatchKeyValue(pEdict, "dmg_take", "0");				
						break;
					}
				}
			}
		}
	}
}

HookReturnCode ClientSay(SayParameters@ pSayParam)
{
	array<string> strCommands = 
	{
		"hm", 
		"hm_size", 
		"hm_hsnd",
		"hm_ksnd",
		"hm_holdtime",
		"hm_fadetime",
		"hm_screenfadetime",
		"hm_screenholdtime",
		"hm_screencolor",
		"hm_hcolor",
		"hm_kcolor",
		"hm_ao",
	};

	array<string> strDesc =
	{
		"[HMInfo]: Usage: .hm or /hm or !hm <enabled>. Example: !hm 1\n",
		"[HMInfo]: Usage: .hm_size or /hm_size or !hm_size <size>. Example: !hm_size 2\n",
		"[HMInfo]: Usage: .hm_hsnd or /hm_hsnd or !hm_hsnd <sound>. Example: !hm_hsnd 1\n",
		"[HMInfo]: Usage: .hm_ksnd or /hm_ksnd or !hm_ksnd <sound>. Example: !hm_ksnd 2 (Currently not working)\n",
		"[HMInfo]: Usage: .hm_holdtime or /hm_holdtime or !hm_holdtime <time>. Example: !hm_holdtime 0.3\n",
		"[HMInfo]: Usage: .hm_fadetime or /hm_fadetime or !hm_fadetime <time>. Example: !hm_fadetime 0.1\n",
		"[HMInfo]: Usage: .hm_screenfadetime or /hm_screenfadetime or !hm_screenfadetime <time>. Example: !hm_screenfadetime 0.3\n",
		"[HMInfo]: Usage: .hm_screenholdtime or /hm_screenholdtime or !hm_screenholdtime <time>. Example: !hm_screenholdtime 0.3\n",
		"[HMInfo]: Usage: .hm_screencolor or /hm_screencolor or !hm_screencolor <red> <green> <blue> <alpha>. Example: !hm_screencolor 25 0 205 55\n",
		"[HMInfo]: Usage: .hm_hcolor or /hm_hcolor or !hm_hcolor <red> <green> <blue> <alpha>. Example: !hm_hcolor 255 255 255 125\n",
		"[HMInfo]: Usage: .hm_kcolor or /hm_kcolor or !hm_kcolor <red> <green> <blue> <alpha>. Example: !hm_kcolor 255 0 0 125\n",
		"[HMInfo]: Usage: .hm_ao or /hm_ao or !hm_ao <adminsonly>. Example: !hm_ao 0\n",
	};
	
	int iEntIndex = g_EntityFuncs.EntIndex(pSayParam.GetPlayer().edict());
	@g_Hitmarker[iEntIndex].pPlayer = pSayParam.GetPlayer();

	bool bHide = false, bIsNaN = false;
	for (uint i = 0; i < strCommands.length(); i++)
	{
		string strText = pSayParam.GetArguments().Arg(0).ToLowercase();
		
		if (pSayParam.GetArguments().ArgC() == 1)
		{
			if (strText == ".hm_reset"
				|| strText == "/hm_reset"
				|| strText == "!hm_reset")
			{
				g_Hitmarker[iEntIndex].ResetToDefault();
				g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: All values have been reset to their default values.");
				
				bHide = true;
				break;
			}
		}
	
		if ((strText == ("." + strCommands[i]))
			|| (strText == ("/" + strCommands[i]))
			|| (strText == ("!" + strCommands[i])))
		{
			if (!IsPlayerAdmin(pSayParam.GetPlayer()))
			{
				if (i == 0 || i == 11)
				{
					g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMError]: This command is for admins only.\n");
					bHide = true;
					
					break;
				}
			}
		
			if (pSayParam.GetArguments().ArgC() == 1)
			{
				bHide = true;
				g_PlayerFuncs.SayText(pSayParam.GetPlayer(), strDesc[i]);
				
				break;
			}
			else if (pSayParam.GetArguments().ArgC() == 2)
			{
				string strArg = pSayParam.GetArguments().Arg(1);
				bIsNaN = IsNaN(strArg);
			
				if (i == 0)
				{
					if (!bIsNaN)
					{
						g_HitmarkerParam.bIsEnabled = (Math.clamp(0, 1, atoi(strArg)) > 0);
						g_PlayerFuncs.SayTextAll(pSayParam.GetPlayer(), (g_HitmarkerParam.bIsEnabled 
							? "[HMSuccess]: The hitmarker feature has been enabled!\n" 
							: "[HMSuccess]: The hitmarker feature has been disabled!\n"));
						
						bHide = true;
					}
				}
				
				if (i == 1)
				{
					if (!bIsNaN)
					{
						g_Hitmarker[iEntIndex].iSize = Math.clamp(0, 5, atoi(strArg));
						g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: The hitmarker size value has been successfully changed to \"" + g_Hitmarker[iEntIndex].iSize + "\"!\n");
						
						bHide = true;
					}
				}
				
				if (i == 2)
				{
					if (!bIsNaN)
					{
						g_Hitmarker[iEntIndex].iHitSnd = Math.clamp(0, 5, atoi(strArg));
						g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: The hit sound value has been successfully changed to \"" + g_Hitmarker[iEntIndex].iHitSnd + "\"!\n");
						
						bHide = true;
					}
				}
				
				if (i == 3)
				{
					if (!bIsNaN)
					{
						g_Hitmarker[iEntIndex].iKillSnd = Math.clamp(0, 2, atoi(strArg));
						g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: The kill sound value has been successfully changed to \"" + g_Hitmarker[iEntIndex].iKillSnd + "\"!\n");
						
						bHide = true;
					}
				}
				
				if (i == 4)
				{
					if (!bIsNaN)
					{
						g_Hitmarker[iEntIndex].fHoldTime = Math.clamp(0.0f, 1.0f, atof(strArg));
						g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: The hitmarker hold time value has been successfully changed to \"" + g_Hitmarker[iEntIndex].fHoldTime + "\"!\n");
						
						bHide = true;
					}
				}
				
				if (i == 5)
				{
					if (!bIsNaN)
					{
						g_Hitmarker[iEntIndex].fFadeOutTime = Math.clamp(0.0f, 1.0f, atof(strArg));
						g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: The hitmarker fade time value has been successfully changed to \"" + g_Hitmarker[iEntIndex].fFadeOutTime + "\"!\n");
						
						bHide = true;
					}
				}
				
				if (i == 6)
				{
					if (!bIsNaN)
					{
						g_Hitmarker[iEntIndex].fScreenFadeTime = Math.clamp(0.0f, 1.0f, atof(strArg));
						g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: The screen fade time value has been successfully changed to \"" + g_Hitmarker[iEntIndex].fScreenFadeTime + "\"!\n");
						
						bHide = true;
					}
				}
				
				if (i == 7)
				{
					if (!bIsNaN)
					{
						g_Hitmarker[iEntIndex].fScreenFadeHoldTime = Math.clamp(0.0f, 1.0f, atof(strArg));
						g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: The screen fade hold time value has been successfully changed to \"" + g_Hitmarker[iEntIndex].fScreenFadeHoldTime + "\"!\n");
						
						bHide = true;
					}
				}
				
				if (i == 11)
				{
					if (!bIsNaN)
					{
						g_HitmarkerParam.bAdminsOnly = (Math.clamp(0, 1, atoi(strArg)) > 0);
						g_PlayerFuncs.SayTextAll(pSayParam.GetPlayer(), (g_HitmarkerParam.bAdminsOnly 
							? "[HMInfo]: The hitmarker feature is now available only to admins.\n" 
							: "[HMInfo]: The hitmarker feature is now available to everyone!\n"));
						
						bHide = true;
					}
				}
			}
			else if (pSayParam.GetArguments().ArgC() == 5)
			{
				array<string> strArgs(pSayParam.GetArguments().ArgC() - 1);
				
				for (uint iArg = 0; iArg < strArgs.length(); iArg++)
				{
					strArgs[iArg] = pSayParam.GetArguments().Arg(iArg + 1);
					
					if (IsNaN(strArgs[iArg]))
					{
						bIsNaN = true;
						break;
					}
					
					strArgs[iArg] = string(Math.clamp(0, 255, atoi(strArgs[iArg])));
				}
				
				//Не ставьте черный цвет (0 0 0 255) - иначе он просто не будет отображаться
				if (i == 8)
				{
					g_Hitmarker[iEntIndex].cScreenFadeColor.iRed = atoi(strArgs[0]);
					g_Hitmarker[iEntIndex].cScreenFadeColor.iGreen = atoi(strArgs[1]);
					g_Hitmarker[iEntIndex].cScreenFadeColor.iBlue = atoi(strArgs[2]);
					g_Hitmarker[iEntIndex].cScreenFadeColor.iAlpha = atoi(strArgs[3]);
					
					g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: The screen fade color value has been successfully changed to \"" + strArgs[0].opAdd(" ") + strArgs[1].opAdd(" ") + strArgs[2].opAdd(" ") + strArgs[3] + "\"!\n");
					bHide = true;
				}
				
				if (i == 9)
				{
					g_Hitmarker[iEntIndex].cHitColor.iRed = atoi(strArgs[0]);
					g_Hitmarker[iEntIndex].cHitColor.iGreen = atoi(strArgs[1]);
					g_Hitmarker[iEntIndex].cHitColor.iBlue = atoi(strArgs[2]);
					g_Hitmarker[iEntIndex].cHitColor.iAlpha = atoi(strArgs[3]);
					
					g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: The hit color value has been successfully changed to \"" + strArgs[0].opAdd(" ") + strArgs[1].opAdd(" ") + strArgs[2].opAdd(" ") + strArgs[3] + "\"!\n");
					bHide = true;
				}
				
				if (i == 10)
				{
					g_Hitmarker[iEntIndex].cKillColor.iRed = atoi(strArgs[0]);
					g_Hitmarker[iEntIndex].cKillColor.iGreen = atoi(strArgs[1]);
					g_Hitmarker[iEntIndex].cKillColor.iBlue = atoi(strArgs[2]);
					g_Hitmarker[iEntIndex].cKillColor.iAlpha = atoi(strArgs[3]);
					
					g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMSuccess]: The kill color value has been successfully changed to \"" + strArgs[0].opAdd(" ") + strArgs[1].opAdd(" ") + strArgs[2].opAdd(" ") + strArgs[3] + "\"!\n");
					bHide = true;
				}
			}
		}
	}
	
	if (bIsNaN)
	{
		if (pSayParam.GetArguments().ArgC() == 1)
			g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMError]: The argument is not a number!\n");
		
		if (pSayParam.GetArguments().ArgC() == 5)
			g_PlayerFuncs.SayText(pSayParam.GetPlayer(), "[HMError]: One or more arguments is not a number!\n");
		
		bHide = true;
	}
	
	if (bHide)
	{
		pSayParam.ShouldHide = true;
		return HOOK_HANDLED;
	}

	return HOOK_CONTINUE;
}

HookReturnCode WeaponPrimaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
	MonsterTakeDamage(pPlayer, g_Hitmarker[g_EntityFuncs.EntIndex(pPlayer.edict())], g_HitmarkerParam);
	return HOOK_CONTINUE;
}

HookReturnCode WeaponSecondaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
	MonsterTakeDamage(pPlayer, g_Hitmarker[g_EntityFuncs.EntIndex(pPlayer.edict())], g_HitmarkerParam);
	return HOOK_CONTINUE;
}

HookReturnCode WeaponTertiaryAttack(CBasePlayer@ pPlayer, CBasePlayerWeapon@ pWeapon)
{
	MonsterTakeDamage(pPlayer, g_Hitmarker[g_EntityFuncs.EntIndex(pPlayer.edict())], g_HitmarkerParam);
	return HOOK_CONTINUE;
}

HookReturnCode ClientDisconnect(CBasePlayer@ pPlayer)
{
	//Сбрасываем значения для вышедшего игрока, так как его место может занять другой игрок с тем же идентификатором
	g_Hitmarker[g_EntityFuncs.EntIndex(pPlayer.edict())].ResetToDefault();

	return HOOK_CONTINUE;
}