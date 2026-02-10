local f, q, u = unpack(... or require "src.functional")

local spectral = (function()
    local x = 0

    ---@param tbl SMODS.Consumable
    return function(tbl)
        tbl.cost = 4
        tbl.set = "Spectral"
        tbl.atlas = "spectral"
        tbl.pos = {x = x, y = 0}
        SMODS.Consumable(tbl)
        x = x + 1
    end
end)()

SMODS.Sound {
    key = "void",
    path = "void.ogg",
}

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "spectral",
    path = "spectral.png",
}

spectral {
    key = "afterimage",
    pronouns = "he_they",
    config = {extra = {amount = 1, hand = -1}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.amount, card.ability.extra.hand}}
    end,
    can_use = function(_, card)
        return u() and card.ability.extra.amount == #Bakery_API.get_highlighted()
    end,
    use = function(_, card)
        f(Bakery_API.get_highlighted()):foreach(function(v)
            q {
                delay = 0.1,
                func = function()
                    v:set_edition {negative = true}
                    v:juice_up(0.5, 0.5)
                end,
            }
        end)

        q {
            delay = 0.1,
            func = function()
                G.hand:change_size(card.ability.extra.hand)
                Bakery_API.unhighlight_all()
            end,
        }
    end,
}

spectral {
    key = "dual",
    pronouns = "they_them",
    config = {extra = {amount = 2}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function()
        return u() and #G.hand.cards > 0
    end,
    use = function(_, card, _)
        local cards = f(G.hand.cards, ipairs):into()
        pseudoshuffle(cards, pseudoseed "RolandDual")

        f(cards):take(card.ability.extra.amount):foreach(function(v)
            local seal

            for _ = 1, 31 do
                seal = SMODS.poll_seal {guaranteed = true}

                if seal ~= "Roland_glass" then
                    break
                end
            end

            v:set_seal(seal == "Roland_glass" and "Red" or seal)
        end)
    end,
}

spectral {
    key = "mirror",
    pronouns = "he_him",
    config = {extra = {amount = 1}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function(_, card)
        return u() and #Bakery_API.get_highlighted() == card.ability.extra.amount
    end,
    use = function(_, _, _)
        f(Bakery_API.get_highlighted()):foreach(function(v)
            v:set_seal "Roland_glass"
        end)
    end,
}

spectral {
    key = "void",
    hidden = true,
    soul_rate = 0.003,
    soul_set = "Spectral",
    pronouns = "it_its",
    config = {extra = {amount = 2}},
    loc_vars = function(_, _, card)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function()
        return #G.playing_cards > 1 and u()
    end,
    use = function(_, card)
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
            local cards = f(G.playing_cards):filter(destructible):into()

            local function calculate_joker(v)
                v:calculate_joker {remove_playing_cards = true, removed = cards}
            end

            f(cards):foreach(destroy)
            f(G.jokers.cards):foreach(calculate_joker)

            for _ = 1, card.ability.extra.amount do
                local cryptid = create_card(nil, G.consumeables, nil, nil, nil, nil, "c_cryptid", "void")
                cryptid:set_edition({negative = true}, true)
                cryptid:add_to_deck()
                G.consumeables:emplace(cryptid)
            end
        end

        play_sound("Roland_void", 1, 0.7)

        q {
            delay = 0.28,
            timer = "REAL",
            trigger = "after",
            func = void,
        }
    end,
}
