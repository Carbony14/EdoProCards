-- Second Circle of Chaos
local s,id=GetID()
s.listed_names={30208479}

function s.initial_effect(c)
    -- Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCountLimit(1,id)
    c:RegisterEffect(e0)

    -- IMMUNE EFFECT
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.statfilter)
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)

    -- Add Chaos Scepters up to the number of "Magician of Black Chaos" you control
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_TOHAND)
    e4:SetType(EFFECT_TYPE_IGNITION)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCountLimit(1,id+100)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)

end

-- Filter for "Magician of Black Chaos"
function s.statfilter(e,c)
    return c:IsCode(30208479) -- Card ID for "Magician of Black Chaos"
end

-- Unaffected by opponent's effects
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.thfilter(c)
    return c:IsType(TYPE_SPELL+TYPE_QUICKPLAY) and c:IsAbleToHand() and s.isChaosScepter(c)
end

function s.isChaosScepter(c)
    return c:IsCode(32345675) or c:IsCode(15256925) or c:IsCode(32345683) -- add all Chaos Scepter codes here
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_MZONE,0,nil,30208479)
    if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_MZONE,0,nil,30208479)
    if ct==0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end