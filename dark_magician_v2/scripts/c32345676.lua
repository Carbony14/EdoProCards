--First Circle of Chaos
local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN, 30208479}
function s.initial_effect(c)

	--Activate: Add one Spell/Trap that mentions "Dark Magician" or "Magician of Black Chaos"
	local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)

	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_SZONE,0)
	e2:SetTarget(s.immune_targets)
	e2:SetValue(s.immune_player_filter)
	c:RegisterEffect(e2)

end


function s.activate_filter(c)
    return c:IsType(TYPE_SPELL+TYPE_TRAP)
        and c:IsAbleToHand()
        and (c:ListsCode(CARD_DARK_MAGICIAN) or c:ListsCode(30208479) or c:IsCode(15256925))
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.activate_filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

function s.immune_targets(e,c)
	return c:IsFaceup()
    and c:IsType(TYPE_SPELL+TYPE_TRAP)
    and (c:ListsCode(CARD_DARK_MAGICIAN) or c:ListsCode(30208479) or c:IsCode(15256925))
    and not c:IsCode(id)
end

function s.immune_player_filter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
