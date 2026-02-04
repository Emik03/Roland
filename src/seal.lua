local f, q = unpack(... or require "src.functional")

-- SMODS.Atlas {
--     px = 71,
--     py = 95,
--     key = "seal",
--     path = "seal.png",
-- }
SMODS.Seal {
    key = "glass",
    atlas = "void",
    pos = {x = 0, y = 0},
    badge_colour = HEX "f6f6f6",

    calculate = function(_, card, context)
        if context.setting_blind or context.starting_shop then
            card.Roland_glass = nil
        end

        if card.Roland_glass then
            return
        end

        if G.STATE == G.STATES.DRAW_TO_HAND and card == context.other_card then
            card.Roland_glass = true

            return q(function()
                card:shatter()
            end)
        end

        if not context.ante_end then
            return
        end

        card.Roland_glass = true
        local tag = Tag(get_next_tag_key "Roland_glass")

        if tag.name == "Orbital Tag" then
            tag.ability.orbital_hand = pseudorandom_element(
                f(G.GAME.hands):filter(function(v)
                    return v.visible
                end):into(),
                pseudoseed "Roland_glass"
            )
        end

        add_tag(tag)
    end,
}
