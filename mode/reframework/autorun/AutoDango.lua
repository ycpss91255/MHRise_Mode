local allManagersRetrieved = false
local gm = {}
gm.FacilityDataManager = {}
gm.FacilityDataManager.n = "snow.data.FacilityDataManager"
gm.ProgressManager = {}
gm.ProgressManager.n = "snow.progress.ProgressManager"
gm.PlayerManager = {}
gm.PlayerManager.n = "snow.player.PlayerManager"
gm.ChatManager = {}
gm.ChatManager.n = "snow.gui.ChatManager"
gm.ContentsIdDataManager = {}
gm.ContentsIdDataManager.n = "snow.data.ContentsIdDataManager"
gm.QuestManager = {}
gm.QuestManager.n = "snow.QuestManager"

for i,v in pairs(gm) do
    v.d = sdk.get_managed_singleton(v.n)
end


-- == -- == -- == -- == --


local DataShortcut = sdk.create_instance("snow.data.DataShortcut", true):add_ref()

local isOrdering = false

local settings = json.load_file("AutoDangoSettings.json") or {}
settings.Enabled = settings.Enabled == nil and true or settings.Enabled
settings.Sounds = settings.Sounds == nil and true or settings.Sounds
settings.UseVoucher = settings.UseVoucher == nil and false or settings.UseVoucher
settings.UseHoppingSkewers = settings.UseHoppingSkewers == nil and false or settings.UseHoppingSkewers
settings.Points = settings.Points == nil and false or settings.Points
settings.EnableNotification = settings.EnableNotification == nil and true or settings.EnableNotification
settings.CurrentSet = settings.CurrentSet or 1
--settings.CurrentSet = math.floor(settings.CurrentSet)


-- == -- == -- == -- == --


local function CreateOrder(setID)
    local Kitchen = gm.FacilityDataManager.d:call("get_Kitchen")
    if not Kitchen then return end
    Kitchen = Kitchen:call("get_MealFunc")
    if not Kitchen then return end

    return Kitchen:call("getMySetList"):call("get_Item", setID - 1)
end

local function OrderFood(order)
    local Kitchen = gm.FacilityDataManager.d:call("get_Kitchen")
    if not Kitchen then return end
    Kitchen = Kitchen:call("get_MealFunc")
    if not Kitchen then return end

    Kitchen:call("resetDailyDango")
    
    if Kitchen:get_field("_AvailableWaitTimer") > 0.0 then return end

    log.debug(order:call("get__DangoId"):call("get_Item", 0))

    if order:call("get__DangoId"):call("get_Item", 0) == 65 then
        gm.ChatManager.d:call("reqAddChatInfomation", "<COL RED>Cannot order from an empty set</COL>", settings.Sounds and 2412657311 or 0)
        return
    end

    local facilityLevel = Kitchen:call("get_FacilityLv")

    local Vouchers = gm.ContentsIdDataManager.d:call("getItemData", 0x410007c)
    local VoucherCount = Vouchers:call("getCountInBox")

    log.debug(VoucherCount)

    if VoucherCount > 0 then
        Kitchen:set_field("_MealTicketFlag", settings.UseVoucher)
    else
        Kitchen:set_field("_MealTicketFlag", false)
    end

    order:set_field("IsSpecialSkewer", settings.UseHoppingSkewers)


    isOrdering = true
    Kitchen:call("order", order, settings.Points and 1 or 0, facilityLevel)
    isOrdering = false

    local Player = gm.PlayerManager.d:call("findMasterPlayer")
    local PlayerData = Player:get_field("_refPlayerData")
    PlayerData:set_field("_vitalMax", PlayerData:get_field("_vitalMax") + 50)
    PlayerData:set_field("_staminaMax", PlayerData:get_field("_staminaMax") + 1500.0)

    local OrderName = order:call("get_OrderName")

    local Message = "<COL YEL>Automatically ate " .. OrderName .. (settings.UseVoucher and (VoucherCount > 0 and (" with a voucher (" .. VoucherCount .. " remaining)") or ", but you are out of vouchers") or "") .. ".\nSkills activated:</COL>"
    local PlayerSkillData = Player:get_field("_refPlayerSkillList")
    PlayerSkillData = PlayerSkillData:call("get_KitchenSkillData")
    for i,v in pairs(PlayerSkillData:get_elements()) do
        if v:get_field("_SkillId") ~= 0 then
            Message = Message .. "\n" .. DataShortcut:call("getName(snow.data.DataDef.PlKitchenSkillId)", v:get_field("_SkillId")) .. (settings.UseHoppingSkewers and (" <COL YEL>(lv " .. v:get_field("_SkillLv") .. ")</COL>") or "")
        end
    end
    Message = Message .. (settings.UseHoppingSkewers and "\n<COL YEL>(Hopping skewer was used)</COL>" or "")

    if settings.EnableNotification then
        gm.ChatManager.d:call("reqAddChatInfomation", Message, settings.Sounds and 2289944406 or 0)
    end

    Kitchen:set_field("_AvailableWaitTimer", Kitchen:call("get_WaitTime"))
