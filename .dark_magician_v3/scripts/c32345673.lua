-- Ritual of Dark Magic

local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN, CARD_DARK_MAGICIAN_GIRL, 30208479}
function s.initial_effect(c)
    -- Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetCondition(s.act_condition)
    e1:SetCost(s.cost)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

    --e2: GY Quick effect Chaos Form Ritual
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
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


--Control DM and MBC in field or GY
function s.spfilter2(c,code)
	return c:IsCode(code) and (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE))
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,46986414)
	   and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,30208479)
end

--Chaos Form Spellcaster Ritual filter
function s.chaosfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsType(TYPE_RITUAL)
		and c:ListsCode(21082832) -- Chaos Form
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SPECIAL,tp,true,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.chaosfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,PLAYER_ALL,0)
end

function s.sdfilter(c, e, tp)
    return c:IsFaceup() and not (c:IsRace(RACE_SPELLCASTER) and c:IsControler(tp))
end

function s.sdatkfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<=atk
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,s.chaosfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)==0 then return end
	Duel.SpecialSummonComplete()

	-- Destroy all monsters with ATK <= summoned monster except your Spellcasters
	local atk=tc:GetAttack()
	local g1=Duel.GetMatchingGroup(s.sdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil, e, tp)
    local dg = g1:Filter(s.sdatkfilter, nil, atk)
	if #dg>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end