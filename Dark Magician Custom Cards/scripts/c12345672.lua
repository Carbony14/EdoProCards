--Dark Magic Fusion

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(
		c,
		aux.FilterBoolFunction(Card.ListsCodeAsMaterial,CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL),
		nil,
		s.fextra,
		nil,
		nil,
		nil,
		2,
		nil,
		nil,
		nil,
		nil,
		nil,
		nil,
		s.extratg)
	e1:SetCountLimit(1, id)
	e1:SetCondition(s.act_condition)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.counterfilter)

end

s.listed_names={CARD_DARK_MAGICIAN, CARK_DARK_MAGICIAN_GIRL}

function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end

function s.counterfilter(c)
	return c:IsType(TYPE_FUSION)
end

function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK)

end

-- Condition: Must have only Dark Magician, Dark Magician Girl or monsters that mentions them.
function s.act_condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	for tc in aux.Next(g) do
		if not (tc:IsCode(CARD_DARK_MAGICIAN) 
			or tc:IsCode(CARD_DARK_MAGICIAN_GIRL) 
			or tc:ListsCode(CARD_DARK_MAGICIAN) 
			or tc:ListsCode(CARD_DARK_MAGICIAN_GIRL)) then
			return false -- You control a monster that doesn't meet the requirement
		end
	end
	return true -- All face-up monsters are valid
end

--Restriction function
function s.turn_restriction(e,c)
	return not c:ListsCode(CARD_DARK_MAGICIAN)
		and not c:ListsCode(CARD_DARK_MAGICIAN_GIRL)
		and not c:IsCode(CARD_DARK_MAGICIAN)
		and not c:IsCode(CARD_DARK_MAGICIAN_GIRL)
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
