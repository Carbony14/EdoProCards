--Magician of Black Chaos Supreme
local s,id=GetID()
s.listed_names={30208479}

function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
    c:AddMustBeFusionSummoned()
    c:SetSPSummonOnce(id)
    Fusion.AddProcMixN(c,true,true,s.matfilter,1)
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,s.contactlimit)

    -- Treated as "Magician of Black Chaos"
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_ADD_CODE)
    e1:SetValue(30208479) -- Card ID for "Magician of Black Chaos"
    c:RegisterEffect(e1)

    -- Quick‑Effect: Negate + Banish
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_CHAINING)
    e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e2:SetRange(LOCATION_MZONE)            -- change if this card is a Spell/Trap
    e2:SetCountLimit(1,id)                 -- once per turn for this copy
    e2:SetCondition(s.negcon)
    e2:SetTarget(s.negtg)
    e2:SetOperation(s.negop)
    c:RegisterEffect(e2)

end
-- Contact fusion

-- Material filter
function s.matfilter(c,fc,sumtype,tp)
    return (c:IsCode(30208479) or c:GetCode() == 30208479) and not c:IsType(TYPE_FUSION)
end

-- Contact Fusion - return to Deck from field or hand
function s.contactfilter(tp)
    return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_MZONE,0,nil)
end

function s.contactop(g,tp)
    --Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
    Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end

function s.contactlimit(e,se,sp,st)
    return e:GetHandler():IsLocation(LOCATION_EXTRA)
end


-- Trigger only on the opponent’s activation and when the chain is negatable
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and Duel.IsChainNegatable(ev)
end

-- Declare we will negate (and possibly banish) the activating card
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    if re:GetHandler():IsAbleToRemove() then
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
    end
end

-- Negate the activation and, if possible, banish the source card
function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) then
        local rc=re:GetHandler()
        if rc and rc:IsRelateToEffect(re) and rc:IsAbleToRemove() then
            Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
        end
    end
end
