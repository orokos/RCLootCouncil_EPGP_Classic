--@debug@
if LibDebug then LibDebug() end
--@end-debug@
local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")
local RCEPGP = addon:GetModule("RCEPGP")
local LibDialog = LibStub("LibDialog-1.0")
local RCLootCouncilML = addon:GetModule("RCLootCouncilML")

-- Dialog input is the same as RCLOOTCOUNCIL_CONFIRM_AWARD, plus "gp" and "resonseGP".
LibDialog:Register("RCEPGP_CONFIRM_AWARD", {
	text = "something_went_wrong",
	icon = "",
	on_show = function(self, data)
		RCLootCouncilML.AwardPopupOnShow(self, data)
		if data.gp then
			local text = self.text:GetText().." "..RCEPGP:GetGPAndResponseGPText(data.gp, data.responseGP)
			self.text:SetText(text)
		end
	end,
	buttons = {
		{ text = _G.YES,
			on_click = function(self, data)
				RCLootCouncilML.AwardPopupOnClickYes(self, data, function(awarded)
					if awarded then
						local gp = data and data.gp or 0
						local winner = RCEPGP:GetEPGPName(data.winner)
						local lastgpAwardee = RCEPGP:GetEPGPName(RCLootCouncilML.lootTable[data.session].gpAwardee)
						local lastgpAwarded = RCLootCouncilML.lootTable[data.session].gpAwarded
						if lastgpAwardee then
							RCEPGP:IncGPSecure(lastgpAwardee, data.link, -lastgpAwarded)
						end
						RCEPGP:SetCurrentAwardingGP(gp) -- For announcement
						-- Remove the origin limitation to gp. 0 gp is allowed.
						RCEPGP:IncGPSecure(winner, data.link, gp) -- Fix GP not awarded for Russian name.
						RCEPGP:Debug("Awarded GP: ", winner, data.link, gp)
						RCLootCouncilML.lootTable[data.session].gpAwarded = gp
						RCLootCouncilML.lootTable[data.session].gpAwardee = winner
						RCEPGP:ScheduleTimer("SetCurrentAwardingGP", 0, 0) -- Reset after 1frame
					end
				end) -- GP Award is handled in RCEPGP:OnMessageReceived()
			end,
		},
		{ text = _G.NO,
			on_click = function(self, data)
				RCLootCouncilML.AwardPopupOnClickNo(self, data)
			end,
		},
	},
	hide_on_escape = true,
	show_while_dead = true,
})
