SXL_AC = {}
SXL_AC.Enable = true
SXL_AC.MainAnticheat = true

SXL_AC.UseESX = true
SXL_AC.ESXTrigger = "esx:getSharedObject" -- If you use ESX, put the trigger right here

SXL_AC.GodModeProtection = true
SXL_AC.AntiSpectate = true
SXL_AC.AntiSpeedHacks = true
SXL_AC.AntiBoomDamage = true
SXL_AC.PlayerProtection = true
SXL_AC.AntiBlacklistedWeapons = true
SXL_AC.AntiVDM = true

SXL_AC.AntiDamageModifier = true
SXL_AC.AntiThermalVision = true
SXL_AC.AntiNightVision = true
SXL_AC.AntiResourceStartorStop = true
SXL_AC.AntiCommandInjection = false -- If you can get in the server while this is "true" perfect. Otherwise just disable it.
SXL_AC.AntiLicenseClears = true

SXL_AC.BlockLUAFiles = true
SXL_AC.BlockedLUAFiles = {
	"ham.lua",
	"fallout.lua",
	"stars.lua",
	"rape.lua",
	"Infinity.lua",
	"fivex.lua"
}

SXL_AC.DisableVehicleWeapons = true
SXL_AC.AntiKeyboardNativeInjections = true
SXL_AC.AntiCheatEngine = true
SXL_AC.AntiNoclip = true
SXL_AC.AntiRadar = true
SXL_AC.AntiRagdoll = true
SXL_AC.AntiInvisible = true
SXL_AC.AntiExplosiveBullets = true
SXL_AC.AntiBlips = true
SXL_AC.AntiInfiniteAmmo = true
SXL_AC.AntiPedChange = true
SXL_AC.AntiVehicleModifiers = true
SXL_AC.AntiSuperJump = true
SXL_AC.AntiFreeCam = true
SXL_AC.AntiFlyandVehicleBelowLimits = true
SXL_AC.DeleteBrokenCars = true
SXL_AC.ClearPedsAfterDetection = true
SXL_AC.ClearObjectsAfterDetection = true
SXL_AC.ClearVehiclesAfterDetection = true
SXL_AC.AntiMenyoo = true
SXL_AC.AntiPedRevive = true
SXL_AC.AntiSuicide = true -- This isn't perfectly working, if normal players get banned because of this, disable it.
SXL_AC.AntiGiveArmour = true

SXL_AC.AntiVehicleSpawn = true
SXL_AC.GarageList = { -- Place all of the garage coordinates right here.
	{x = 217.89, y = -804.99, z = 30.91},
}

SXL_AC.HospitalCoords = vector3(293.11,-582.1,43.19) -- Put here the hospital coords or the coords where the player respawns after dying

SXL_AC.BlacklistedWeapons = {
	"WEAPON_HAMMER",
	"WEAPON_SAWNOFFSHOTGUN",
	"WEAPON_BULLPUPSHOTGUN",
	"WEAPON_GRENADELAUNCHER",
	"WEAPON_GRENADELAUNCHER_SMOKE",
	"WEAPON_RPG",
	"WEAPON_STINGER",
	"WEAPON_MINIGUN",
	"WEAPON_GRENADE",
	"WEAPON_BALL",
	"WEAPON_BOTTLE",
	"WEAPON_HEAVYSHOTGUN",
	"WEAPON_GARBAGEBAG",
	"WEAPON_RAILGUN",
	"WEAPON_RAILPISTOL",
	"WEAPON_RAILGUN",
	"WEAPON_RAYPISTOL", 
	"WEAPON_RAYCARBINE", 
	"WEAPON_RAYMINIGUN",
	"WEAPON_DIGISCANNER",
	"WEAPON_SPECIALCARBINE_MK2",
	"WEAPON_BULLPUPRIFLE_MK2",
	"WEAPON_PUMPSHOTGUN_MK2",
	"WEAPON_MARKSMANRIFLE_MK2",
	"WEAPON_COMPACTLAUNCHER",
	"WEAPON_SNSPISTOL_MK2",
	"WEAPON_REVOLVER_MK2",
	"WEAPON_FIREWORK",
	"WEAPON_HOMINGLAUNCHER", 
	"WEAPON_SMG_MK2"
}
