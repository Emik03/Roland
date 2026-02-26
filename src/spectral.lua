local f, q, u = unpack(... or require "lib.shared")

local negative = {key = "e_negative_consumable", set = "Edition", config = {extra = 1}}

local spectral = (function()
    local x = 0

    ---@param tbl SMODS.Consumable|{artist?: string}
    ---@return SMODS.Consumable
    return function(tbl)
        tbl.cost = 4
        tbl.set = "Spectral"
        tbl.atlas = "spectral"
        tbl.pos = {x = x, y = 0}
        tbl.artist = tbl.artist and "Roland_" .. tbl.artist or nil
        local ret = SMODS.Consumable(tbl)
        x = x + 1

        q(function()
            Bakery_API.credit(ret)
        end)

        return ret
    end
end)()

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "spectral",
    path = "spectral.png",
}

SMODS.Sound {
    key = "void",
    path = "void.ogg",
}

spectral {
    key = "afterimage",
    pronouns = "he_they",
    artist = "aster",
    config = {extra = {amount = 1, hand = -2}},
    loc_vars = function(_, info_queue, card)
        table.insert(info_queue, negative)
        return {vars = {card.ability.extra.amount, card.ability.extra.hand}}
    end,
    can_use = function(_, card)
        return u() and card.ability.extra.amount == #Bakery_API.get_highlighted()
    end,
    use = function(_, card)
        f(Bakery_API.get_highlighted()):each(function(v)
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
        local cards = f(G.hand.cards):table()
        pseudoshuffle(cards, pseudoseed "RolandDual")

        f(cards):take(card.ability.extra.amount):each(function(v)
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
    loc_vars = function(_, info_queue, card)
        table.insert(info_queue, G.P_SEALS.Roland_glass)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function(_, card)
        return u() and #Bakery_API.get_highlighted() == card.ability.extra.amount
    end,
    use = function(_, _, _)
        f(Bakery_API.get_highlighted()):each(function(v)
            v:set_seal "Roland_glass"
        end)
    end,
}

local void = spectral {
    key = "void",
    pronouns = "it_its",
    artist = "aster",
    soul_rate = 0.003,
    soul_set = "Spectral",
    config = {extra = {amount = 2}},
    loc_vars = function(_, info_queue, card)
        table.insert(info_queue, negative)
        table.insert(info_queue, G.P_CENTERS.c_cryptid)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function()
        return #G.playing_cards > 1 and not not u()
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
            local cards = f(G.playing_cards):where(destructible):table()

            local function calculate_joker(v)
                v:calculate_joker {remove_playing_cards = true, removed = cards}
            end

            f(cards):each(destroy)
            f(G.jokers.cards):each(calculate_joker)

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

q(function()
    void.hidden = not SMODS.Mods.Cryptid
end)
