--Preparation Of Dark Magic
local s,id=GetID()
function s.initial_effect(c)
    -- Activate: Search from Deck or Graveyard
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_MAGICIAN}
function s.filter(c)
    return (c:ListsCode(CARD_DARK_MAGICIAN) or c:IsCode(CARD_DARK_MAGICIAN))
		and c:IsAbleToHand()
		and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
		and not c:IsCode(id)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,1)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleDeck(tp)

		if Duel.IsPlayerCanDraw(tp,1)
			and Duel.IsExistingMatchingCard(s.dmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) then
			Duel.BreakEffect()
			Duel.ShuffleDeck(tp)
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end

end

function s.dmfilter(c)
    return c:IsCode(CARD_DARK_MAGICIAN)
end
