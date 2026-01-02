--Master of Dark Magic
local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN}

function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
    c:AddMustBeFusionSummoned()
    c:SetSPSummonOnce(id)
	Fusion.AddProcMix(c,true,true,s.fusionfilterFR,s.fusionfilterGeneric) -- at least 2 matching cards
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,s.contactlimit)

    -- Name becomes "Magician of Black Chaos" while on the field or in the GY
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_MZONE + LOCATION_GRAVE)
    e0:SetValue(30208479)
    c:RegisterEffect(e0)

    --Add one spell card that mentions Dark Magician or Magician of Black Chaos
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.on_special_summon_target)
    e1:SetOperation(s.on_special_summon_operation)
    c:RegisterEffect(e1)

    --Quick Effect: Banish cards
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetTurnPlayer() == tp end)
    e2:SetCountLimit(1,id+1)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

end

--START OF CONTACT FUSION CODE
--filter
function s.fusionfilterGeneric(c)
    return (c:IsCode(CARD_DARK_MAGICIAN) or c:IsCode(30208479) or
            c:ListsCode(CARD_DARK_MAGICIAN) or c:ListsCode(30208479) or
            c:IsCode(15256925))
end

function s.fusionfilterFR(c,fc,sumtype,tp)
    return (c:IsCode(CARD_DARK_MAGICIAN) or c:IsCode(30208479) or
            c:ListsCode(CARD_DARK_MAGICIAN) or c:ListsCode(30208479))
            and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_RITUAL))
end

function s.contactfilter(tp)
	return Duel.GetMatchingGroup(s.fusionfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
end

function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end

function s.contactlimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

--END OF CONTACT FUSION CODE

--START OF ADD 1 CARD WHEN SPECIAL SUMMONED
function s.on_special_summon_filter(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToHand() and (c:ListsCode(CARD_DARK_MAGICIAN) or c:ListsCode(30208479) or c:IsCode(15256925))
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
--END OF ADD 1 CARD WHEN SPECIAL SUMMONED

--START OF REMOVE CODE
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=1
    if Duel.GetTurnPlayer()==tp then ct=2 end
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_ONFIELD)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    local ct=1
    if Duel.GetTurnPlayer()==tp then ct=2 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,ct,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end

--END OF REMOVE CODE