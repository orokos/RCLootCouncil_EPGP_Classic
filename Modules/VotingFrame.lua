local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil_Classic")
local RCEPGP = addon:GetModule("RCEPGP")
local RCVF = RCEPGP:GetModule("RCEPGPVotingFrame")

function RCVF.PRSort(table, rowa, rowb, sortbycol)
  local column = table.cols[sortbycol]
  local a, b = table:GetRow(rowa), table:GetRow(rowb);
  -- Extract the rank index from the name, fallback to 100 if not found

  local nameA = RCEPGP:GetEPGPName(a.name)
  local nameB = RCEPGP:GetEPGPName(b.name)

  local a_ep, a_gp = EPGP:GetEPGP(nameA)
  local b_ep, b_gp = EPGP:GetEPGP(nameB)

  if (not a_ep) or (not a_gp) then
    return false
  elseif (not b_ep) or (not b_gp) then
    return true
  end

  local a_pr = a_ep / a_gp
  local b_pr = b_ep / b_gp

  local a_qualifies = a_ep >= EPGP.db.profile.min_ep
  local b_qualifies = b_ep >= EPGP.db.profile.min_ep

  if a_qualifies == b_qualifies and a_pr == b_pr then
    if column.sortnext then
      local nextcol = table.cols[column.sortnext];
      if nextcol and not(nextcol.sort) then
        if nextcol.comparesort then
          return nextcol.comparesort(table, rowa, rowb, column.sortnext);
        else
          return table:CompareSort(rowa, rowb, column.sortnext);
        end
      end
    end
    return false
  else
    local direction = column.sort or column.defaultsort or "dsc";
    if tostring(direction):lower() == "asc" then
      if a_qualifies == b_qualifies then
        return a_pr < b_pr
      else
        return b_qualifies
      end
    else
      if a_qualifies == b_qualifies then
        return a_pr > b_pr
      else
        return a_qualifies
      end
    end
  end
end
