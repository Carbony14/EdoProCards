--First Circle of Chaos
local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN}
function s.initial_effect(c)

    -- This card is always treated as "Eternal Soul"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_ADD_CODE)
	e0:SetValue(48680970) -- Eternal Soul ID
	c:RegisterEffect(e0)

    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)

	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.immfilter)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)

	-- ATK boost for Dark Magician
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(s.atktg)
	e4:SetValue(s.atkval)
	c:RegisterEffect(e4)

	-- DEF boost for Dark Magician
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)

	-- ATK boost updates for Dark Magician
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_ADJUST)
	e6:SetRange(LOCATION_SZONE)
	e6:SetOperation(s.atkval)
	c:RegisterEffect(e6)
	e6:SetLabelObject(e4)

	-- DEF boost updates for Dark Magician
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_ADJUST)
	e7:SetRange(LOCATION_SZONE)
	e7:SetOperation(s.atkval)
	c:RegisterEffect(e7)
	e7:SetLabelObject(e5)

end


-- Function to target Dark Magician Monsters
function s.atktg(e,c)
    return c:IsCode(CARD_DARK_MAGICIAN) and c:IsFaceup() -- "Dark Magician"
end

-- Function to list dark magician cards
function isDarkMagicianCard(c)
    return (c:ListsCode(CARD_DARK_MAGICIAN) or c:IsCode(CARD_DARK_MAGICIAN)) and c:IsFaceup()
end

-- Function to calculate ATK/DEF value
function s.atkval(e,c)
	local c2 = e:GetHandler()
    local count = Duel.GetMatchingGroupCount(isDarkMagicianCard, c2:GetControler(), LOCATION_MZONE+LOCATION_SZONE, 0, nil)
    return count * 100
end

function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_DECK,0,1,nil,CARD_DARK_MAGICIAN)
end

function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
end

function s.tgfilter(c)
	return c:ListsCode(CARD_DARK_MAGICIAN) and c:IsAbleToGrave()
end

function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

function s.immfilter(e,c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:ListsCode(CARD_DARK_MAGICIAN)
end

function s.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
