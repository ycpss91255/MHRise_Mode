-- Ver 1.0

-- Constants

local SNOW_GAME_MANAGER = "snow.SnowGameManager"
local VILLAGE_AREA_MANAGER = "snow.VillageAreaManager"
local RECAST_TIMER = "_RecastTimer"
local VILLAGE_STATUS = 1
local TRAINING_AREA = 5

local CONFIG_PATH = "infinite_village_wirebugs.json"

local MOD_OPTIONS_API_PACKAGE_NAME = "ModOptionsMenu.ModMenuApi"
local NAME = "Infinite Village Wirebugs"
local DESCRIPTION = "Freely roam out of bounds in villages."
local VERSION = "1.1"

-- Settings

local settings = {
	enabled = true,
	training_disabled = true
}


if json ~= nil then
	local file = json.load_file(CONFIG_PATH)
	if file ~= nil then
		settings = file
	else
		json.dump_file(CONFIG_PATH, settings)
	end
end

-- Functions

-- Can use this to check if the api is available and do an alternative to avoid complaints from users
function IsModuleAvailable(name)
	if package.loaded[name] then
	  return true
	else
	  for _, searcher in ipairs(package.searchers or package.loaders) do
		local loader = searcher(name)
		if type(loader) == 'function' then
		  package.preload[name] = loader
		  return true
		end
	  end
	  return false
	end
  end

-- Loading the settings UI
local modUI = nil;

if IsModuleAvailable(MOD_OPTIONS_API_PACKAGE_NAME) then
	modUI = require(MOD_OPTIONS_API_PACKAGE_NAME)
end

-- Loads the UI in REFramework
local function ui_settings()
	local changedA, changedB
	if imgui.tree_node(NAME) then
		changedA, settings.enabled = imgui.checkbox("Enabled", settings.enabled)
		changedB, settings.training_disabled = imgui.checkbox("Disabled in training area", settings.training_disabled)
		imgui.tree_pop()
	end

	if changedA or changedB then
		json.dump_file(CONFIG_PATH, settings)
	end
end

-- Loads the UI in Mod Menu
local function mod_ui_settings()
	local changedA, changedB

	modUI.Label("Version: <COL RED>" .. VERSION .. "</COL>", "", "Have fun!")
	
	modUI.Header("Toggles")
	
	changedA, settings.enabled = modUI.CheckBox("Enabled", settings.enabled, "Toggles the mod on and off.")
	changedB, settings.training_disabled = modUI.CheckBox("Disabled in training area", settings.training_disabled, "Whether the wirebug cooldowns should be active in the training area.")

	if changedA or changedB then
		json.dump_file(CONFIG_PATH, settings)
	end
end

if modUI then
	modUI.OnMenu(NAME, DESCRIPTION, mod_ui_settings)
else
	re.on_draw_ui(ui_settings)
end


-- The stuff below is what actually makes the mod work

local function is_in_village()
	local snow_game_manager = sdk.get_managed_singleton(SNOW_GAME_MANAGER)
	local snow_game_manager_type_def = sdk.find_type_definition(SNOW_GAME_MANAGER)
	local get_status_method = snow_game_manager_type_def:get_method("getStatus")
	return snow_game_manager and get_status_method:call(snow_game_manager) == VILLAGE_STATUS or false
end

local function is_in_training()
	local village_area_manager = sdk.get_managed_singleton(VILLAGE_AREA_MANAGER)
	local village_area_manager_type_def = sdk.find_type_definition(VILLAGE_AREA_MANAGER)
	local get_current_area_no_method = village_area_manager_type_def:get_method("getCurrentAreaNo")
	return village_area_manager and get_current_area_no_method:call(village_area_manager) == TRAINING_AREA or false
end

local function on_pre_wirebug(args)
end

local function on_post_wirebug(retval)
	if settings.enabled and is_in_village() and (not settings.training_disabled or not is_in_training()) then
		local player = sdk.get_managed_singleton("snow.player.PlayerManager"):call("findMasterPlayer")
		local wirebug_slots = player:get_field("_HunterWireGauge")

		wirebug_slots[0]:set_field(RECAST_TIMER, 0)
		wirebug_slots[1]:set_field(RECAST_TIMER, 0)
		wirebug_slots[2]:set_field(RECAST_TIMER, 0)
	end
	return retval
end

sdk.hook(sdk.find_type_definition("snow.player.fsm.PlayerFsm2ActionHunterWire"):get_method("start"), on_pre_wirebug,
	on_post_wirebug)
