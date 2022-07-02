item_red_key = class({})


function item_red_key:OnAbilityPhaseStart(  )
	if not IsServer() then return end
    local target = self:GetCursorTarget()
    if target:GetUnitName() == "npc_dota_soul_red" then
        return true
    end
    local player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerID())
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="Не подходящая цель"})
    end
    
end

function item_red_key:OnSpellStart()
	ability = self
	EmitGlobalSound("keyisered")
	target = self:GetCursorTarget()
	local random_place = RandomInt(1, 4)

	local buildings = FindUnitsInRadius(
		DOTA_TEAM_CUSTOM_8,	-- int, your team number
		Vector(0,0,0),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_BOTH,	-- int, team filter
		DOTA_UNIT_TARGET_ALL,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	local fountain = nil
	for _,building in pairs(buildings) do
		if building:GetUnitName()=="npc_dota_demolist_spawner_"..random_place  then
			fountain = building
			local demolist = CreateUnitByName("npc_dota_demolist_1", building:GetAbsOrigin(), true,nil,nil,10)
			
			local ab = demolist:AddAbility("ability_demolist")
			Timers:CreateTimer(0.3, function()
				demolist:CastAbilityOnPosition(target:GetAbsOrigin(), ab, self:GetCaster():GetPlayerID())
				ability:SpendCharge()
			end)

			break
		end
	end
	-- if no fountain, just don't do anything
	if not fountain then return end
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modfifer_key", {duration = 1.0})

		ParticleManager:CreateParticle("particles/econ/items/wraith_king/wraith_king_arcana/wk_arc_reincarn_bone_explosion_lv.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
end
LinkLuaModifier("modifier_red_key", "components/items/item_keys", LUA_MODIFIER_MOTION_NONE)
modifier_red_key = class({})
function modifier_red_key:IsHidden() return false end
function modifier_red_key:IsPurgable() return false end
function modifier_red_key:GetTexture() return end
function modifier_red_key:GetEffectName() return end

function modifier_red_key:OnCreated()

end

function modifier_red_key:OnRefresh()

end

function modifier_red_key:DeclareFunctions()
 local funcs = {

 }
return funcs
end

LinkLuaModifier("modfifer_key", "components/items/item_keys", LUA_MODIFIER_MOTION_NONE)	

modfifer_key = class({})
function modfifer_key:IsHidden() return false end
function modfifer_key:IsPurgable() return false end
function modfifer_key:GetTexture() return end
function modfifer_key:GetEffectName() return end

function modfifer_key:OnCreated()

end

function modfifer_key:OnRefresh()

end

function modfifer_key:GetOverrideAnimation(  )
	return ACT_DOTA_FLAIL
end

function modfifer_key:CheckState(  )
		local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FLYING] = true,
	}
	return state
end