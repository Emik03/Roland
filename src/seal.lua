local f, _ = unpack(... or require "src.functional")

-- SMODS.Atlas {
--     px = 71,
--     py = 95,
--     key = "seal",
--     path = "seal.png",
-- }
SMODS.Seal {
    name = "Frost",
    key = "frost",
    badge_colour = HEX("12f254"),
    atlas = "void",
    pos = {x = 0, y = 0},
    config = {ready = true},
    calculate = function(_, card, context)
        if context.setting_blind or context.starting_shop then
            card.Roland_frost = nil
        end

        if not context.end_of_round or card.area ~= G.deck or card.Roland_frost then
            return
        end

        card.Roland_frost = true
        local tag = Tag(get_next_tag_key("Roland_frost"))

        if tag.name == "Orbital Tag" then
            tag.ability.orbital_hand = pseudorandom_element(
                f(G.GAME.hands):filter(function(v)
                    return v.visible
                end):into(),
                pseudoseed("Roland_frost")
            )
        end

        add_tag(tag)
    end,
}
