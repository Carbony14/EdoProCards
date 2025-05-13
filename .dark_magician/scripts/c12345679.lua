--Master of Dark Magic
local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN}
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcCode2(c,CARD_DARK_MAGICIAN,12345678,false,false)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,s.contactlimit)

    --Add one spell card that mentions Dark Magician or Master of Dark Magic
    local e0=Effect.CreateEffect(c)
    e0:SetDescription(aux.Stringid(id,0))
    e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e0:SetCode(EVENT_SPSUMMON_SUCCESS)
    e0:SetProperty(EFFECT_FLAG_DELAY)
    e0:SetCountLimit(1,id)
    e0:SetTarget(s.on_special_summon_target)
    e0:SetOperation(s.on_special_summon_operation)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

    -- Name becomes "Dark Magician" while on the field or in the GY
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_CHANGE_CODE)
    e3:SetRange(LOCATION_MZONE + LOCATION_GRAVE)
    e3:SetValue(CARD_DARK_MAGICIAN)
    c:RegisterEffect(e3)


    -- e5: Negate and destroy when opponent activates a card or effect
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,0))
    e5:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_MZONE)
    e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e5:SetCountLimit(1,id+100)
    e5:SetCondition(s.negcon)
    e5:SetTarget(s.negtg)
    e5:SetOperation(s.negop)
    c:RegisterEffect(e5)

end
s.listed_names={CARD_DARK_MAGICIAN}

function s.contactfil(tp)
	return Duel.GetMatchingGroup(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_ONFIELD,0,nil)
end

function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end

function s.contactlimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

function s.on_special_summon_filter(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToHand() and (c:ListsCode(CARD_DARK_MAGICIAN) or c:ListsCode(12345679))
end

function s.on_special_summon_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.on_special_summon_filter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.on_special_summon_operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.on_special_summon_filter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.atkfilter(c)
    return c:ListsCode(CARD_DARK_MAGICIAN) and not c:IsCode(id) or c:IsCode(CARD_DARK_MAGICIAN)
end

function s.atkval(e,c)
    local tp=c:GetControler()

    -- Face-up cards on field that list "Dark Magician"
    local fieldCount=Duel.GetMatchingGroupCount(function(tc)
        return tc:IsFaceup() and s.atkfilter(tc)
    end, tp, LOCATION_ONFIELD, 0, nil)

    -- Cards in GY and banished zone that list "Dark Magician"
    local gyBanishedCount=Duel.GetMatchingGroupCount(s.atkfilter, tp, LOCATION_GRAVE+LOCATION_REMOVED, 0, nil)

    return (fieldCount + gyBanishedCount) * 100
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

--Quick Effect
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp~=tp and Duel.IsChainNegatable(ev)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
        Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
    end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end
