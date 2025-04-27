-- Dark Magician of Destruction
local s,id=GetID()

function s.initial_effect(c)
    -- Special summon restriction
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)
    -- Name becomes "Dark Magician" while on the field or in the GY
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(CARD_DARK_MAGICIAN)
    c:RegisterEffect(e0)

    --Place 1 "Eternal Soul" from your Deck or GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.operation_eternal_soul)
	c:RegisterEffect(e1)

    -- Quick effect: Destroy 1 card
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_MZONE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCountLimit(2, id+2)
    e3:SetTarget(s.destroy_target)
    e3:SetOperation(s.destroy_operation)
    c:RegisterEffect(e3)

    -- Remove when it leaves the field
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetValue(LOCATION_REMOVED)
    c:RegisterEffect(e4)

end

s.listed_names={CARD_DARK_MAGICIAN}

-- Effect filter: Unaffected by opponent's card effects
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end

function s.filter_eternal_soul(c)
    return c:IsCode(48680970) and c:IsSSetable()-- Eternal Soul's code is 48680970
end

function s.operation_eternal_soul(e,tp,eg,ep,ev,re,r,rp)
    --local g=Duel.SelectMatchingCard(tp,s.filter_eternal_soul,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    local g=Duel.GetMatchingGroup(s.filter_eternal_soul,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,nil)
	if #g>0 then
		local g=Duel.SelectMatchingCard(tp,s.filter_eternal_soul,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end

end

-- Check if a Dark Magician Spell or Trap card Soul is face-up on your field
function s.immune_condition(e)
    return Duel.IsExistingMatchingCard(function(c)
        return c:IsFaceup() and c:ListsCode(CARD_DARK_MAGICIAN)
    end, e:GetHandlerPlayer(), LOCATION_SZONE, 0, 1, nil)
end

-- Immune to opponent's effects
function s.immune_filter(e, te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.destroy_target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetChainLimit(aux.FALSE)
end

function s.destroy_operation(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        Duel.Destroy(tc,REASON_EFFECT)
    end
end
