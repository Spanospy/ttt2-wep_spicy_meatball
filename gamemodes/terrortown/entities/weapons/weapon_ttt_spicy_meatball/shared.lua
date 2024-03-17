
if SERVER then
	AddCSLuaFile()
    resource.AddFile("materials/vgui/ttt/icon_spicy_meatball.vmt")
    resource.AddFile("sound/spicy_meatball/spicy_meatball_burp.wav")
    resource.AddFile("sound/spicy_meatball/hatsaspicymeatball.wav")
end

if CLIENT then
    hook.Add("Initialize", "ttt2_spicy_meatball_init", function()
		STATUS:RegisterStatus("ttt2_spicy_meatball_status", {
			hud = Material("vgui/ttt/hud_icon_spicy_meatball.png"),
			type = "bad",
			name = "status_spicy_meatball",
			sidebarDescription = "status_spicy_meatball_desc"
		})
	end)
end


local sounds = {
	deny = Sound("Player.DenyWeaponSelection"),
	fed = Sound("HealthVial.Touch"),
    force = Sound("physics/body/body_medium_break3.wav"),
    impact = Sound("physics/metal/metal_grenade_impact_soft2.wav"),
    pin = Sound("Default.PullPin_Grenade"),
    burp = Sound("spicy_meatball/spicy_meatball_burp.wav"),
    thatsaspicymeatball = Sound("spicy_meatball/thatsaspicymeatball.wav")
}


SWEP.Base = "weapon_tttbase"


SWEP.HoldNormal = "slam"

SWEP.HoldType = "grenade"

if CLIENT then
    SWEP.Author = "Spanospy"
	--SWEP.Slot = 7
    SWEP.DrawAmmo = false
    SWEP.Category = "Explosive"

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 54
    SWEP.DrawCrosshair = false

	SWEP.Icon = "vgui/ttt/icon_spicy_meatball.vtf"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_spicy_meatball",
        desc = "weapon_spicy_meatball_desc"
    }

    function SWEP:Initialize()
        self:AddTTT2HUDHelp("help_spicy_meatball_primary")
        return self.BaseClass.Initialize(self)
    end

    function SWEP:AddToSettingsMenu(parent)
		local form = vgui.CreateTTT2Form(parent, "header_equipment_additional")

        form:MakeHelp({
            label = "label_spicy_meatball_damage_scaling_desc"
        })

		form:MakeSlider({
			serverConvar = "ttt2_spicy_meatball_detonate_time",
			label = "label_spicy_meatball_detonate_time",
			min = 0,
			max = 15,
			decimal = 0
		})

        form:MakeSlider({
			serverConvar = "ttt2_spicy_meatball_radius",
			label = "label_spicy_meatball_radius",
			min = 0,
			max = 500,
			decimal = 0
		})

        form:MakeSlider({
			serverConvar = "ttt2_spicy_meatball_heal",
			label = "label_spicy_meatball_heal",
			min = 0,
			max = 100,
			decimal = 0
		})

	end
end

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Delay = 0.5
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize	= -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo	= "none"

SWEP.Kind = WEAPON_SPECIAL
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true
SWEP.WeaponID = SPICY_MEATBALL
SWEP.DeploySpeed = 2

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_eq_fraggrenade.mdl"
SWEP.WorldModel = "models/weapons/w_eq_fraggrenade.mdl"

SWEP.Weight = 5

SWEP.NoSights = true

function SWEP:PrimaryAttack()

    local owner = self:GetOwner()

	local trace = owner:GetEyeTrace() --TODO check if hats block head hitgroup hits
	local distance = trace.StartPos:Distance(trace.HitPos)
    local ent = trace.Entity

    if CLIENT and not IsValidAttack(owner, ent, distance, trace) then 
        self:EmitSound(sounds["deny"])
        return 
    end

    --self:SendWeaponAnim(ACT_VM_THROW)


    if SERVER and IsValidAttack(owner, ent, distance, trace) then
        owner:SetAnimation(PLAYER_ATTACK1)
        ent:EmitSound(sounds["force"], 75, 100, 0.75, CHAN_WEAPON )
        self:EmitSound(sounds["impact"], 75, 100, 1, CHAN_WEAPON )
        self:EmitSound(sounds["pin"], 75, 100, 1, CHAN_WEAPON )
        GiveSpicyMeatball(ent, owner)
        self:Remove()
    end

end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function IsValidAttack(attacker, ent, distance, trace)
    local isHit, validHit = ComputeAttack(attacker, ent, distance, trace)
    return isHit and validHit
end

