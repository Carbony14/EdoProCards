-- Ritual of Dark Magic

local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN, CARD_DARK_MAGICIAN_GIRL, 30208479}
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1)
    --e1:SetCondition(s.conditions_function)
    e1:SetTarget(s.target_function)
    e1:SetCost(s.cost_function)
    e1:SetOperation(s.activate_function)
    c:RegisterEffect(e1)

    -- -- e2: GY Quick Effect Negate
    -- local e2=Effect.CreateEffect(c)
    -- e2:SetDescription(aux.Stringid(id,1))
    -- e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
    -- e2:SetType(EFFECT_TYPE_QUICK_O)
    -- e2:SetCode(EVENT_CHAINING)
    -- e2:SetRange(LOCATION_GRAVE)
    -- e2:SetCountLimit(1) -- Once per copy activation, not per turn
    -- e2:SetCondition(s.gynegate_condition)
    -- e2:SetTarget(s.gynegate_target)
    -- e2:SetOperation(s.gynegate_operation)
    -- e2:SetCost(aux.bfgcost) -- banish this card as cost
    -- c:RegisterEffect(e2)

end

-- Condition: Must have only Dark Magician, Dark Magician Girl, Magician of Black Chaos or monsters that mentions them.
function s.conditions_function(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		if s.restriction(e,tc) then
			return false -- You control a monster that doesn't meet the restriction
		end
	end
	return true -- All face-up monsters are valid
end

-- Cost: prevent non-Dark Magician summons before and after activation and send card to grave
function s.cost_function(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cost_filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
	end

    local g=Duel.SelectMatchingCard(tp,s.cost_filter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
    if #g==0 then return end
    if Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end

	-- Prevent Special Summons of non-DM monsters for rest of turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.restriction)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- Also block Normal Summons of non-DM monsters
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end

-- Cost: prevent non-Dark Magician summons before and after activation
function s.target_function(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.cost_filter,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.ritual_filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.activate_function(e,tp,eg,ep,ev,re,r,rp)
    -- Obtain Summonable Cards

    local rg=Duel.GetMatchingGroup(s.ritual_filter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
    if #rg==0 then return end

    -- Seleciona 1 Ritual Monster do grupo rg
    local sp_t=rg:Select(tp,1,1,nil)
    if #sp_t==0 then return end

    local rc=sp_t:GetFirst()
    rc:SetMaterial(nil)
    if Duel.SpecialSummonStep(rc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP) then
        rc:CompleteProcedure()
    end
    Duel.SpecialSummonComplete()

end

-- Filter for "Dark Magician"
function s.cost_filter(c)
    return (c:IsCode(CARD_DARK_MAGICIAN) or c:IsCode(30208479) or c:IsSetCard(0xcf)) and c:IsAbleToGrave()
end

-- Filter for "Chaos" Ritual Monsters that mention "Dark Magician", "Dark Magician Girl" or "Magician of Black Chaos"
function s.ritual_filter(c,e,tp)
    return c:IsType(TYPE_RITUAL) and c:IsMonster()
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
        and c:IsAbleToHand() -- placeholder for GY/Deck access
        and (c:ListsCode(CARD_DARK_MAGICIAN) or c:IsCode(30208479) or c:ListsCode(CARD_DARK_MAGICIAN_GIRL))
        and c:IsSetCard(0xcf)
end

--Restriction function
function s.restriction(e,c)
	return not c:ListsCode(CARD_DARK_MAGICIAN)
        and not c:ListsCode(30208479)
		and not c:IsCode(CARD_DARK_MAGICIAN)
		and not c:IsCode(30208479)
        and not (c:IsType(TYPE_RITUAL) and c:IsSetCard(0xcf))
end
