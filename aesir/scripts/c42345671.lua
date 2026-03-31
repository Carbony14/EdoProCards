--Odin, Ruler of Asgard
local s,id=GetID()

function s.initial_effect(c)
    Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x42),1,1,Synchro.NonTuner(nil),1,99)
    c:EnableReviveLimit()
    c:SetSPSummonOnce(id)

    --Always treated as "Aesir"
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_SINGLE)
    e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e0:SetRange(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_EXTRA)
    e0:SetCode(EFFECT_ADD_SETCODE)
    e0:SetValue(0x4b)
    c:RegisterEffect(e0)

    --Activate Solemn traps from hand
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(LOCATION_HAND,0)
    e1:SetTarget(s.handtg)
    c:RegisterEffect(e1)

    --Draw when activating Solemn or Nordic S/T
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAINING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.drawop)
    c:RegisterEffect(e2)

    --Set on Special Summon
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_LEAVE_GRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.settg)
    e3:SetOperation(s.setop)
    c:RegisterEffect(e3)
end

-----------------------------------------------------
-- S O L E M N  I D S
-----------------------------------------------------
s.solemn_ids={
    41420027, -- Solemn Judgment
    40605147, -- Solemn Warning
    14315573, -- Solemn Strike
    84749824, -- Solemn Scolding
    78114463, -- Solemn Report
    16308000, -- Solemn Authority
    35346968, -- Solemn Wishes
    92512625, -- Solemn Scolding (duplicate kept as provided)
}

function s.isSolemn(c)
    for _,code in ipairs(s.solemn_ids) do
        if c:IsCode(code) then return true end
    end
    return false
end

-----------------------------------------------------
-- HAND ACTIVATION FILTER
-----------------------------------------------------
function s.handtg(e,c)
    return s.isSolemn(c)
end

-----------------------------------------------------
-- DRAW EFFECT
-----------------------------------------------------
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
    if rp~=tp then return end
    local rc=re:GetHandler()
    if not rc then return end

    if s.isSolemn(rc) or (rc:IsType(TYPE_SPELL+TYPE_TRAP) and rc:IsSetCard(0x42)) then
        Duel.Draw(tp,1,REASON_EFFECT)
        Duel.Recover(tp,500,REASON_EFFECT)
    end
end
-----------------------------------------------------
-- SET EFFECT
-----------------------------------------------------
function s.setfilter(c)
    return c:IsType(TYPE_TRAP) and c:IsSSetable()
        and (s.isSolemn(c) or c:IsSetCard(0xb2)) -- Nordic Relic assumed 0xB2
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
    end
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
    local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
    local tc=g:GetFirst()
    if tc then
        Duel.SSet(tp,tc)
    end
end