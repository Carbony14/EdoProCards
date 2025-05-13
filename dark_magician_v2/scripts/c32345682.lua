-- Dark Magician of Black Chaos
local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN, 30208479}

function s.initial_effect(c)
    c:EnableReviveLimit()
    -- Name becomes "Magician of Black Chaos" while on the field
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetCode(EFFECT_CHANGE_CODE)
    e0:SetRange(LOCATION_MZONE)
    e0:SetValue(30208479)
    c:RegisterEffect(e0)

    -- Name becomes "Dark Magician" while on the GY
    local e01=Effect.CreateEffect(c)
    e01:SetType(EFFECT_TYPE_SINGLE)
    e01:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e01:SetCode(EFFECT_CHANGE_CODE)
    e01:SetRange(LOCATION_GRAVE)
    e01:SetValue(CARD_DARK_MAGICIAN)
    c:RegisterEffect(e01)

    -- Special summon a Spellcaster from the GY or Banishement zone
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

end

-- Special summon Spellcaster in GY or Banished
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)

         -- Gain 1000 ATK/DEF
        local c=e:GetHandler()
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(500)

        c:RegisterEffect(e1)

        local e2=e1:Clone()
        e2:SetCode(EFFECT_UPDATE_DEFENSE)
        c:RegisterEffect(e2)

    end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- First opponent effect of the turn
    return rp~=tp and Duel.IsChainDisablable(ev)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    -- Negate the effect
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.NegateEffect(ev)
    --Duel.NegateActivation(ev)

    -- Gain 500 ATK/DEF
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetValue(500)

    c:RegisterEffect(e1)

    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

end