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

    -- ATK/DEF boost + Unaffected for "Magician of Black Chaos"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,0)
    e1:SetTarget(s.statfilter)
    e1:SetValue(500)
    c:RegisterEffect(e1)
    local e2=e1:Clone()
    e2:SetCode(EFFECT_UPDATE_DEFENSE)
    c:RegisterEffect(e2)

    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_SZONE)
    e3:SetTargetRange(LOCATION_MZONE,0)
    e3:SetTarget(s.statfilter)
    e3:SetValue(s.efilter)
    c:RegisterEffect(e3)

    -- Banish effect
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_CHAIN_SOLVING)
    e4:SetRange(LOCATION_SZONE)
    e4:SetCondition(s.rmcon)
    e4:SetTarget(s.rmtg)
    e4:SetOperation(s.rmop)
    e4:SetCountLimit(1)
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

-- Trigger condition: A "Magician of Black Chaos" you control activates an effect
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    local rc=re:GetHandler()
    return rc and rc:IsControler(tp) and rc:IsCode(30208479)
end

-- Banish target
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
    if chk==0 then return #g>0 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end

-- Banish operation
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
    if #g>0 then
        Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
    end
end