function ComputeAttack(attacker, ent, distance, trace)

    local isHit = false
    local validHit = false

    if distance > 100 then return isHit, validHit end
    if not IsValid(ent) or not ent:IsPlayer() then return isHit, validHit end

    isHit = true

    if trace ~= nil then

        --Check if ent has a head HeadGroup
        local HasHead = HasHitGroup(ent, 1)

        --If so, check if the trace hits the head HitGroup and return if it doesn't.
        if HasHead then
            if trace.HitGroup ~= 1 then return isHit, validHit end
        end

        --if not, see if the trace hit is close enough to ent's eyepos
        --TODO

    end

    --Should we check if ent is somewhat facing the attacker? Possible ideas:
    ---ent:Visible(attacker) (intended for NPCs)
    ---ent:VisibleVec(attacker:EyePos()) (check multiple positions? This will fail if the ent can't properly see the attacker's head.)
    ---ent:IsLineOfSightClear(attacker) (No clue how this one works. Does it just use GetEyeTrace?)
    ---Check if the ent is looking directly at the attacker:
    ----local enttrace = ent:GetEyeTrace() 
    ---Manually work out a field of view of the ent and see if attacker eyepos is in it:
    ----local enteyes = ent:EyePos()
    ----local entaim = ent:GetAimVector()

    validHit = true

    return isHit, validHit
end

function HasHitGroup(ent, targethitgroup)

    --Ensure lookup table for caching player hitbox info is setup
    if TTT2_Spicy_Meatball_HLookup == nil then 
        TTT2_Spicy_Meatball_HLookup = {} 
    end

    --Values used to verify accuracy of lookup
    local PlayerModel = ent:GetModel()
    local HitBoxSet, HitBoxSetName = ent:GetHitboxSet()
    local HitBoxCount = ent:GetHitBoxCount(HitBoxSet)

    if TTT2_Spicy_Meatball_HLookup[ent] then

        local cached = true

        --ensure lookup is up to date (i.e. the player hasn't changed their playermodel or hitboxes since we last checked)
        if TTT2_Spicy_Meatball_HLookup[ent]["PlayerModel"] ~= PlayerModel
        or TTT2_Spicy_Meatball_HLookup[ent]["HitBoxSet"] ~= HitBoxSet
        or TTT2_Spicy_Meatball_HLookup[ent]["HitBoxSetName"] ~= HitBoxSetName
        or TTT2_Spicy_Meatball_HLookup[ent]["HitBoxCount"] ~= HitBoxCount then
            --Not up to date; will need to re-evaluate hitbox info.
            cached = false
        end

        if cached then
            --use the HitGroup info stored in cache.
            return TTT2_Spicy_Meatball_HLookup[ent]["HitGroup" .. targethitgroup]
        end
    end

    --If not in lookup (or cache out of date), let's populate it.

    local newcache = {}
    newcache["PlayerModel"] = PlayerModel
    newcache["HitBoxSet"] = HitBoxSet
    newcache["HitBoxSetName"] = HitBoxSetName
    newcache["HitBoxCount"] = HitBoxCount

    for i = 0, HitBoxCount - 1 do
        local HitGroup = ent:GetHitBoxHitGroup(i, HitBoxSet)

        if HitGroup >= 0 and newcache["HitGroup" .. HitGroup] ~= true then
            newcache["HitGroup" .. HitGroup] = true
        end

    end

    TTT2_Spicy_Meatball_HLookup[ent] = newcache

    --Use cache to answer the call
    return TTT2_Spicy_Meatball_HLookup[ent]["HitGroup" .. targethitgroup] == true

end


if SERVER then

    function GiveSpicyMeatball(ply, attacker)

        local timerName = "ttt2_spicy_meatball_timer_" .. ply:UserID()
        local duration = GetConVar("ttt2_spicy_meatball_detonate_time"):GetInt()
        local heal = GetConVar("ttt2_spicy_meatball_heal"):GetInt()

        --Check ply hasn't already received a spicy meatball
        if timer.Exists(timerName) and timer.TimeLeft(timerName) > 0 then return end

        --Heal player, for fun :)
        if heal > 0 and ply:GetMaxHealth() > ply:Health() then
            ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + heal))
            ply:EmitSound(sounds["fed"], 60, 100, 0.75, CHAN_WEAPON )
        end

        --Ensure lookup table for Spicy Meatball explosion timers is setup
        if TTT2_Spicy_Meatball_ELookup == nil then 
            TTT2_Spicy_Meatball_ELookup = {} 
        end

        TTT2_Spicy_Meatball_ELookup[timerName] = {}
        local lut = TTT2_Spicy_Meatball_ELookup[timerName]

        lut[1] = ply --Entity to place explosion at
        lut[2] = attacker --Entity that will be attributed to causing the explosion

        --Add spicy meatball to player
        STATUS:AddTimedStatus(ply, "ttt2_spicy_meatball_status",duration, true)
        timer.Create(timerName, duration, 1, function()
            SpicyMeatballExplosion(lut[1], lut[2], timerName)
        end)

        --Add the status to the attacker too, so they know when it'll explode.
        --STATUS:AddTimedStatus(attacker, "ttt2_spicy_meatball_status",duration, true)

        --Add a delayed burp
        timer.Simple(duration - 1, function()

            target = lut[1]

            if not IsTangible(target) then return end

            target:EmitSound(sounds["burp"], 75, 100, 1, CHAN_WEAPON )

        end)

        --Spawn a spicy meatball that travels from the attacker to the target's eyepos.
        --This is only for animation.
        --SpicyMeatballAnim(ply, attacker)

    end

    function SpicyMeatballAnim(ply, attacker)

        local ang = attacker:EyeAngles()
		local src = attacker:GetPos() + (attacker:Crouching() and attacker:GetViewOffsetDucked() or attacker:GetViewOffset()) + ang:Forward() * 8 + ang:Right() * 10

        local ent = ents.Create("sent_spicy_meatball")
        if not IsValid(ent) then return end
        ent.target = ply
        ent:SetPos(src)
        ent:SetAngles(Angle(0,0,0))
        ent:Spawn()

    end

    hook.Add("TTTOnCorpseCreated", "SpicyMeatballCheck", function(rag, ply)

        if ply:Alive() then return end --Presumably not their real body

        local timerName = "ttt2_spicy_meatball_timer_" .. ply:UserID()

        if not timer.Exists(timerName) then return end

        if timer.TimeLeft(timerName) then
            --change entity reference in lookup table to be the ragdoll
            TTT2_Spicy_Meatball_ELookup[timerName][1] = rag
        end

    end)

    function IsTangible(ent)

        if not IsValid(ent) then return false end
        if ent:IsPlayer() then 
            if not ent:Alive() then return false end
            if SpecDM and (ent.IsGhost and ent:IsGhost()) then return false end
        end

        return true

    end

    function SpicyMeatballExplosion(target, attacker, lutName)

        if GetRoundState() == ROUND_PREP then return end

        if not IsTangible(target) then return end
    
        local meatball = ents.Create("weapon_ttt_spicy_meatball") --temporary entity for BlastDamage, since the original weapon has already been removed.
        local radius = GetConVar("ttt2_spicy_meatball_radius"):GetInt()
        local damage = 200 * (meatball.damageScaling or 1)

        --GetPos() gives us the feet of the target if it's a player. So let's adjust that and get the center of the ent's collision instead.
        local basepos = target:GetPos()
        local posmin, posmax = target:GetCollisionBounds()
        local pos = ((posmin + basepos) + (posmax + basepos)) / 2

    
        local effect = EffectData()
        effect:SetStart(pos)
        effect:SetOrigin(pos)
        effect:SetScale(radius * 0.3)
        effect:SetRadius(radius)
        effect:SetMagnitude(damage)

        if GetRoundState() ~= ROUND_POST and attacker:GetSubRole() == ROLE_JESTER then
            damage = 0
        end
    
        util.Effect("Explosion", effect, true, true)
        
        util.BlastDamage(meatball, attacker, pos, radius, damage)

        meatball:Remove()
        
        local trs = util.TraceLine({
            start = pos + Vector(0, 0, 64),
            endpos = pos + Vector(0, 0, -128),
            filter = target
        })
        util.Decal("SmallScorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)


        --Easter egg :)
        if target:IsPlayer() then
            timer.Simple(2, function()
                if IsTangible(target) then
                    target:EmitSound(sounds["thatsaspicymeatball"], 75, 100, 1, CHAN_WEAPON )
                end
            end)
        end
        
        --Cleanup lookup table
        if lutName then 
            TTT2_Spicy_Meatball_ELookup[lutName] = nil 
        end
    end

