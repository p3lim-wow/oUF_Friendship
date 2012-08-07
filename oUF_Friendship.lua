local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, 'oUF Friendship was unable to locate oUF install')

local function GetNPCID()
	local GUID = UnitGUID('target') or ''
	return tonumber(string.sub(GUID, -12, -9), 16)
end

local function OnEnter(self)
	local cache = oUF_FriendshipCache[GetNPCID()]
	GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMRIGHT')
	GameTooltip:SetText(cache.name, 1, 1, 1)
	GameTooltip:AddLine(cache.details, nil, nil, nil, true)
	GameTooltip:AddLine(cache.standing .. ' / 42999', 1, 1, 1, true)
	GameTooltip:Show()
end

local function Update(self, event)
	if(not UnitExists('target')) then return end
	local _, standing, details, id -- 'id' is temporary

	local cache = oUF_FriendshipCache[GetNPCID()]
	if(event == 'GOSSIP_SHOW') then
		id, standing, _, details = GetFriendshipReputation()
		if(not id) then return end

		if(cache) then
			cache.standing = standing
			cache.details = details -- Not sure if this ever changes
		else
			oUF_FriendshipCache[GetNPCID()] = {
				standing = standing,
				details = details,
				name = UnitName('npc')

				id = id, -- Temporary tracking
			}
		end
	elseif(cache) then
		standing = cache.standing
	end

	local friendship = self.Friendship
	if(standing ~= nil) then
		friendship:SetMinMaxValues(0, 42999) -- Max value doesn't seem to change
		friendship:SetValue(standing)
		friendship:Show()
	else
		friendship:Hide()
	end

	if(friendship.PostUpdate) then
		return friendship:PostUpdate(standing)
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

		self:RegisterEvent('GOSSIP_SHOW', Path)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path)

		if(friendship.Tooltip) then
			friendship:EnableMouse(true)
			friendship:HookScript('OnEnter', OnEnter)
			friendship:HookScript('OnLeave', GameTooltip_Hide)
		end

		oUF_FriendshipCache = oUF_FriendshipCache or {}

		if(not friendship:GetStatusBarTexture()) then
			friendship:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
		end

		return true
	end
end

local function Disable(self)
	if(self.Friendship) then
		self:UnregisterEvent('GOSSIP_SHOW', Path)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
	end
end

oUF:AddElement('Friendship', Path, Enable, Disable)
