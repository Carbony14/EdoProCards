--Beginning of Chaos
local s,id=GetID()
s.listed_names={CARD_DARK_MAGICIAN}
function s.initial_effect(c)
    -- Activate: Place "Eternal Soul" and optionally send "Dark Magician"
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

function s.esfilter(c)
    return c:IsCode(48680970) and c:IsSSetable()
end

function s.dmfilter(c)
    return c:IsCode(CARD_DARK_MAGICIAN) and c:IsAbleToGrave()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        return Duel.IsExistingMatchingCard(s.esfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
    end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
    local g=Duel.SelectMatchingCard(tp,s.esfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
    local tc=g:GetFirst()
    if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
        Duel.ConfirmCards(1-tp,tc)
        -- Now offer to send Dark Magician
        if Duel.IsExistingMatchingCard(s.dmfilter,tp,LOCATION_DECK,0,1,nil)
            and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
            local dg=Duel.SelectMatchingCard(tp,s.dmfilter,tp,LOCATION_DECK,0,1,1,nil)
            if #dg>0 then
                Duel.SendtoGrave(dg,REASON_EFFECT)
            end
        end
    end
end