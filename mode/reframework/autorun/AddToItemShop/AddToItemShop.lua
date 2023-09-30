--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
local __TS__Symbol, Symbol
do
    local symbolMetatable = {__tostring = function(self)
        return ("Symbol(" .. (self.description or "")) .. ")"
    end}
    function __TS__Symbol(description)
        return setmetatable({description = description}, symbolMetatable)
    end
    Symbol = {
        iterator = __TS__Symbol("Symbol.iterator"),
        hasInstance = __TS__Symbol("Symbol.hasInstance"),
        species = __TS__Symbol("Symbol.species"),
        toStringTag = __TS__Symbol("Symbol.toStringTag")
    }
end

local __TS__Generator
do
    local function generatorIterator(self)
        return self
    end
    local function generatorNext(self, ...)
        local co = self.____coroutine
        if coroutine.status(co) == "dead" then
            return {done = true}
        end
        local status, value = coroutine.resume(co, ...)
        if not status then
            error(value, 0)
        end
        return {
            value = value,
            done = coroutine.status(co) == "dead"
        }
    end
    function __TS__Generator(fn)
        return function(...)
            local args = {...}
            local argsLength = select("#", ...)
            return {
                ____coroutine = coroutine.create(function()
                    local ____fn_1 = fn
                    local ____unpack_0 = unpack
                    if ____unpack_0 == nil then
                        ____unpack_0 = table.unpack
                    end
                    return ____fn_1(____unpack_0(args, 1, argsLength))
                end),
                [Symbol.iterator] = generatorIterator,
                next = generatorNext
            }
        end
    end
end

local __TS__Iterator
do
    local function iteratorGeneratorStep(self)
        local co = self.____coroutine
        local status, value = coroutine.resume(co)
        if not status then
            error(value, 0)
        end
        if coroutine.status(co) == "dead" then
            return
        end
        return true, value
    end
    local function iteratorIteratorStep(self)
        local result = self:next()
        if result.done then
            return
        end
        return true, result.value
    end
    local function iteratorStringStep(self, index)
        index = index + 1
        if index > #self then
            return
        end
        return index, string.sub(self, index, index)
    end
    function __TS__Iterator(iterable)
        if type(iterable) == "string" then
            return iteratorStringStep, iterable, 0
        elseif iterable.____coroutine ~= nil then
            return iteratorGeneratorStep, iterable
        elseif iterable[Symbol.iterator] then
            local iterator = iterable[Symbol.iterator](iterable)
            return iteratorIteratorStep, iterator
        else
            return ipairs(iterable)
        end
    end
end

local function __TS__ArrayMap(self, callbackfn, thisArg)
    local result = {}
    for i = 1, #self do
        result[i] = callbackfn(thisArg, self[i], i - 1, self)
    end
    return result
end

local function __TS__StringAccess(self, index)
    if index >= 0 and index < #self then
        return string.sub(self, index + 1, index + 1)
    end
end

local __TS__Unpack = table.unpack or unpack

local function __TS__Spread(iterable)
    local arr = {}
    if type(iterable) == "string" then
        for i = 0, #iterable - 1 do
            arr[i + 1] = __TS__StringAccess(iterable, i)
        end
    else
        local len = 0
        for ____, item in __TS__Iterator(iterable) do
            len = len + 1
            arr[len] = item
        end
    end
    return __TS__Unpack(arr)
end

local function __TS__SparseArrayNew(...)
    local sparseArray = {...}
    sparseArray.sparseLength = select("#", ...)
    return sparseArray
end

local function __TS__SparseArrayPush(sparseArray, ...)
    local args = {...}
    local argsLen = select("#", ...)
    local listLen = sparseArray.sparseLength
    for i = 1, argsLen do
        sparseArray[listLen + i] = args[i]
    end
    sparseArray.sparseLength = listLen + argsLen
end

local function __TS__SparseArraySpread(sparseArray)
    local ____unpack_0 = unpack
    if ____unpack_0 == nil then
        ____unpack_0 = table.unpack
    end
    local _unpack = ____unpack_0
    return _unpack(sparseArray, 1, sparseArray.sparseLength)
end

-- End of Lua Library inline imports
local ____exports = {}
local ____IL2CPP = require("AddToItemShop.IL2CPP.IL2CPP")
local snow = ____IL2CPP.snow
local ITEM_LIST = require("AddToItemShop.ItemList")
local il_iter = __TS__Generator(function(self, obj)
    do
        local i = 0
        while i < obj:get_Count() do
            coroutine.yield(obj:get_Item(i))
            i = i + 1
        end
    end
end)
local function create_array(self, ____type, ____table)
    local array = sdk.create_managed_array(
        ____type:get_full_name(),
        #____table
    )
    do
        local i = 0
        while i < #____table do
            array:Set(i, ____table[i + 1])
            i = i + 1
        end
    end
    return array
end
local function argosy_item_list(self)
    local list = snow.facility.TradeCenterFacility.Instance:get_TradeFunc()._TradeUserData._Param
    local ret = {}
    for ____, data in __TS__Iterator(il_iter(nil, list)) do
        ret[#ret + 1] = data._ItemId
    end
    return ret
end
local function create_item(self, itemId, index)
    local item_data = snow.data.ItemShopDisplayUserData.Param:T():create_instance()
    item_data._Id = itemId
    item_data._SortId = index
    item_data._FlagIndex = index
    item_data._IsBargainObject = true
    item_data._IsUnlockAfterAlchemy = false
    item_data._HallProgress = 1
    item_data._VillageProgress = 1
    item_data._MRProgress = 0
    return item_data
end
local function addItems(self, ____self)
    local count = ____self._DisplayData._Param:get_Count()
    local data = {}
    for ____, id in ipairs(argosy_item_list(nil)) do
        data[#data + 1] = create_item(nil, id, count)
        count = count + 1
    end
    for ____, id in ipairs(__TS__ArrayMap(
        ITEM_LIST,
        function(____, n) return tonumber(n, 16) end
    )) do
        data[#data + 1] = create_item(nil, id, count)
        count = count + 1
    end
    local ____self__DisplayData_3 = ____self._DisplayData
    local ____create_array_2 = create_array
    local ____temp_1 = snow.data.ItemShopDisplayUserData.Param:T()
    local ____array_0 = __TS__SparseArrayNew(__TS__Spread(il_iter(nil, ____self._DisplayData._Param)))
    __TS__SparseArrayPush(
        ____array_0,
        table.unpack(data)
    )
    ____self__DisplayData_3._Param = ____create_array_2(
        nil,
        ____temp_1,
        {__TS__SparseArraySpread(____array_0)}
    )
end
do
    local ____self
    sdk.hook(
        snow.data.ItemShopFacility.initialize,
        function(args)
            ____self = sdk.to_managed_object(args[2])
            addItems(nil, ____self)
        end
    )
end
return ____exports
