/////////////////////////////////////////
///	Defines
/////////////////////////////////////////

local ADMIN_PASSWORD = "secretpassword"
local MOD_PASSWORD = "secretpassword"

enum LEVEL {
	MOD = 1,
	ADMIN = 2,
}

local ADMIN_SERIAL = [
	// List of admins serial, for auto login
]

/////////////////////////////////////////
///	ACP
/////////////////////////////////////////

local Player = []

for (local i = 0; i < getMaxSlots(); ++i)
	Player.push({rank = 0})
	
//---------------------------------------

local function checkPermission(pid, level)
{
	if (Player[pid].rank >= level)
		return true

	sendMessageToPlayer(pid, 255, 0, 0, "ACP: You don't have permission to use this command!")
	return false
}

//---------------------------------------

local function cmd_acp(pid, params)
{
	sendMessageToPlayer(pid, 0, 255, 0, "-=========== ACP ===========-")
	sendMessageToPlayer(pid, 0, 255, 0, "/logina password - Login as admin")
	sendMessageToPlayer(pid, 0, 255, 0, "/loginm password - Login as mod")
	sendMessageToPlayer(pid, 0, 255, 0, "/color id r g b - Change player color")
	sendMessageToPlayer(pid, 0, 255, 0, "/name id nickname - Change player nickname")
	sendMessageToPlayer(pid, 0, 255, 0, "/kick id reason - Kick player")
	sendMessageToPlayer(pid, 0, 255, 0, "/ban id minutes reason - Ban player (minutes = 0 = forever)")
	sendMessageToPlayer(pid, 0, 255, 0, "/tp from_id to_id - Teleport player to other player")
	sendMessageToPlayer(pid, 0, 255, 0, "/tpall to_id - Teleport players to other player")
	sendMessageToPlayer(pid, 0, 255, 0, "/giveitem id instance amount - Give item to player")
	sendMessageToPlayer(pid, 0, 255, 0, "/str id value - Set player strength")
	sendMessageToPlayer(pid, 0, 255, 0, "/dex id value - Set player dexterity")
	sendMessageToPlayer(pid, 0, 255, 0, "/heal id - Heal player")
	sendMessageToPlayer(pid, 0, 255, 0, "/time hour minute - Set server time")
}

//---------------------------------------

local function cmd_login_admin(pid, params)
{
	if (params == ADMIN_PASSWORD)
	{
		Player[pid].rank = LEVEL.ADMIN
		sendMessageToPlayer(pid, 255, 255, 0, "ACP: Logged into admin account.")
	}
	else
		sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wrong admin password!")
}

//---------------------------------------

local function cmd_login_mod(pid, params)
{
	if (params == MOD_PASSWORD)
	{
		Player[pid].rank = LEVEL.MOD
		sendMessageToPlayer(pid, 255, 255, 0, "ACP: Logged into mod account.")
	}
	else
		sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wrong mod password!")
}

//---------------------------------------

local function cmd_color(pid, params)
{
	if (!checkPermission(pid, LEVEL.MOD)) return
	
	local args = sscanf("dddd", params)
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /color id r g b")
		return
	}
	
	local id = args[0]
	local r = args[1]
	local g = args[2]
	local b = args[3]

	if (!isPlayerConnected(id))
	{
		sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot change color of unconnected player!")
		return
	}
	
	setPlayerColor(id, r, g, b)
	
	sendMessageToPlayer(pid, r, g, b, format("ACP: You changed color of %s to %d, %d, %d", getPlayerName(id), r, g, b))
	sendMessageToPlayer(id, r, g, b, format("Your color was changed to %d, %d, %d by %s", r, g, b, getPlayerName(pid)))
}

//---------------------------------------

local function cmd_name(pid, params)
{
	if (!checkPermission(pid, LEVEL.MOD)) return
	
	local args = sscanf("ds", params)
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /name id nickname")
		return
	}
	
	local id = args[0]
	local name = args[1]

	if (!isPlayerConnected(id))
	{
		sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot change nickname of unconnected player!")
		return
	}
	
	setPlayerName(id, name)
	
	sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You changed nickname of %s to %s", getPlayerName(id), name))
	sendMessageToPlayer(id, 0, 255, 0, format("Your nickname was changed to %s by %s", name, getPlayerName(pid)))
}

//---------------------------------------

