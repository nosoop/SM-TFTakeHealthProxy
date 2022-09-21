/**
 * TakeHealth Proxy
 * 
 * Provides a few forwards to manage TakeHealth stuff.
 */
#pragma semicolon 1
#include <sourcemod>

#include <sdktools>
#include <dhooks>
// #include <stocksoup/log_server>

#pragma newdecls required

Handle g_OnTakeHealthCalculateMultiplier;
Handle g_OnTakeHealthPre;

float g_flHealFraction[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	RegPluginLibrary("takehealth_proxy");
	
	g_OnTakeHealthCalculateMultiplier = CreateGlobalForward("TF2_OnTakeHealthGetMultiplier",
			ET_Event, Param_Cell, Param_FloatByRef);
	g_OnTakeHealthPre = CreateGlobalForward("TF2_OnTakeHealthPre",
			ET_Hook, Param_Cell, Param_FloatByRef, Param_CellByRef);
	
	return APLRes_Success;
}

public void OnPluginStart() {
	Handle hGameConf = LoadGameConfigFile("tf2.takehealth_proxy");
	if (!hGameConf) {
		SetFailState("Failed to load gamedata (tf2.takehealth_proxy).");
	}
	
	Handle dtPlayerTakeHealth = DHookCreateFromConf(hGameConf, "CTFPlayer::TakeHealth()");
	DHookEnableDetour(dtPlayerTakeHealth, false, OnTakeHealthPre);
	
	delete hGameConf;
}

public void OnClientPutInServer(int client) {
	g_flHealFraction[client] = 0.0;
}

public MRESReturn OnTakeHealthPre(int client, Handle hReturn, Handle hParams) {
	float flMultiplier = 1.0;
	
	Action result;
	
	Call_StartForward(g_OnTakeHealthCalculateMultiplier);
	Call_PushCell(client);
	Call_PushFloatRef(flMultiplier);
	Call_Finish(result);
	
	if (result != Plugin_Changed) {
		flMultiplier = 1.0;
	}
	
	
	float flOriginalHealAmount = DHookGetParam(hParams, 1);
	int bitsDamageType = DHookGetParam(hParams, 2);
	
	float flModifiedHealAmount = flOriginalHealAmount * flMultiplier;
	
	Call_StartForward(g_OnTakeHealthPre);
	Call_PushCell(client);
	Call_PushFloatRef(flModifiedHealAmount);
	Call_PushCellRef(bitsDamageType);
	Call_Finish(result);
	
	/**
	 * TODO maybe push another byref "proxyflags" for some additional behaviors that TakeHealth
	 * Proxy can do on its own?
	 * 
	 * One of the relevant ones is to limit the heal amount granted by overheal based on max
	 * buffed health.
	 */
	
	if (result == Plugin_Stop) {
		// LogServer("Blocked healing on %N", client);
		return MRES_Supercede;
	} else if (result == Plugin_Continue && flModifiedHealAmount == flOriginalHealAmount) {
		// LogServer("Unchanged healing on %N: %.2f", client, flOriginalHealAmount);
		return MRES_Ignored;
	}
	
	flModifiedHealAmount += g_flHealFraction[client];
	
	int iHealAmount = RoundToFloor(flModifiedHealAmount);
	g_flHealFraction[client] = flModifiedHealAmount - iHealAmount;
	
	DHookSetParam(hParams, 1, float(iHealAmount));
	DHookSetParam(hParams, 2, bitsDamageType);
	
	// LogServer("Modified healing for %N: %.2f -> %.2f", client,
			// flOriginalHealAmount, flModifiedHealAmount);
	
	return MRES_ChangedHandled;
}
