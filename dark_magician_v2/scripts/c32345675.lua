--Chaos Scepter Void Blast
local s,id=GetID()
s.listed_names={30208479}

function s.initial_effect(c)
    -- Activate: Non-target negate + optional banish
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetCondition(s.condition)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Check if you control a "Magician of Black Chaos" or a Level 8 Spellcaster
function s.condfilter(c)
    return c:IsFaceup() and (c:IsCode(30208479) or (c:IsRace(RACE_SPELLCASTER) and c:IsLevel(8)))
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.condfilter,tp,LOCATION_MZONE,0,1,nil)
        and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil)
end

-- Effect: Non-target negate and optional banish
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
    if #g==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
    local sg=g:Select(tp,1,1,nil)
    local tc=sg:GetFirst()
    if not tc then return end

    -- Negate its effects
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_DISABLE)
    e1:SetReset(RESET_EVENT+RESETS_STANDARD)
    tc:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_DISABLE_EFFECT)
    tc:RegisterEffect(e2)

    Duel.BreakEffect()

    -- Optional banish
    local bg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
    if #bg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
        local rm=bg:Select(tp,1,1,nil)
        Duel.Remove(rm,POS_FACEUP,REASON_EFFECT)
    end
end