local function cmd_kick(pid, params)
{
	if (checkPermission(pid, LEVEL.MOD))
	{
		local args = sscanf("ds", params)
		if (!args)
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /kick id reason")
			return
		}

		local id = args[0]
		local reason = args[1]

		if (!isPlayerConnected(id))
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot kick unconnected player!")
			return
		}

		kick(id, reason)
		
		sendMessageToAll(255, 80, 0, format("ACP: %s has been kicked by %s", getPlayerName(id), getPlayerName(pid)))
		sendMessageToAll(255, 80, 0, format("Reason: %s", reason))
	}
}

//---------------------------------------

local function cmd_ban(pid, params)
{
	if (checkPermission(pid, LEVEL.ADMIN))
	{
		local args = sscanf("dds", params)
		if (!args)
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /ban id minutes reason")
			return
		}

		local id = args[0]
		local minutes = args[1]
		local reason = args[2]

		if (!isPlayerConnected(id))
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot ban unconnected player!")
			return
		}

		ban(id, minutes, reason)
		
		if (minutes > 0) sendMessageToAll(255, 0, 0, format("ACP: %s has been banned for %d minutes by %s", getPlayerName(id), minutes, getPlayerName(pid)))
		else sendMessageToAll(255, 0, 0, format("ACP: %s has been banned FOREVER by %s", getPlayerName(id), minutes, getPlayerName(pid)))
		sendMessageToAll(255, 0, 0, format("Reason: %s", reason))
	}
}

//---------------------------------------

local function cmd_tp(pid, params)
{
	if (checkPermission(pid, LEVEL.MOD))
	{
		local args = sscanf("dd", params)
		if (!args)
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /tp from_id to_id")
			return
		}

		local from_id = args[0]
		local to_id = args[1]

		if (!isPlayerSpawned(from_id) || !isPlayerSpawned(to_id))
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot teleport unconnected or unspawned players!")
			return
		}

		if (from_id == to_id)
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot teleport the same player!")
			return
		}
		
		local world = getPlayerWorld(to_id)
		if (world != getPlayerWorld(from_id)) 
			setPlayerWorld(from_id, world)

		local pos = getPlayerPosition(to_id)
		setPlayerPosition(from_id, pos.x, pos.y, pos.z)

		sendMessageToPlayer(pid, 0, 255, 0, format("ACP: Teleported %s to %s", getPlayerName(from_id), getPlayerName(to_id)))
		sendMessageToPlayer(from_id, 0, 255, 0, format("You were teleported to %s by %s", getPlayerName(to_id), getPlayerName(pid)))
		sendMessageToPlayer(to_id, 0, 255, 0, format("To you has been teleported %s by %s", getPlayerName(from_id), getPlayerName(pid)))
	}
}

//---------------------------------------

local function cmd_tpall(pid, params)
{
	if (checkPermission(pid, LEVEL.ADMIN))
	{
		local args = sscanf("d", params)
		if (!args)
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /tpall to_id")
			return
		}

		local to_id = args[0]
		if (!isPlayerSpawned(to_id))
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot teleport to unconnected or unspawned player!")
			return
		}

		local world = getPlayerWorld(to_id)
		local pos = getPlayerPosition(to_id)
		local message = format("You were teleported to %s by %s", getPlayerName(to_id), getPlayerName(pid))
		
		for (local i = 0; i < getMaxSlots(); ++i)
		{
			if (isPlayerConnected(i) && isPlayerSpawned(i))
			{
				if (world != getPlayerWorld(i))
					setPlayerWorld(i, world)
					
				sendMessageToPlayer(i, 0, 255, 0, message)
				setPlayerPosition(i, pos.x, pos.y, pos.z)
			}
		}
		
		sendMessageToPlayer(pid, 0, 255, 0, format("ACP: Teleported players %s", getPlayerName(to_id)))
	}
}

//---------------------------------------

local function cmd_giveitem(pid, params)
{
	if (checkPermission(pid, LEVEL.ADMIN))
	{
		local args = sscanf("dsd", params)
		if (!args)
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /giveitem id instance amount")
			return
		}

		local id = args[0]
		local instance = Items.id(args[1])
		local amount = args[2]

		if (!isPlayerSpawned(id))
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot give item to unconnected or unspawned player!")
			return
		}

		if (amount < 1) amount = 1
		giveItem(id, instance, amount)

		sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You gave item %s amount: %d to %s", args[1], amount, getPlayerName(id)))
		sendMessageToPlayer(id, 0, 255, 0, format("Received item %s amount: %d from %s", args[1], amount, getPlayerName(pid)))
	}
}

