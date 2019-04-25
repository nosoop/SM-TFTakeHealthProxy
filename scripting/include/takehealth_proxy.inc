/**
 * [TF2] TakeHealth Proxy
 * 
 * Provides a few global forwards that are called before CTFPlayer::TakeHealth() to modify the
 * healing given to a player.
 */

#if defined __takehealth_proxy_included
	#endinput
#endif

#define __takehealth_proxy_included

/**
 * Called before TakeHealth to allow adjusting the healing multiplier.
 * This is set to 1.0 by default regardless of the game's healing modifiers.
 */
forward Action TF2_OnTakeHealthGetMultiplier(int client, float &flMultiplier);

/**
 * Called after `TF2_OnTakeHealthGetMultiplier` to modify the actual healing value before
 * healing is applied to a player.
 * 
 * `flags` corresponds to the bitfield the game passes into `TakeHealth`.
 */
forward Action TF2_OnTakeHealthPre(int client, float &flAmount, int &flags);

public SharedPlugin __pl_takehealth_proxy = {
	name = "takehealth_proxy",
	file = "takehealth_proxy.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};
