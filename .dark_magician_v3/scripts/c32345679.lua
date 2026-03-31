--Spirit of Dark Magic
local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN}

function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()

	Fusion.AddProcMix(c,true,true,s.fusionfilterFR,s.fusionfilterGeneric) -- at least 2 matching cards
    Fusion.AddContactProc(c,s.contactfilter,s.contactop,s.contactlimit)

    -- Name becomes "Magician of Black Chaos" while on the field or in the GY
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_CHANGE_CODE)
    e2:SetRange(LOCATION_MZONE + LOCATION_GRAVE)
    e2:SetValue(CARD_DARK_MAGICIAN)
    c:RegisterEffect(e2)

    --Add one spell card that mentions Dark Magician or Magician of Black Chaos
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_SPSUMMON_SUCCESS)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetCountLimit(2, id)
    e3:SetTarget(s.on_special_summon_target)
    e3:SetOperation(s.on_special_summon_operation)
    c:RegisterEffect(e3)

    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,3))
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCode(EVENT_TO_GRAVE)
    e4:SetCountLimit(1,id+300)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)

    local e4b=e4:Clone()
    e4b:SetCode(EVENT_REMOVE)
    c:RegisterEffect(e4b)

end

-- Cannot be Fusion Summoned more than once per turn
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	-- allow non-Fusion Special Summons (revives, etc.)
	if st~=SUMMON_TYPE_FUSION then return true end
	-- once per turn check
	return Duel.GetFlagEffect(sp,c:GetCode())==0
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsSummonType(SUMMON_TYPE_FUSION) then
		Duel.RegisterFlagEffect(tp,c:GetCode(),RESET_PHASE+PHASE_END,0,1)
	end
end

--START OF CONTACT FUSION CODE
--filter
function s.fusionfilterGeneric(c)
    return (c:IsCode(CARD_DARK_MAGICIAN) or c:IsCode(30208479) or
            c:ListsCode(CARD_DARK_MAGICIAN) or c:ListsCode(30208479) or
            c:IsCode(15256925))
end

function s.fusionfilterFR(c,fc,sumtype,tp)
    return (c:IsCode(CARD_DARK_MAGICIAN) or c:IsCode(30208479) or
            c:ListsCode(CARD_DARK_MAGICIAN) or c:ListsCode(30208479))
            and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_RITUAL))
end

function s.contactfilter(tp)
	return Duel.GetMatchingGroup(s.fusionfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
end

function s.contactop(g,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end

function s.contactlimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end

--END OF CONTACT FUSION CODE

--START OF ADD 1 CARD WHEN SPECIAL SUMMONED
function s.on_special_summon_filter(c)
    return c:IsType(TYPE_SPELL) and c:IsAbleToHand() and (c:ListsCode(CARD_DARK_MAGICIAN) or c:ListsCode(30208479) or c:IsCode(15256925))
end

function s.on_special_summon_target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.on_special_summon_filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

function s.on_special_summon_operation(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.on_special_summon_filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end
--END OF ADD 1 CARD WHEN SPECIAL SUMMONED


function s.thfilter(c)
	return (c:IsCode(59514116) or c:IsCode(71143015)) and c:IsAbleToHand() -- Secrets of Dark Magic
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),
		tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end