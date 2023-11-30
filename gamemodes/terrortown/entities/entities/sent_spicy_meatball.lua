ENT.Type = "anim"

ENT.PrintName		= "Spicy Meatball"
ENT.Author			= "Spanospy"
ENT.Contact			= "@Spanospy"
ENT.Purpose			= "INTENDED FOR ANIMATION ONLY"
ENT.Instructions	= "DO NOT SPAWN"
ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:Initialize()
end

if SERVER then
	AddCSLuaFile()

	ENT.MakeTime = CurTime()
	function ENT:Initialize()
		self:SetModel( "models/weapons/w_eq_fraggrenade.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		self.MakeTime = CurTime()

		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:EnableGravity(false)
		end
		self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)

	end

	function ENT:Use( activator, caller )
		return
	end

	function ENT:Think()

		if CurTime() - self.MakeTime > 2 then self:Remove() return end

		if !self.Solidified then
			self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			self.Solidified = true
		end

		local target = self.target

		if not IsValid(target) then self:Remove() return end
		if not target:Alive() then self:Remove() return end
		if SpecDM and (target.IsGhost and target:IsGhost()) then self:Remove() return end

		local distance = target:EyePos():DistToSqr( self:GetPos() )
		if distance < 500 then
			self:Remove()
		else
			local normVec = (target:EyePos() - self:GetPos()):GetNormalized()
			local phys = self:GetPhysicsObject()

			local curVel = phys:GetVelocity()
			local tarVel = normVec * math.min(distance * 0.25, 500)

			if phys then phys:SetVelocityInstantaneous(tarVel) end
		end
	end
end