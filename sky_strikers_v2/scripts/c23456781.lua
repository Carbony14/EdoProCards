-- Prototype Sky Striker Ace - Noir
local s,id=GetID()
s.listed_names={id}
s.listed_series={SET_SKY_STRIKER_ACE,SET_SKY_STRIKER}
s.activated_effects_while_face_up = 0

function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
    Link.AddProcedure(c,nil,2,99,s.lcheck)

    --Only 1 per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	--Temporary immunity
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e,tp)
		return Duel.GetFlagEffect(tp,id)==0 -- Só ativa se nunca foi usado este duelo
	end)
	e1:SetOperation(function(e,tp)
		Duel.RegisterFlagEffect(tp,id,0,0,1) -- Marca que já foi usado

		local c=e:GetHandler()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(function(e,te)
			return te:GetOwner()~=e:GetHandler()
		end)
		e2:SetReset(RESET_PHASE+PHASE_END,2) -- Até final do teu próximo turno
		c:RegisterEffect(e2)
	end)
	c:RegisterEffect(e1)

    --increase_atk per "Sky Striker" card in GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.attack_up_count_val)
	c:RegisterEffect(e2)

	--Attack all special summoned monsters
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(function(e,c)
		return c:IsSummonType(SUMMON_TYPE_SPECIAL)
	end)
	c:RegisterEffect(e3)

	-- When this card attacks, your opponent cannot activate cards or effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetAttacker()==e:GetHandler()
	end)
	e4:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		-- Lock opponent's activations only during this attack
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetValue(function(e,re,tp)
			return true
		end)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE) -- ends after the attack is concluded
		Duel.RegisterEffect(e1,tp)
	end)
	c:RegisterEffect(e4)

end

-- Link Materials: 1+ monsters, including at least 1 "Sky Striker" monster
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_SKY_STRIKER)  -- Assuming "Sky Striker" is SetCard 0x115
end

function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(s.matfilter,1,nil)
end

--Only 1 per turn
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsStatus(STATUS_SUMMONING)
end

--Temporary immunity condition
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetSummonLocation()==LOCATION_EXTRA
end

function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end


function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
end

-- attack up
function s.attack_up_count_filter(c)
	return c:IsSetCard(SET_SKY_STRIKER_ACE) or c:IsSetCard(SET_SKY_STRIKER)
end

function s.attack_up_count_val(e,c)
    return Duel.GetMatchingGroupCount(s.attack_up_count_filter, c:GetControler(), LOCATION_GRAVE, 0, nil) * 200
end
