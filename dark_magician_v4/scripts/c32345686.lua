-- Chaos Burning Magic
local s,id=GetID()
local CARD_DARK_MAGIC_ATTACK=2314238 -- Dark Magic Attack ID

s.listed_names={CARD_DARK_MAGICIAN, CARD_DARK_MAGIC_ATTACK}

function s.initial_effect(c)
    --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)

    -- Treat as "Dark Magic Attack"
    local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(CARD_DARK_MAGIC_ATTACK)
	c:RegisterEffect(e0)

end

function s.is_face_up_code_filter(c, code)
	return c:IsFaceup() and c:IsCode(code)
end

function s.is_face_up_set_filter(c, set)
	return c:IsFaceup() and c:IsRitualMonster() and c:IsSetCard(set)
end

function s.self_target_filter(c)
	return s.is_face_up_code_filter(c, CARD_DARK_MAGICIAN) or s.is_face_up_set_filter(c, 0xcf)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.is_face_up_code_filter,tp,LOCATION_MZONE,0,1,nil,CARD_DARK_MAGICIAN)
		and Duel.IsExistingMatchingCard(s.is_face_up_set_filter,tp,LOCATION_MZONE,0,1,nil,0xcf)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
        return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil)
            and Duel.IsExistingMatchingCard(s.self_target_filter,tp,LOCATION_MZONE,0,1,nil)
    end

    -- Select your monster
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g1=Duel.SelectTarget(tp,s.self_target_filter,tp,LOCATION_MZONE,0,1,1,nil)

    -- Select up to 2 opponent's cards
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g2=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)

    g1:Merge(g2)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,#g1,0,0)

end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
    local tg=g:Filter(Card.IsRelateToEffect,nil,e)
    if #tg>0 then
        Duel.Destroy(tg,REASON_EFFECT)
    end
end
