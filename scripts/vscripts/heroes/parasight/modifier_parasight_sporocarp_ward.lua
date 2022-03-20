modifier_parasight_sporocarp_ward = class({})

function modifier_parasight_sporocarp_ward:IsHidden()
    return true
end

function modifier_parasight_sporocarp_ward:CheckState()
    return {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true    
    }
end

function modifier_parasight_sporocarp_ward:Combust()
	self:GetParent():ForceKill(false)
end

function modifier_parasight_sporocarp_ward:OnDestroy()
	if IsServer() then
		local unit = self:GetParent()
		local caster = self:GetCaster()

		if caster and caster.spores then
			 for i = 1, #caster.spores do
	            if caster.spores[i] == unit then
	                table.remove(caster.spores, i)
	                break
	            end
	        end
		end
	end
end
