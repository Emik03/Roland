local f, q, u = (... or require "lib.shared")[1], (... or require "lib.shared")[2], (... or require "lib.shared")[3]

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "tarot",
    path = "tarot.png",
}

q(SMODS.Consumable {
    key = "coolheaded",
    pos = {x = 0, y = 0},
    config = {extra = {amount = 1}},
    cost = 3,
    set = "Tarot",
    atlas = "tarot",
    artist = "Roland_aster",
    attributes = {"editions", "modify_card", "spectral"},
    loc_vars = function(_, info_queue, card)
        table.insert(info_queue, G.P_CENTERS.e_Roland_frozen)
        return {vars = {card.ability.extra.amount}}
    end,
    can_use = function(_, card)
        if not u() then
            return false
        end

        local highlighted = Bakery_API.get_highlighted()

        return #G.jokers.highlighted + #highlighted == card.ability.extra.amount and
            f(G.jokers.highlighted):concat(highlighted):all(function(v)
                return not v.edition
            end)
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
})
