--Spirit of Dark Magic
local s,id=GetID()
function s.initial_effect(c)

    -- Treated as Dragon while in Deck
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_CHANGE_RACE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_DECK)
    e1:SetValue(RACE_DRAGON)
    c:RegisterEffect(e1)

    -- Level becomes 7 on field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_CHANGE_LEVEL)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(7)
    c:RegisterEffect(e2)

    -- Special Summon from GY if you control Dark Magician
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetCountLimit(1,id)
    e3:SetCondition(s.spcon)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)

    -- Cannot be Special Summoned except by its own effect
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e4:SetCode(EFFECT_SPSUMMON_CONDITION)
    e4:SetValue(s.splimit)
    c:RegisterEffect(e4)

    -- Quick Effect: Send this card from hand to GY, then Special Summon Dark Magician or Dark Magician Girl from Deck
    local e5=Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_IGNITION)
    e5:SetCode(EVENT_FREE_CHAIN)
    e5:SetRange(LOCATION_HAND)
    e5:SetCountLimit(1,id+2) -- separate count from GY effect
    e5:SetCost(s.qecost)
    e5:SetTarget(s.qetg)
    e5:SetOperation(s.qeop)
    c:RegisterEffect(e5)

end
s.listed_names={CARD_DARK_MAGICIAN, CARD_DARK_MAGICIAN_GIRL}

function s.spfilter(c)
    return c:IsFaceup() and c:IsCode(CARD_DARK_MAGICIAN) or c:IsFaceup() and c:IsCode(CARD_DARK_MAGICIAN_GIRL) -- Dark Magician
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:IsRelateToEffect(e) then
        if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
            e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
            e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
            e1:SetValue(LOCATION_REMOVED)
            c:RegisterEffect(e1,true)
        end
    end
end

function s.splimit(e,se,sp,st)
    return se and se:GetHandler() and se:GetHandler():IsCode(id)
end

-- Quick Effect: Discard and Special Summon Dark Magician or Dark Magician Girl from Deck
function s.qecost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return c:IsAbleToGraveAsCost() end
    Duel.SendtoGrave(c,REASON_COST)
end

function s.qefilter(c)
    return c:IsCode(CARD_DARK_MAGICIAN) or c:IsCode(CARD_DARK_MAGICIAN_GIRL)
end

function s.qetg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.qefilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end

function s.qeop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.qefilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
