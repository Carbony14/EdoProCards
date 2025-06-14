--Preparation Of Dark Magic
local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN}
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

	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.escon)
	e2:SetTarget(s.estg)
	e2:SetOperation(s.esop)
	e2:SetCountLimit(1,id+100)
	c:RegisterEffect(e2)
end

function s.filter(c)
    return (c:ListsCode(CARD_DARK_MAGICIAN) or c:IsCode(CARD_DARK_MAGICIAN))
		and c:IsAbleToHand()
		and c:IsType(TYPE_SPELL)
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

			if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
				Duel.Draw(tp,1,REASON_EFFECT)
			end

		end
	end

end

function s.dmfilter(c)
    return c:IsCode(CARD_DARK_MAGICIAN)
end


function s.esfilter(c)
    return c:IsCode(48680970) and c:IsSSetable()
end

function s.escon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0
end

function s.estg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
            and Duel.IsExistingMatchingCard(s.esfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
end

function s.esop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
        local g=Duel.SelectMatchingCard(tp,s.esfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
        end
    end
end
