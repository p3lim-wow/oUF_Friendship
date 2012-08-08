local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Friendship was unable to locate oUF install')

-- This is not a final list, if you find an npc with reputation,
-- please let me (p3lim) know by PM/comment on the download site.
-- Will be generated properly if Wowhead adds filters for it.
local friendships = {
	[GetFactionInfoByID(1278)] = 1278,
	[GetFactionInfoByID(1273)] = 1273,
	[GetFactionInfoByID(1282)] = 1282,
	[GetFactionInfoByID(1276)] = 1276,
	[GetFactionInfoByID(1358)] = 1358,
	[GetFactionInfoByID(1279)] = 1279,
	[GetFactionInfoByID(1281)] = 1281,
	[GetFactionInfoByID(1283)] = 1283,
}

local function GetFriendshipID()
	if(not UnitExists('target')) then return end
	if(UnitIsPlayer('target')) then return end

	return friendships[UnitName('target')]
end

local function OnEnter(self)
	local _, cur, _, details, _, standing, threshold = GetFriendshipReputationByID(GetFriendshipID())
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	GameTooltip:SetText(UnitName('target'), 1, 1, 1)
	GameTooltip:AddLine(details, nil, nil, nil, true)
	GameTooltip:AddLine((cur - threshold) .. ' / 8400 (' .. standing .. ')', 1, 1, 1, true)
	GameTooltip:Show()
end

local function Update(self)
	local friendship = self.Friendship
	
	local id = GetFriendshipID()
	if(id) then
		local _, cur, _, _, _, _, threshold = GetFriendshipReputationByID(id)
		friendship:SetMinMaxValues(0, 8400)
		friendship:SetValue(cur - threshold)
		friendship:Show()
	else
		friendship:Hide()
	end

	if(friendship.PostUpdate) then
		return friendship:PostUpdate(id)
	end
end

local function Path(self, ...)
	return (self.Friendship.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function Enable(self, unit)
	local friendship = self.Friendship
	if(friendship) then
		friendship.__owner = self
		friendship.ForceUpdate = ForceUpdate

		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path)

		if(friendship.Tooltip) then
			friendship:EnableMouse(true)
			friendship:HookScript('OnEnter', OnEnter)
			friendship:HookScript('OnLeave', GameTooltip_Hide)
		end

		if(not friendship:GetStatusBarTexture()) then
			friendship:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		return true
	end
end

local function Disable(self)
	if(self.Friendship) then
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
	end
end

oUF:AddElement('Friendship', Path, Enable, Disable)
