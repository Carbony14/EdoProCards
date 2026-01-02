-- Sky Striker Link Monster
local s,id=GetID()
s.listed_names={id}
s.listed_series={SET_SKY_STRIKER_ACE,SET_SKY_STRIKER}
s.activated_effects_while_face_up = 0

function s.initial_effect(c)
    -- Link Summon
    c:EnableReviveLimit()
    Link.AddProcedure(c,s.matfilter,1,99)

    -- Special Summon "Sky Striker Ace" monsters
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)

    -- Negate effects of opponent's monsters with lower ATK
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(0,LOCATION_MZONE)
    e2:SetTarget(s.disable)
    c:RegisterEffect(e2)

    -- Negate and destroy
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,1))
    e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCondition(s.negcon)
    e4:SetCost(s.negcost)
    e4:SetTarget(s.negtg)
    e4:SetOperation(s.negop)
    c:RegisterEffect(e4)

    -- Reduce one counter each time you activate a card or effect
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	--e4:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetOperation(s.increase_activation_var)
	c:RegisterEffect(e5)

    --increase_atk per effect activated
    local e6=Effect.CreateEffect(c)
    e6:SetType(EFFECT_TYPE_SINGLE)
    e6:SetCode(EFFECT_UPDATE_ATTACK)
    e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e6:SetRange(LOCATION_MZONE)
    e6:SetValue(s.atkval)
    c:RegisterEffect(e6)

end

-- Link Materials: 1+ monsters, including at least 1 "Sky Striker" monster
function s.matfilter(c,lc,sumtype,tp)
    return c:IsSetCard(SET_SKY_STRIKER)  -- Assuming "Sky Striker" is SetCard 0x115
end

-- Special Summon condition
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL) 
end

function s.spfilter(c,e,tp,zone)
    return c:IsSetCard(SET_SKY_STRIKER_ACE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    local zone=e:GetHandler():GetLinkedZone(tp)
    if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,zone) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()
    local co_linked_g = c:GetLinkedGroup()
    local link_level = c:GetLink()
    local available_summons = link_level - #co_linked_g
    local zone = c:GetLinkedZone(tp)

    if available_summons <= 0 then return end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,
        s.spfilter,
        tp,
        LOCATION_HAND+LOCATION_GRAVE,
        0,
        1,
        available_summons,
        nil,
        e,
        tp,
        zone)
    for tc in aux.Next(g) do
        Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone)
    end
    Duel.SpecialSummonComplete()
end

-- Disable monsters with less ATK
function s.disable(e,c)
    return c:IsFaceup() and c:GetAttack()<e:GetHandler():GetAttack()
end

-- Quick Effect Negate and Destroy
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsChainNegatable(ev)
end

function s.cfilter(c)
    return c:IsFaceup() and c:IsAbleToGrave()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=e:GetHandler():GetLinkedGroup():Filter(s.cfilter,nil)
    if chk==0 then return #g>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local sg=g:Select(tp,1,1,nil)
    Duel.SendtoGrave(sg,REASON_COST)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
        Duel.Destroy(eg,REASON_EFFECT)
    end
end

function s.increase_activation_var(e,tp,eg,ep,ev,re,r,rp)
    s.activated_effects_while_face_up  = s.activated_effects_while_face_up + 1
end

function s.atkval(e,tp,eg,ep,ev,re,r,rp)
    return s.activated_effects_while_face_up * 100
end
