-- Prototype Sky Striker Ace - Phantom
local s,id=GetID()
s.listed_names={id}
s.listed_series={SET_SKY_STRIKER_ACE,SET_SKY_STRIKER}

function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
    -- Link Materials: Exactly 1 monster, and it must be "Sky Striker Ace – Purple Danya"
    Link.AddProcedure(c,nil,2,2,s.link_check)

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

    --Negate all Special Summoned monsters your opponent controls (once per Duel)
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,2))
    e2:SetCategory(CATEGORY_DISABLE)
    e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetCountLimit(1,{id,2},EFFECT_COUNT_CODE_DUEL) -- Once per Duel
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

    --increase_atk per "Sky Striker" card in GY
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.attack_up_count_val)
	c:RegisterEffect(e3)

end

-- Link Materials: 1+ monsters, including at least 1 "Sky Striker" monster
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_SKY_STRIKER_ACE)  -- Assuming "Sky Striker" is SetCard 0x115
end

function s.link_check(g,lc,sumtype,tp)
	return g:IsExists(Card.IsCode,1,nil,23456784)
end

--Only 1 per turn
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsStatus(STATUS_SUMMONING)
end

-- Filter function: only immune to opponent's effects
function s.efilter(e,tp)
    return tp:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- attack up
function s.attack_up_count_filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.attack_up_count_val(e,c)
    return Duel.GetMatchingGroupCount(s.attack_up_count_filter, c:GetControler(), 0, LOCATION_MZONE, nil) * 500
end

--Condition (only when properly Special Summoned)
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) -- only triggers on proper Link Summon
end

--Target
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(function(c) return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsControler(1-tp) and not c:IsDisabled() end,tp,0,LOCATION_MZONE,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end

--Operation
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local g=Duel.GetMatchingGroup(function(c) return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsControler(1-tp) and c:IsFaceup() end,tp,0,LOCATION_MZONE,nil)
    for tc in g:Iter() do
        --Negate its effects
        Duel.NegateRelatedChain(tc,RESET_TURN_SET)
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_DISABLE)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
        local e2=Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetCode(EFFECT_DISABLE_EFFECT)
        e2:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e2)
    end
end