end



-- == -- == -- == -- == --



sdk.hook(
    sdk.find_type_definition("snow.QuestManager"):get_method("questActivate(snow.LobbyManager.QuestIdentifier)"),
    function(args)
        OrderFood(CreateOrder(settings.CurrentSet))
    end
)

sdk.hook(
    sdk.find_type_definition("snow.facility.MealOrderData"):get_method("canOrder"),
    function()end,
    function(ret)
        local bool
        if isOrdering then 
            bool = sdk.create_instance("System.Boolean"):add_ref()
            bool:set_field("mValue", true)
            ret = sdk.to_ptr(bool) 
        end
        log.debug(sdk.to_int64(ret))
    return ret end
)



-- == -- == -- == -- == --



re.on_frame(function()
    if allManagersRetrieved == false then
        local success = true
        for i,v in pairs(gm) do
            v.d = sdk.get_managed_singleton(v.n)
            if v.d == nil then success = false end
        end
        allManagersRetrieved = success
    end
end)



-- == -- == -- == -- == --


re.on_draw_ui(function()
    if imgui.tree_node("AutoDango")then
        if allManagersRetrieved then
            local Kitchen = gm.FacilityDataManager.d:call("get_Kitchen")
            if Kitchen then
                Kitchen = Kitchen:call("get_MealFunc")
                if Kitchen then
                    _, settings.Enabled = imgui.checkbox("Automatically eat", settings.Enabled)
                    imgui.new_line()
                    _, settings.CurrentSet = imgui.slider_int("Current dango set", settings.CurrentSet, 1,32, Kitchen:call("get_MySetDataList"):call("get_Item", settings.CurrentSet - 1):call("get_OrderName"))
                    _, settings.UseHoppingSkewers = imgui.checkbox("Use hopping skewers", settings.UseHoppingSkewers)
                    _, settings.Points = imgui.checkbox("Pay with Kamura Points", settings.Points)
                    _, settings.UseVoucher = imgui.checkbox("Use voucher on eating", settings.UseVoucher)
                    imgui.new_line()
                    _, settings.EnableNotification = imgui.checkbox("Enable eating notification", settings.EnableNotification)
                    _, settings.Sounds = imgui.checkbox("Enable notification sounds", settings.Sounds)
                    imgui.new_line()
                    if Kitchen._AvailableWaitTimer > 0 then
                        imgui.text("You may not manually eat as you have already eaten")
                    else
                        if imgui.button("Manually trigger eating") then
                            OrderFood(CreateOrder(settings.CurrentSet))
                        end
                    end
                else
                    imgui.text("Loading...")
                end
            else
                imgui.text("Loading...")
            end
        else
            imgui.text("Loading...")
        end
        imgui.tree_pop();
    end
end)


-- == -- == -- == -- == --


re.on_config_save(function()
    json.dump_file("AutoDangoSettings.json", settings)
end)