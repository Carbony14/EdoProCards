-- Chaos Scepter Invocation of Darkness
local s,id=GetID()
s.listed_names={30208479, CARD_DARK_MAGICIAN}

function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Choice options
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chk==0 then return true end
    local op=Duel.SelectEffect(tp,
        {true,aux.Stringid(id,0), "Special Summon 1 Spellcaster from GY or banished"},
        {true,aux.Stringid(id,1), "Add 1 card that mentions 'Dark Magician'"},
        {true,aux.Stringid(id,2), "Add 1 'Chaos Scepter' Spell from your GY"},
        {true,aux.Stringid(id,3), "'Magician of Black Chaos' gain 500 ATK/DEF per Spellcaster"}
    )
    e:SetLabel(op)
    if op==1 then
        Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
    elseif op==2 or op==3 then
        Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
    elseif op==4 then
        Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,LOCATION_MZONE)
    end
end

-- Filters
function s.spfilter(c,e,tp)
    return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.dmfilter(c)
    return c:IsAbleToHand() and c:ListsCode(CARD_DARK_MAGICIAN)
end

function s.scepterfilter(c)
    return c:IsAbleToHand() and c:IsType(TYPE_SPELL)
        and (c:IsCode(32345675) or c:IsCode(15256925))
        and c:IsAbleToHand()
end

function s.mobcfilter(c)
    return c:IsFaceup() and c:IsCode(30208479) -- Magician of Black Chaos
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local op=e:GetLabel()
    if op==1 then
        local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
        if #g>0 then Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
    elseif op==2 then
        local g=Duel.SelectMatchingCard(tp,s.dmfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    elseif op==3 then
        local g=Duel.SelectMatchingCard(tp,s.scepterfilter,tp,LOCATION_GRAVE,0,1,1,nil)
        if #g>0 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
            Duel.ConfirmCards(1-tp,g)
        end
    elseif op==4 then
        -- Count Spellcasters across field, GYs, and banished (both players)
        local count=Duel.GetMatchingGroupCount(Card.IsRace,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,nil,RACE_SPELLCASTER)
        if count==0 then return end
        local g=Duel.GetMatchingGroup(s.mobcfilter,tp,LOCATION_MZONE,0,nil)
        for tc in aux.Next(g) do
            local atk=Effect.CreateEffect(e:GetHandler())
            atk:SetType(EFFECT_TYPE_SINGLE)
            atk:SetCode(EFFECT_UPDATE_ATTACK)
            atk:SetValue(count*500)
            atk:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
            tc:RegisterEffect(atk)
            local def=atk:Clone()
            def:SetCode(EFFECT_UPDATE_DEFENSE)
            tc:RegisterEffect(def)
        end
    end
end
