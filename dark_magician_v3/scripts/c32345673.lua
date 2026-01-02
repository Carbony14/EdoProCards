-- Ritual of Dark Magic

local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN, CARD_DARK_MAGICIAN_GIRL, 30208479}
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id) -- once per turn
    e1:SetTarget(s.target)
    e1:SetCondition(s.act_condition)
    e1:SetCost(s.cost)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    -- e2: Change name to revealed Fusion Monster
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(30208479,1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(s.e2con)
    e2:SetCost(s.e2cost)
    e2:SetTarget(s.e2tg)
    e2:SetOperation(s.e2op)
    c:RegisterEffect(e2)

end

-- Filter for "Dark Magician"
function s.tgfilter(c)
    return (c:IsCode(CARD_DARK_MAGICIAN) or c:IsCode(30208479)) and c:IsAbleToGrave()
end

-- Filter for Ritual Monsters that mention "Dark Magician"
function s.ritualfilter(c,e,tp)
    return c:IsType(TYPE_RITUAL) and c:IsMonster() 
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true)
        and c:IsAbleToHand() -- placeholder for GY/Deck access
        and (c:ListsCode(CARD_DARK_MAGICIAN) or c:IsCode(30208479))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.IsExistingMatchingCard(s.ritualfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    -- Send 1 "Dark Magician" from Deck to GY
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g==0 or Duel.SendtoGrave(g,REASON_EFFECT)==0 then return end

    -- Select up to 3 Ritual Monsters with different names
    local rg=Duel.GetMatchingGroup(s.ritualfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
    if #rg==0 then return end

    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local sg=aux.SelectUnselectGroup(rg,e,tp,1,3,s.checkUniqueNames,1,tp,HINTMSG_SPSUMMON)
    if #sg==0 then return end

    -- Special Summon the selected Ritual Monsters
    for tc in aux.Next(sg) do
        tc:SetMaterial(nil)
        Duel.SpecialSummonStep(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
        tc:CompleteProcedure()
    end
    Duel.SpecialSummonComplete()

    for tc in aux.Next(sg) do
    -- This checks if the monster is now treated as "Magician of Black Chaos"
        if tc:IsCode(30208479) or tc:GetCode() == 30208479 then
            -- s.GiveChaosNegateEffect(tc, e)
        end
    end

end

-- Checks that all selected cards have unique names
function s.checkUniqueNames(sg,e,tp,mg)
    return aux.ChkfMMZ(1)(sg,e,tp,mg) and sg:GetClassCount(Card.GetCode)==#sg,sg:GetClassCount(Card.GetCode)~=#sg
end

function s.GiveChaosNegateEffect(c,e)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_CHAINING)
    e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCountLimit(1)
    e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
        return Duel.IsChainNegatable(ev)
    end)
    e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
        if chk==0 then return true end
        Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
        if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
            Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
        end
    end)
    e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
        if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
            Duel.Destroy(eg,REASON_EFFECT)
        end
    end)
    c:RegisterEffect(e1,true)
end


-- Condition: Must have only Dark Magician, Dark Magician Girl, Magician of Black Chaos or monsters that mentions them.
function s.act_condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		if not (tc:IsCode(CARD_DARK_MAGICIAN) 
			or tc:IsCode(CARD_DARK_MAGICIAN_GIRL) 
            or tc:IsCode(30208479)
			or tc:ListsCode(CARD_DARK_MAGICIAN) 
			or tc:ListsCode(CARD_DARK_MAGICIAN_GIRL)
            or tc:ListsCode(30208479)) then
			return false -- You control a monster that doesn't meet the requirement
		end
	end
	return true -- All face-up monsters are valid
end

--Restriction function
function s.turn_restriction(e,c)
	return not c:ListsCode(CARD_DARK_MAGICIAN)
		and not c:ListsCode(CARD_DARK_MAGICIAN_GIRL)
        and not c:ListsCode(30208479)
		and not c:IsCode(CARD_DARK_MAGICIAN)
		and not c:IsCode(CARD_DARK_MAGICIAN_GIRL)
        and not c:IsCode(30208479)
        and not (c:IsType(TYPE_FUSION) and (c:ListsCodeAsMaterial(CARD_DARK_MAGICIAN) or c:ListsCodeAsMaterial(CARD_DARK_MAGICIAN_GIRL)))
end

-- Cost: prevent non-Dark Magician summons before and after activation
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- Must not have Special Summoned non-DM monsters before
		return true --Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
	end
	-- Prevent Special Summons of non-DM monsters for rest of turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.turn_restriction)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)

	-- Also block Normal Summons of non-DM monsters
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end


-- Condition: Control "Magician of Black Chaos"
function s.e2con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,30208479),tp,LOCATION_MZONE,0,1,nil)
end

-- Cost: Banish this card from GY
function s.e2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

-- Target: Reveal 1 Fusion Monster, target 1 "Magician of Black Chaos"
function s.e2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,30208479),tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_EXTRA,0,1,nil,TYPE_FUSION)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_EXTRA,0,1,1,nil,TYPE_FUSION)
	Duel.ConfirmCards(1-tp,g)
	e:SetLabel(g:GetFirst():GetCode())
	Duel.ShuffleExtra(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsCode,30208479),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.SetTargetCard(tc)
end

-- Operation: Change name
function s.e2op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local code=e:GetLabel()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(code)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	tc:RegisterEffect(e1)
end