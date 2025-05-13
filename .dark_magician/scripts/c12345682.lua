--Spirit of Chaos
local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN}
s.listed_series={SET_CHAOS}
s.sp_summoned_codes = {}

function s.initial_effect(c)
	-- Special summon restriction
	--c:EnableReviveLimit()
	--c:SetSPSummonOnce(id)
	Link.AddProcedure(c,s.matfilter,1,1)

	--Place 1 "Eternal Soul" from your Deck or GY to your field
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	--e0:SetCountLimit(1,id)
	e0:SetCondition(s.condition_eternal_soul)
	e0:SetOperation(s.operation_eternal_soul)
	c:RegisterEffect(e0)

	-- Name becomes "Dark Magician" while on the GY or field
    local en=Effect.CreateEffect(c)
    en:SetType(EFFECT_TYPE_SINGLE)
    en:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    en:SetCode(EFFECT_CHANGE_CODE)
    en:SetRange(LOCATION_MZONE|LOCATION_GRAVE)
    en:SetValue(CARD_DARK_MAGICIAN)
    c:RegisterEffect(en)

	--Increase ATK of monsters it points to
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.atkdef_target)
	e1:SetValue(500)
	c:RegisterEffect(e1)

	--Increase DEF of monsters it points to
	local e1_d=e1:Clone()
	e1_d:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1_d)

    -- Special Summon effect (Quick Effect)
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, id+100)
	e2:SetHintTiming(0, TIMINGS_CHECK_MONSTER + TIMING_END_PHASE)
	e2:SetCondition(s.sp_condition)
	e2:SetTarget(s.sp_target)
    e2:SetCost(s.sp_cost)
	e2:SetOperation(s.sp_operation)
	c:RegisterEffect(e2)

end

--Link Summon Conditions
function s.matfilter(c,scard,sumtype,tp)
	return c:IsType(TYPE_MONSTER) and (c:IsCode(CARD_DARK_MAGICIAN) or c:ListsCode(CARD_DARK_MAGICIAN))
end

-- Effect filter: Unaffected by opponent's card effects
function s.efilter(e,te)
    return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end

function s.filter_eternal_soul(c)
    return c:IsCode(48680970) and c:IsSSetable()-- Eternal Soul's code is 48680970
end

-- Condition for placing one eternal soul face up
function s.condition_eternal_soul(e,tp,eg,ep,ev,re,r,rp)
    local c = e:GetHandler()  -- Get the monster being summoned
    if c:IsSummonType(SUMMON_TYPE_LINK) then  -- Check if it's a Link Summon
        local mg = c:GetMaterial()  -- Get the materials used for the summon
        -- Check if Dark Magician is in the materials
        local sp_by_dm = mg:IsExists(function(c) return c:IsCode(CARD_DARK_MAGICIAN) and c:GetOriginalCode()~=id end, 1, nil)
        local g = Duel.GetMatchingGroup(s.filter_eternal_soul,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,nil)
        return sp_by_dm and #g > 0
    end
    return false
end

function s.operation_eternal_soul(e,tp,eg,ep,ev,re,r,rp)
    --local g=Duel.SelectMatchingCard(tp,s.filter_eternal_soul,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    local g=Duel.GetMatchingGroup(s.filter_eternal_soul,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,nil)
	if #g>0 then
		local g=Duel.SelectMatchingCard(tp,s.filter_eternal_soul,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end

end

-- Effect for increasing ATK/DEF of cards this card points to
function s.atkdef_target(e,c)
    return e:GetHandler():GetLinkedGroup():IsContains(c)
end

--QUICK EFFECT RELATED----

-- Condition to check if both "First Circle of Chaos" and "Second Circle of Chaos" are controlled
function s.sp_condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.IsExistingMatchingCard(s.sp_chaos_check,tp,LOCATION_SZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.sp_chaos_check_2,tp,LOCATION_SZONE,0,1,nil)
end

-- Filter for "First Circle of Chaos"
function s.sp_chaos_check(c)
    return c:GetOriginalCode() == 12345676 and c:IsFaceup()
end

-- Filter for "Second Circle of Chaos"
function s.sp_chaos_check_2(c)
    return c:GetOriginalCode() == 12345677 and c:IsFaceup()
end

function s.sp_filter(c,e,tp)
    return c:IsType(TYPE_FUSION)  -- Ensure it's a Fusion Monster
        and (
            c:IsCode(12381100) or -- Check for specific card code
            c:IsSetCard(SET_CHAOS)  -- Check if it belongs to the "CHAOS" set
            or c:ListsCode(CARD_DARK_MAGICIAN)  -- Check if it lists Dark Magician
            or c:ListsCode(CARD_DARK_MAGICIAN_GIRL)  -- Check if it lists Dark Magician Girl
            or c:ListsCodeAsMaterial(CARD_DARK_MAGICIAN)  -- Check if Dark Magician is used as material
            or c:ListsCodeAsMaterial(CARD_DARK_MAGICIAN_GIRL)  -- Check if Dark Magician Girl is used as material
        )
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)

end

function s.sp_target_filter(c,e,tp)
    return c:IsType(TYPE_FUSION)  -- Ensure it's a Fusion Monster
        and (
            c:IsCode(12381100) or -- Check for specific card code
            c:IsSetCard(SET_CHAOS)  -- Check if it belongs to the "CHAOS" set
            or c:ListsCode(CARD_DARK_MAGICIAN)  -- Check if it lists Dark Magician
            or c:ListsCode(CARD_DARK_MAGICIAN_GIRL)  -- Check if it lists Dark Magician Girl
            or c:ListsCodeAsMaterial(CARD_DARK_MAGICIAN)  -- Check if Dark Magician is used as material
            or c:ListsCodeAsMaterial(CARD_DARK_MAGICIAN_GIRL)  -- Check if Dark Magician Girl is used as material
        )
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end

function s.sp_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.sp_target_filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end

function s.sp_cost(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then 
        return c:IsAbleToGraveAsCost() and c:IsLocation(LOCATION_MZONE)
    end
    Duel.SendtoGrave(c, REASON_COST)
end

function s.sp_operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.sp_target_filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
    local tc=g:GetFirst()
    if tc then
        Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP,true)
        tc:CompleteProcedure()
    end
end
