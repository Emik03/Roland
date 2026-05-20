local f, q, u = unpack(... or require "lib.shared")

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "tarot",
    path = "tarot.png",
}

SMODS.Consumable {
    key = "coolheaded",
    pos = {x = 0, y = 0},
    config = {extra = {amount = 1}},
    cost = 3,
    set = "Tarot",
    atlas = "tarot",
    attributes = {"editions", "modify_card", "spectral"},
    loc_vars = function(_, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.e_Roland_frozen)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function(_, card)
        return u() and f(G.jokers.highlighted):concat(Bakery_API.get_highlighted()):count(function(v)
            return not v.edition
        end) == card.ability.extra.amount
    end,
    use = function()
        f(G.jokers.highlighted):concat(Bakery_API.get_highlighted()):each(function(v)
            q {
                delay = 0.1,
                func = function()
                    v:set_edition {Roland_frozen = true}
                end,
            }
        end)
    end,
}