//---------------------------------------

local function cmd_str(pid, params)
{
	if (checkPermission(pid, LEVEL.ADMIN))
	{
		local args = sscanf("dd", params)
		if (!args)
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /str id value")
			return
		}

		local id = args[0]
		local value = args[1]

		if (!isPlayerSpawned(id))
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot give strength to unconnected or unspawned player!")
			return
		}

		if (value < 0) value = 0
		setPlayerStrength(id, value)

		sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You changed %s strength to %d", getPlayerName(id), value))
		sendMessageToPlayer(id, 0, 255, 0, format("Strength was changed to %d by %s", value, getPlayerName(pid)))
	}
}

//---------------------------------------

local function cmd_dex(pid, params)
{
	if (checkPermission(pid, LEVEL.ADMIN))
	{
		local args = sscanf("dd", params)
		if (!args)
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /dex id value")
			return
		}

		local id = args[0]
		local value = args[1]

		if (!isPlayerSpawned(id))
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot give dexterity to unconnected or unspawned player!")
			return
		}

		if (value < 0) value = 0
		setPlayerDexterity(id, value)

		sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You changed %s dexterity to %d", getPlayerName(id), value))
		sendMessageToPlayer(id, 0, 255, 0, format("Dexterity was changed to %d by %s", value, getPlayerName(pid)))
	}
}

//---------------------------------------

local function cmd_heal(pid, params)
{
	if (checkPermission(pid, LEVEL.MOD))
	{
		local args = sscanf("d", params)
		if (!args)
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /heal id")
			return
		}

		local id = args[0]
		if (!isPlayerSpawned(id))
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot heal unconnected or unspawned player!")
			return
		}

		setPlayerHealth(id, getPlayerMaxHealth(id))

		sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You healed %s", getPlayerName(id)))
		sendMessageToPlayer(id, 0, 255, 0, format("You were healed by %s", getPlayerName(pid)))
	}
}

//---------------------------------------

local function cmd_time(pid, params)
{
	if (checkPermission(pid, LEVEL.MOD))
	{
		local args = sscanf("dd", params)
		if (!args)
		{
			sendMessageToPlayer(pid, 255, 0, 0, "ACP: Type /time hour min")
			return
		}

		local hour = args[0]
		local min = args[1]
		
		if (hour > 23) hour = 23
		else if (hour < 0) hour = 0
		
		if (min > 59) min = 59
		else if (min < 0) min = 0

		setTime(hour, min)
		sendMessageToAll(0, 255, 0, format("ACP: %s changed time to %02d:%02d", getPlayerName(pid), hour, min))
	}
}
		
/////////////////////////////////////////
///	Events
/////////////////////////////////////////

local function playerJoin(pid)
{
	local playerSerial = getPlayerSerial(pid)

	foreach (serial in ADMIN_SERIAL)
	{
		if (serial == playerSerial)
		{
			Player[pid].rank = LEVEL.ADMIN
			return
		}
	}
}

addEventHandler("onPlayerJoin", playerJoin)

//---------------------------------------

local function playerDisconnect(pid, reason)
{
	Player[pid].rank = 0
}

addEventHandler("onPlayerDisconnect", playerDisconnect)

//---------------------------------------

local function cmdHandler(pid, cmd, params)
{
	switch (cmd)
	{
	case "acp":
		cmd_acp(pid, params)
		break

	case "logina":
		cmd_login_admin(pid, params)
		break

	case "loginm":
		cmd_login_mod(pid, params)
		break
		
	case "color":
		cmd_color(pid, params)
		break
		
	case "name":
		cmd_name(pid, params)
		break
		
	case "kick":
		cmd_kick(pid, params)
		break
		
	case "ban":
		cmd_ban(pid, params)
		break

	case "tp":
		cmd_tp(pid, params)
		break
		
	case "tpall":
		cmd_tpall(pid, params)
		break

	case "giveitem":
		cmd_giveitem(pid, params)
		break

	case "str":
		cmd_str(pid, params)
		break

	case "dex":
		cmd_dex(pid, params)
		break
		
	case "heal":
		cmd_heal(pid, params)
		break
		
	case "time":
		cmd_time(pid, params)
		break
	}
}

addEventHandler("onPlayerCommand", cmdHandler)