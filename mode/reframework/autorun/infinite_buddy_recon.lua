-- infinite_buddy_recon.lua : written by arcwizard1204

local travelCount = 0

local settings = {
	infiniteRecon = true;
	basePoint = 100;
}

local OtomoReconManager = nil

function on_pre_onCompleteReconOtomoAct(args)
	if settings.infiniteRecon then
		return sdk.PreHookResult.SKIP_ORIGINAL
	else
		return sdk.PreHookResult.CALL_ORIGINAL
	end
end

function on_post_onCompleteReconOtomoAct(retval)
	if settings.infiniteRecon then
		sdk.get_managed_singleton("snow.otomo.OtomoManager")._RefOtReconManager:removeReconOtomo()
	end
    return retval
end

function on_pre_showReconOtomo(args)
	if settings.infiniteRecon then
		travelCount = travelCount + 1
	end
	return sdk.PreHookResult.CALL_ORIGINAL
end

function on_pre_initRewardList(args)
	if settings.infiniteRecon then
		local usedPoints = settings.basePoint * travelCount
		if travelCount > 0 then
			OtomoReconManager:set_field("_IsUseOtomoReconFastTravel", true)
		end
		OtomoReconManager:set_field("UseOtomoReconFastTravelVillagePoint", usedPoints)
	end

	return sdk.PreHookResult.CALL_ORIGINAL
end

function on_pre_initQuestStart(args)
	OtomoReconManager = sdk.get_managed_singleton("snow.data.OtomoReconManager")
	if settings.infiniteRecon then
		if travelCount > 0 then
			travelCount = 0
			OtomoReconManager:set_field("_IsUseOtomoReconFastTravel", false)
		end
		OtomoReconManager:set_field("UseOtomoReconFastTravelVillagePoint", settings.basePoint)
	end

	return sdk.PreHookResult.CALL_ORIGINAL
end

local function SaveSettings()
	if not settings.infiniteRecon then
		OtomoReconManager:set_field("UseOtomoReconFastTravelVillagePoint", 100)
	end
	json.dump_file("Infinite_buddy_recon.json", settings)
end


local function LoadSettings()
	local loadedSettings = json.load_file("Infinite_buddy_recon.json");
	if loadedSettings then
		settings = loadedSettings;
	end

	if not settings.infiniteRecon then settings.infiniteRecon = true end
	if not settings.basePoint then settings.basePoint = 100 end
end

re.on_draw_ui(function()

	local changed = false;

    if imgui.tree_node("Infinite buddy recon") then

		changed, settings.basePoint = imgui.slider_int("Village point per use", settings.basePoint, 0, 1000);
		changed, settings.infiniteRecon = imgui.checkbox("Enabled", settings.infiniteRecon);

    end

end)

re.on_config_save(function()
	SaveSettings()
end)

LoadSettings()

sdk.hook(sdk.find_type_definition("snow.otomo.OtomoReconCharaManager"):get_method("onCompleteReconOtomoAct"), 
	on_pre_onCompleteReconOtomoAct,
	on_post_onCompleteReconOtomoAct)
	
sdk.hook(sdk.find_type_definition("snow.otomo.OtomoReconCharaManager"):get_method("showReconOtomo"), 
	on_pre_showReconOtomo,
	function(retval) end)

sdk.hook(sdk.find_type_definition("snow.gui.GuiQuestResultFsmManager"):get_method("initRewardList"), 
	on_pre_initRewardList,
	function(retval) end)
	
sdk.hook(sdk.find_type_definition("snow.SnowSessionManager"):get_method("initQuestStart"), 
	on_pre_initQuestStart,
	function(retval) end)