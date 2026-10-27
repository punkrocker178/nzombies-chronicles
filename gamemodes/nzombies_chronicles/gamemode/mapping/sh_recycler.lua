--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2017 Zet0rz
Copyright (C) 2016-2017 lolleko
Copyright (C) 2020-2025 Ethorbit

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
--]]

nzRecycler = nzRecycler or {}

function nzRecycler.Is(ent)
	return IsValid(ent) and ent:GetClass() == "prop_physics" and ent:GetNWBool("NZRecycler")
end

function nzRecycler.BaseClass(wep)
	if !IsValid(wep) then return end

	local class = wep:GetClass()
	local unreplaced = nzWeps:Unreplaced(class)
	if istable(unreplaced) and isstring(unreplaced.ClassName) then
		return unreplaced.ClassName
	end

	return class
end

function nzRecycler.LowestWallPrice(class)
	local lowest

	for _, wall in ipairs(ents.FindByClass("wall_buys")) do
		if (wall.WeaponGive or wall:GetWepClass()) == class then
			local price = tonumber(wall.Price or wall:GetPrice())
			if price and (!lowest or price < lowest) then
				lowest = price
			end
		end
	end

	return lowest
end

if SERVER then
	function nzRecycler.TryUse(ply, ent)
		if !ply:KeyPressed(IN_USE) then return false end

		if isnumber(ply.nextUseTime) and CurTime() < ply.nextUseTime then return false end
		ply.nextUseTime = CurTime() + 1

		if !ply:GetNotDowned() then return false end

		local wep = ply:GetActiveWeapon()
		if !IsValid(wep) then return false end

		if wep:IsSpecial() then return false end

		local baseClass = nzRecycler.BaseClass(wep)
		local price = nzRecycler.LowestWallPrice(baseClass)
		local refund = price and math.floor(price / 2)

		if !refund or refund < 1 then
			ply:ChatPrint("This weapon cannot be recycled.")
			return false
		end

		wep:Remove()
		ply:GivePoints(refund, true)
		return false
	end
end
