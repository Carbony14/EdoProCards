--Loki, God of Mischief
local s,id=GetID()

function s.initial_effect(c)
	--Synchro Summon
	c:EnableReviveLimit()
	c:SetSPSummonOnce(id)
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x42),1,1,Synchro.NonTuner(nil),1,99)

	--Always treated as Aesir
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_SETCODE)
	e0:SetValue(0x42)
	c:RegisterEffect(e0)

	---------------------------------------------------
	-- EFFECT 1: Monster Special Summon negate
	---------------------------------------------------
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.moncon)
	e2:SetCost(s.moncost)
	e2:SetOperation(s.monop)
	c:RegisterEffect(e2)

	---------------------------------------------------
	-- EFFECT 2: Spell/Trap negate
	---------------------------------------------------
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+1)
	e3:SetCondition(s.spcon)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end

---------------------------------------------------
-- MONSTER EFFECT
---------------------------------------------------

function s.moncon(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and eg:IsExists(Card.IsControler,1,nil,1-tp)
end

function s.moncost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_COST)
end

function s.monop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	if #g>0 then
		local tc=g:GetFirst()
		if tc then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		end
	end
end

---------------------------------------------------
-- SPELL/TRAP EFFECT
---------------------------------------------------

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and (re:IsActiveType(TYPE_SPELL) or re:IsActiveType(TYPE_TRAP))
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		Duel.Draw(rp,1,REASON_EFFECT)
	end
end