local function can_use()
    return not ((G.play and #G.play.cards > 0 or
            G.CONTROLLER.locked or
            (G.GAME.STOP_USE and G.GAME.STOP_USE > 0)) and
        G.STATE ~= G.STATES.HAND_PLAYED and
        G.STATE ~= G.STATES.DRAW_TO_HAND and
        G.STATE ~= G.STATES.PLAY_TAROT)
end

SMODS.Sound({key = "void", path = "void.ogg"})

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "afterimage",
    path = "afterimage.png",
}

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "void",
    path = "void.png",
}

SMODS.Consumable {
    key = "afterimage",
    set = "Spectral",
    pos = {x = 0, y = 0},
    cost = 6,
    atlas = "afterimage",
    config = {extra = {amount = 1, hand = -1}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.amount, card.ability.extra.hand}}
    end,
    can_use = function(_, card)
        return can_use() and card.ability.extra.amount == #Bakery_API.get_highlighted()
    end,
    use = function(_, card, _, _)
        for _, v in ipairs(Bakery_API.get_highlighted()) do
            G.E_MANAGER:add_event(Event {
                delay = 0.1,
                func = function()
                    v:set_edition({negative = true})
                    v:juice_up(0.5, 0.5)
                    return true
                end,
            })
        end

        G.E_MANAGER:add_event(Event {
            delay = 0.1,
            func = function()
                G.hand:change_size(card.ability.extra.hand)
                Bakery_API.unhighlight_all()
                return true
            end,
        })
    end,
}

SMODS.Consumable {
    key = "void",
    set = "Spectral",
    pos = {x = 0, y = 0},
    cost = 6,
    hidden = true,
    atlas = "void",
    soul_rate = 0.003,
    soul_set = "Spectral",
    config = {extra = {amount = 2}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function(_, _)
        return #G.playing_cards > 1 and can_use()
    end,
    use = function(_, card, _, _)
        local function destructible(v)
            return not v.ability or not (v.ability.eternal or v.ability.cry_absolute)
        end

        local function destroy(v)
            if v.area then
                v.area:remove_card(v)
            end

            v.rhm = false
            v:start_dissolve()
        end

        local function void()
            local cards = F.filter(G.playing_cards, destructible)

            local function calculate_joker(v)
                v:calculate_joker({remove_playing_cards = true, removed = cards})
            end

            F.foreach(cards, destroy)
            F.foreach(G.jokers.cards, calculate_joker)

            for _ = 1, card.ability.extra.amount do
                local cryptid = create_card(
                    nil,
                    G.consumeables,
                    nil,
                    nil,
                    nil,
                    nil,
                    "c_cryptid",
                    "void"
                )

                cryptid:set_edition({negative = true}, true)
                cryptid:add_to_deck()
                G.consumeables:emplace(cryptid)
            end

            return true
        end

        play_sound("Roland_void", 1, 0.7)

        G.E_MANAGER:add_event(Event({
            delay = 0.27,
            timer = "REAL",
            trigger = "after",
            func = void,
        }))
    end,
}
