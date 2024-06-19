function export()
    local getName = sdk.find_type_definition("snow.data.DataShortcut"):get_method("getName(snow.data.DataDef.PlEquipSkillId)")

    local saveManager = sdk.get_managed_singleton("snow.SnowSaveService")
    local slot = saveManager._CurrentHunterSlotNo
    if slot == -1 or slot == nil then return end
    
    local data = sdk.get_managed_singleton("snow.data.DataManager")
    local box = data._PlEquipBox
    local list = box:get_field("_WeaponArmorInventoryList")--box:call("getInventoryDataList(snow.data.EquipBox.InventoryType)", 0)
    
    local exportString = ""

    for i = 0, list:call("get_Count") - 1 do
        local v = list:call("get_Item", i)

        if v._IdType == 3 then
            local singleString = ""

            local lvList = v._TalismanSkillLvList
            local skillList = v._TalismanSkillIdList
            singleString = singleString .. getName:call(nil, skillList:call("get_Item", 0)) ..",".. lvList:call("get_Item",0) .. ","
            singleString = singleString .. getName:call(nil, skillList:call("get_Item", 1)) ..",".. lvList:call("get_Item",1) .. ","

            local decoList = v._TalismanDecoSlotNumList
            local lv4 = decoList:call("get_Item", 4)
            local lv3 = decoList:call("get_Item", 3)
            local lv2 = decoList:call("get_Item", 2)
            local lv1 = decoList:call("get_Item", 1)
            
            local decoString = ""
            if lv4 > 0 then
                for i = 0, lv4 - 1 do
                    decoString = decoString .. "4,"
                end
            end
            if lv3 > 0 then
                for i = 0, lv3 - 1 do
                    decoString = decoString .. "3,"
                end
            end
            if lv2 > 0 then
                for i = 0, lv2 - 1 do
                    decoString = decoString .. "2,"
                end
            end
            if lv1 > 0 then
                for i = 0, lv1 - 1 do
                    decoString = decoString .. "1,"
                end
            end

            while string.len(decoString) < string.len("0,0,0") do
                decoString = decoString .. "0,"
            end
            decoString = string.sub(decoString, 0,string.len("0,0,0"))

            singleString = singleString .. decoString
            exportString = exportString .. singleString .. "\n"
        end
    end
    fs.write("TalismanExporter/Save00".. slot .. "_ExportedTalismans.txt", exportString)
end

re.on_draw_ui(
    function()
        if imgui.tree_node("Talisman Exporter") then
            if imgui.button("Export") then
                export()
            end
            imgui.tree_pop();
        end
    end
)