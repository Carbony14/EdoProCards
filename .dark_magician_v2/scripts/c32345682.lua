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
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetValue(CARD_DARK_MAGICIAN)
    c:RegisterEffect(e1)

    -- Search Chaos Scepter cards on Ritual Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
    end)
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    -- Allow Quick-Play Spell activation from hand during opponent's turn
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD)
    e4:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e4:SetRange(LOCATION_MZONE)
    e4:SetTargetRange(LOCATION_HAND,0)
    e4:SetTarget(function(e,c)
        return c:IsType(TYPE_QUICKPLAY)
    end)
    c:RegisterEffect(e4)

end

function s.thfilter(c)
    return (c:IsCode(32345675) or c:IsCode(15256925) or c:IsCode(32345683))
        and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
