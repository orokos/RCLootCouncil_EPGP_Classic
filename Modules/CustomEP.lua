local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil_Classic")
local RCEPGP = addon:GetModule("RCEPGP")

local RCCustomEP = RCEPGP:GetModule("RCCustomEP")

function RCCustomEP:OnInitialize()
  self.candidateInfos = {} -- The information of everyone in the guild or group
  self.eventInfos = {} -- The inforamation of events within += 12h, including the invite list
  self.eventOpenQueue = {} -- The event that is waiting for process

  self.lastOtherCalendarOpenEvent = 0 -- THe time when other program runs CalendarOpenEvent()
  -- self:RegisterEvent("CALENDAR_OPEN_EVENT", "OPEN_CALENDAR")
  -- self:RegisterBucketEvent({"CALENDAR_UPDATE_EVENT_LIST", "CALENDAR_UPDATE_INVITE_LIST"}, 20, "UPDATE_CALENDAR")
  self:ScheduleRepeatingTimer("GROUP_ROSTER_UPDATE", 15, "GROUP_ROSTER_UPDATE")
  self:RegisterBucketEvent("GUILD_ROSTER_UPDATE", 20, "GUILD_ROSTER_UPDATE")
  -- self:SecureHook(_G.C_Calendar, "OpenEvent", "OnCalendarOpenEvent")
  EPGP.RegisterCallback(self, "StartRecurringAward", "OnStartRecurringAward")
  EPGP.RegisterCallback(self, "StopRecurringAward", "OnStopRecurringAward")
  EPGP.RegisterCallback(self, "ResumeRecurringAward", "OnResumeRecurringAward")
  GuildRoster()
  self:ProcessEventOpenQueue()
  -- self:ScheduleTimer("UPDATE_CALENDAR", 10)
  self:ScheduleTimer("GROUP_ROSTER_UPDATE", 2)
  self:ScheduleTimer("GUILD_ROSTER_UPDATE", 2)
  -- LibSpec:Rescan()
  if not EPGP.db.profile.next_award then
    self:OnStopRecurringAward()
  end
  self.defaultFormula = CopyTable(RCEPGP.defaults.profile.customEP.EPFormulas["**"])
  self.defaultFormula.standby = EPGP.db.profile.extras_p * 0.01
  self.initialize = true
end

function RCCustomEP:GROUP_ROSTER_UPDATE()
  GuildRoster()
  for i = 1, GetNumGroupMembers() or 0 do
    local name, rank, subgroup, level, _, classFileName, zone, online, isDead, groupRole, isML = GetRaidRosterInfo(i)
    if name then
      local unitID
      if IsInRaid() then
        unitID = "raid"..i
      else
        unitID = "party"..i
      end
      local fullName = RCEPGP:GetEPGPName(name)
      local guildName, guildRankName, guildRankIndex = GetGuildInfo(unitID)
      if not self.candidateInfos[fullName] then
        self.candidateInfos[fullName] = {}
      end
      local info = self.candidateInfos[fullName]
      info["guid"] = UnitGUID(unitID)
      info["fullName"] = fullName
      info["raidRank"] = rank
      info["subgroup"] = subgroup
      info["level"] = level
      info["class"] = classFileName
      info["zone"] = zone
      info["online"] = online
      info["isDead"] = isDead
      info["groupRole"] = groupRole
      info["isML"] = isML
      -- info["role"] = UnitGroupRolesAssigned(unitID)
      info["guid"] = UnitGUID(unitID)
      if guildName and guildRankName and guildRankIndex then -- Must check this because this is not available when offline
        info["guildName"] = guildName
        info["guildRank"] = guildRankName
        info["guildRankIndex"] = guildRankIndex
      end
      -- if UnitIsVisible(unitID) then
      --   local guid = info["guid"]
      --   local specInfo = LibSpec:GetCachedInfo(guid)
      --   if not specInfo or not specInfo.spec_role_detailed then
      --     LibSpec:Rescan(guid)
      --   end
      -- end
    else
      RCEPGP:DebugPrint("GROUP_ROSTER_UPDATE uncached, retry after 1s.")
      self:ScheduleTimer("GROUP_ROSTER_UPDATE", 1)
    end
  end
end

function RCCustomEP:GetEventTimeDiff(month, day, year, hour, min)
  local _
  if year < 100 then year = year + 2000 end
  local eventTime = time({year=year, month=month, day=day, hour=hour, min=min, sec=0})
  -- Get current server time
  -- _, month, day, year = CalendarGetDate()
  local month = tonumber(date("%m"))
  local day = tonumber(date("%d"))
  local year = tonumber(date("%Y"))
  hour, min = GetGameTime()
  local now = time({year=year, month=month, day=day, hour=hour, min=min, sec=0})
  return eventTime - now
end

-- tank, healer, melee, ranged
function RCCustomEP:GetDetailedRole(name)
  local name = RCEPGP:GetEPGPName(name)
  local guid = self.candidateInfos[name] and self.candidateInfos[name].guid
  return guid -- and LibSpec:GetCachedInfo(guid) and LibSpec:GetCachedInfo(guid).spec_role_detailed
end
