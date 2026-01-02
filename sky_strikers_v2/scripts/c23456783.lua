-- Prototype Sky Striker Ace - Spectra
local s,id=GetID()
s.listed_names={id}
s.listed_series={SET_SKY_STRIKER_ACE,SET_SKY_STRIKER}

function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
    -- Link Materials: Exactly 1 monster, and it must be "Sky Striker Ace – Purple Danya"
    Link.AddProcedure(c,nil,1,1,s.lcheck)

    --This card is always treated as "Sky Striker Ace – Purple Danya"
    local e01=Effect.CreateEffect(c)
    e01:SetType(EFFECT_TYPE_SINGLE)
    e01:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
    e01:SetCode(EFFECT_ADD_CODE)
    e01:SetValue(23456784) -- Purple Danya's ID
    c:RegisterEffect(e01)

    --Must be link summuned
    local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.lnklimit)
	c:RegisterEffect(e1)

    --Only 1 per turn
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

    --Immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

    -- Search on Special Summon (Once per Duel)
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,1))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)  -- Once per Duel
    e3:SetTarget(s.thtg)
    e3:SetOperation(s.thop)
    c:RegisterEffect(e3)

    -- Target and Banish twice per battle
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,4))
    e4:SetCategory(CATEGORY_REMOVE)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
    e4:SetCountLimit(2,{id,4},EFFECT_COUNT_CODE_DUEL) -- 2 per Duel
    e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
    e4:SetTarget(s.banish_tg)
    e4:SetOperation(s.banish_op)
    c:RegisterEffect(e4)

end

--Check function for link summon
function s.lcheck(g,lc,sumtype,tp)
    return g:IsExists(Card.IsCode,1,nil,23456784)
end

--Only 1 per turn
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsStatus(STATUS_SUMMONING)
end

-- Filter function: only immune to opponent's effects
function s.efilter(e,tp)
    return tp:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

function s.thfilter(c)
    return c:IsSetCard(SET_SKY_STRIKER) and c:IsAbleToHand()   -- "Sky Striker" archetype
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

--banish player interaction limiter
function s.chlimit(e,ep,tp)
	return tp==ep
end

--target (opponent's field only)
function s.banish_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
    local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
    Duel.SetChainLimit(s.chlimit)
end

--operation
function s.banish_op(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local tc=Duel.GetFirstTarget()
    if tc and tc:IsRelateToEffect(e) then
        if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
            --lose 500 ATK if banish succeeds
            local e1=Effect.CreateEffect(c)
            e1:SetType(EFFECT_TYPE_SINGLE)
            e1:SetCode(EFFECT_UPDATE_ATTACK)
            e1:SetValue(-500)
            e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
            c:RegisterEffect(e1)
        end
    end
end