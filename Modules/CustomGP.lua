local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil_Classic")
local RCEPGP = addon:GetModule("RCEPGP")
local RCCustomGP = RCEPGP:GetModule("RCCustomGP")

-- store the item status text in the saved variable\
-- @param return if success. Should call this function again if failed.
function RCCustomGP:LocalizeItemStatusText()
	if not addon.db.global.localizedItemStatus then
		addon.db.global.localizedItemStatus = {}
	end
	if addon.db.global.localizedItemStatus.created ~= GetLocale() then
		addon.db.global.localizedItemStatus = {}
	end

	local success = true
	-- for key, item in pairs(statusTextItems) do
	-- 	if not addon.db.global.localizedItemStatus[key] or not addon.db.global.localizedItemStatus.created then
	-- 		GetItemInfo(item)
	-- 		addon.db.global.localizedItemStatus[key] = GetTextLeft2(item)
	-- 		if not addon.db.global.localizedItemStatus[key] or addon.db.global.localizedItemStatus[key] == "" then
	-- 			success = false
	-- 			addon.db.global.localizedItemStatus[key] = nil
	-- 		end
	-- 	end
	-- end

	if success then
		addon.db.global.localizedItemStatus.created = GetLocale()
	end
	return success
end
