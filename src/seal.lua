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
    calculate = function(_, card, context)
        if not context.blind_defeated or card.area ~= G.deck then
            return
        end

        local tag = Tag(get_next_tag_key("Roland_frost"))

        if tag.name == "Orbital Tag" then
            local hands = {}

            for k, v in pairs(G.GAME.hands) do
                if v.visible then
                    table.insert(hands, k)
                end
            end

            tag.ability.orbital_hand = pseudorandom_element(hands, pseudoseed("Roland_frost"))
        end

        add_tag(tag)
    end,
}
