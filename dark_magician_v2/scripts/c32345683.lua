-- Dominion of Chaos
local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN}

function s.initial_effect(c)
    -- Enable Spell Counters and ensure they can only be added by this card's effect
    c:EnableCounterPermit(0x1) -- Spell Counter

    -- Activate only if all your monsters are Dark Magician or reference it
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(s.act_condition)
    e1:SetOperation(s.add_counters)
    e1:SetTarget(s.target)
    e1:SetCost(s.cost)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE + EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
    c:RegisterEffect(e1)

    -- Prevent opponent from responding to the activation of Dominion of Chaos
	local e1_1=Effect.CreateEffect(c)
	e1_1:SetType(EFFECT_TYPE_FIELD)
	e1_1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1_1:SetRange(LOCATION_FZONE)
	e1_1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1_1:SetTargetRange(1,0)
	e1_1:SetValue(1)
	e1_1:SetCondition(s.condition_prevent_activation)
	c:RegisterEffect(e1_1)

    -- Disable opponent's card effects on the field
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_DISABLE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTargetRange(0,LOCATION_ONFIELD)
    c:RegisterEffect(e2)

    -- Prevent opponent from activating cards/effects
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD)
    e3:SetCode(EFFECT_CANNOT_ACTIVATE)
    e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e3:SetRange(LOCATION_FZONE)
    e3:SetTargetRange(0,1)
    e3:SetValue(1)
    c:RegisterEffect(e3)

    -- Reduce one counter each time you activate a card or effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	--e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_FZONE)
    e4:SetCondition(s.counter_reduction_condition)
	e4:SetOperation(s.reduce_counter)
	c:RegisterEffect(e4)

    -- Check and destroy Dominion of Chaos if it has 0 counters at the end of each turn
    local e5=Effect.CreateEffect(c)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e5:SetCode(EVENT_CHAIN_SOLVING)
    e5:SetRange(LOCATION_FZONE)
    e5:SetCondition(s.check_counter)
    e5:SetOperation(s.destroy_if_zero)
    c:RegisterEffect(e5)

end

-- Condition: All your monsters must be Dark Magician or reference it
function s.act_condition(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    return g:FilterCount(s.valid_monster,nil)==#g
end

function s.act_condition(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
    return g:FilterCount(s.valid_monster,nil)==#g
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		Duel.SetChainLimit(aux.FALSE)
	end
end

function s.valid_monster(c)
    return c:IsCode(CARD_DARK_MAGICIAN)
        or c:ListsCode(CARD_DARK_MAGICIAN)
        or c:ListsCodeAsMaterial(CARD_DARK_MAGICIAN)
end

-- Condition to prevent opponent from responding to the card activation
function s.condition_prevent_activation(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer() == tp
end

-- On activation, gain Spell Counters equal to the opponent's card count minus yours
function s.add_counters(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()

    local op=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)
    local pl=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0) - 1
    local diff=math.max(0, op - pl)

    -- Add counters if there's a difference
    if diff > 0 and c:IsRelateToEffect(e) then
        c:AddCounter(0x1,diff)
    else
        Duel.SendtoGrave(c,REASON_EFFECT)
    end
end

-- Prevent other cards from adding counters to Dominion of Chaos
function s.counter_limit(e,c)
    return c ~= e:GetHandler()  -- Only allow the card itself to add counters
end

--- Condition: Only reduce counter when the effect is activated by the player
function s.counter_reduction_condition(e,tp,eg,ep,ev,re,r,rp)
    return ep == tp
end

-- Reduce 1 counter each time you activate a card or effect
function s.reduce_counter(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetCounter(0x1) > 0 then
        c:RemoveCounter(tp,0x1,1,REASON_EFFECT)
    end
    if c:GetCounter(0x1) <= 0 then
        Duel.SendtoGrave(c,REASON_EFFECT)  -- Send to the Graveyard
    end
end

-- Check if Dominion of Chaos has 0 counters
function s.check_counter(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:GetCounter(0x1) <= 0  -- Check if it has 0 Spell Counters
end

-- Destroy Dominion of Chaos if it has 0 counters
function s.destroy_if_zero(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    if c:GetCounter(0x1) <= 0 then
        Duel.SendtoGrave(c,REASON_EFFECT)  -- Send to the Graveyard
    end
end

--Restriction function
function s.turn_restriction(e,c)
	return not c:ListsCode(CARD_DARK_MAGICIAN)
        and not c:ListsCode(30208479)
		and not c:IsCode(CARD_DARK_MAGICIAN)
        and not c:IsCode(30208479)
        and not (c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(CARD_DARK_MAGICIAN))
        and not (c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(30208479))
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