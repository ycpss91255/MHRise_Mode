local modName = "Seconds, Please! Eat more dango"
local folderName = "Seconds, Please"
local version = "Version: 2.0.2"

local modUtils = require(folderName .. "/mod_utils")

modUtils.info(modName .. " " .. version .. " loaded!")

local settings = modUtils.getConfigHandler({
    enabled = true,
    disableInQuest = true
}, folderName)

local function getMealFunc()
    local kitchen =
        sdk.get_managed_singleton("snow.data.FacilityDataManager"):call(
            "get_Kitchen")
    if not kitchen then return nil end
    local mealFunc = kitchen:call("get_MealFunc")
    if not mealFunc then return nil end
    return mealFunc
end

local function clearEatTimer(mealFunc)
    if not mealFunc then return end

    mealFunc:set_field("_AvailableWaitTimer", 0)
end

sdk.hook(sdk.find_type_definition("snow.facility.kitchen.MealFunc"):get_method(
             "order"), function() end, function(retval)
    local mealFunc = getMealFunc()
    if mealFunc:call("isInQuest") and not settings.data.disableInQuest then
        clearEatTimer(mealFunc)
    end
    return retval
end)

local hadEaten = false;
sdk.hook(
    sdk.find_type_definition("snow.gui.fsm.kitchen.GuiKitchenFsmManager"):get_method(
        "awake"), function() end, function(retval)
        if not settings.data.enabled then return retval end

        local mealFunc = getMealFunc()
        hadEaten = mealFunc:get_field("_AvailableWaitTimer") > 0
        clearEatTimer(mealFunc)
        return retval
    end)

sdk.hook(
    sdk.find_type_definition("snow.gui.fsm.kitchen.GuiKitchen"):get_method(
        "onDestroy"), function() end, function(retval)
        if not settings.data.enabled then return retval end

        if hadEaten then
            local mealFunc = getMealFunc()
            mealFunc:set_field("_AvailableWaitTimer",
                               mealFunc:call("get_WaitTime"))
        end
        hadEaten = false;
        return retval
    end)

sdk.hook(sdk.find_type_definition("snow.stage.StageManager"):get_method(
             "onQuestStart"), function() end, function(retval)
    if not settings.data.enabled then return retval end

    local mealFunc = getMealFunc()
    clearEatTimer(mealFunc)
end)

re.on_draw_ui(function()
    if imgui.tree_node(modName) then
        local changedEnabled, userEnabled =
            imgui.checkbox("Enabled", settings.data.enabled)
        settings.handleChange(changedEnabled, userEnabled, "enabled")

        local changedDisableInQuest, userDisableInQuest = imgui.checkbox(
                                                              "Disable in quests (use default timer)",
                                                              settings.data
                                                                  .disableInQuest)
        settings.handleChange(changedDisableInQuest, userDisableInQuest,
                              "disableInQuest")

        if changedEnabled or changedDisableInQuest then
            local mealFunc = getMealFunc()
            if mealFunc then
                if changedEnabled and userEnabled then
                    clearEatTimer(mealFunc)
                elseif userEnabled and not userDisableInQuest then
                    clearEatTimer(mealFunc)
                end
            end
        end

        if not settings.isSavingAvailable then
            imgui.text(
                "WARNING: JSON utils not available (your REFramework version may be outdated). Configuration will not be saved between restarts.")
        end

        imgui.text(version)
        imgui.tree_pop()
    end
end)
