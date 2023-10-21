-- Version 1.0.0
-- Hopefully I didn't mess something up and this is the only version

local function pre_WishList_Message(args)
    return sdk.PreHookResult.SKIP_ORIGINAL
end

local function post_WishList_Message(retval)
end

local wishListManager = nil

local function wishListSkip()
	-- try to get the snow.data.WishListManager singleton
	wishListManager = sdk.find_type_definition("snow.data.WishListManager")	
	
	-- skip the method controlling the "material types" message
	sdk.hook(wishListManager:get_method("checkWishListCategoryCompleteVillage"), pre_WishList_Message, post_WishList_Message)
end

wishListSkip()