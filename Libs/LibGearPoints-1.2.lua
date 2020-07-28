local MAJOR_VERSION = "LibGearPoints-1.2"
local MINOR_VERSION = 10200

local lib, oldMinor = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local l13 = LibStub("LibGearPoints-1.3")

function lib:GetNumRecentItems()
  return l13:GetNumRecentItems()
end

function lib:GetRecentItemLink(i)
  return l13:GetRecentItemLink(i)
end

--- Return the currently set quality threshold.
function lib:GetQualityThreshold()
  return l13:GetQualityThreshold()
end

--- Set the minimum quality threshold.
-- @param itemQuality Lowest allowed item quality.
function lib:SetQualityThreshold(itemQuality)
  return l13:SetQualityThreshold(itemQuality)
end

function lib:GetValue(item)
  if not item then return end

  local _, itemLink, rarity, ilvl, _, _, itemSubClass, _, equipLoc = GetItemInfo(item)
  if not itemLink then return end

  local gp1, c1, gp2, c2, gp3, c3 = l13:GetValue(item)
  if not gp1 then return end

  return gp1 * 100, gp2 and gp2 * 100, ilvl, rarity, equipLoc
end