end


if CLIENT then
	local TryT = LANG.TryTranslation

	hook.Add("TTTRenderEntityInfo", "HUDDrawTargetIDSpicyMeatball", function(tData)
		local client = LocalPlayer()
		local ent = tData:GetEntity()
        local distance = tData:GetEntityDistance()

		if not IsValid(client) or not client:IsTerror() or not client:Alive() then return end

		local c_wep = client:GetActiveWeapon()
		local role_color = client:GetRoleColor()

		if not IsValid(c_wep) or c_wep:GetClass() ~= "weapon_ttt_spicy_meatball" then return end

        if not ent:IsPlayer() then return end

        local isHit, validHit = ComputeAttack(client, ent, distance, client:GetEyeTrace())

        if not isHit then
            tData:AddDescriptionLine(
                TryT("targetid_spicy_meatball_notinrange"),
                COLOR_ORANGE
            )

        elseif not validHit then
            tData:AddDescriptionLine(
                TryT("targetid_spicy_meatball_invalidattack"),
                COLOR_ORANGE
            )
            
        elseif validHit then
            -- enable targetID rendering
            tData:EnableOutline()
            tData:SetOutlineColor(client:GetRoleColor())

            tData:AddDescriptionLine(
                TryT("targetid_spicy_meatball_validattack"),
                role_color
            )

            -- draw instant-kill maker
            local x = ScrW() * 0.5
            local y = ScrH() * 0.5

            surface.SetDrawColor(clr(role_color))

            local outer = 20
            local inner = 10
            
            surface.DrawLine(x - outer, y - outer, x - inner, y - inner)
            surface.DrawLine(x + outer, y + outer, x + inner, y + inner)

            surface.DrawLine(x - outer, y + outer, x - inner, y + inner)
            surface.DrawLine(x + outer, y - outer, x + inner, y - inner)
        end

	end)
end