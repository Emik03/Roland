local f, q = unpack(... or require "src.functional")

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "seal",
    path = "seal.png",
}

SMODS.Seal {
    key = "glass",
    atlas = "seal",
    pos = {x = 0, y = 0},
    badge_colour = HEX "a6a6a6",
    pronouns = "he_him",
    calculate = function(_, card, context)
        local function proc()
            card.Roland_glass = true
            local tag = Tag(get_next_tag_key "Roland_glass")

            if tag.name == "Orbital Tag" then
                tag.ability.orbital_hand = pseudorandom_element(
                    f(G.GAME.hands):filter(function(v)
                        return v.visible
                    end):keys():into(),
                    pseudoseed "Roland_glass"
                )
            end

            add_tag(tag)
            play_sound "other1"
        end

        if context.setting_blind or context.starting_shop then
            card.Roland_glass = nil
        end

        if card.Roland_glass then
            return
        end

        if context.hand_drawn and f(context.hand_drawn):any(function(v)
                return v == card
            end) then
            q(function()
                card:shatter()
            end)

            SMODS.calculate_context({remove_playing_cards = true, removed = {card}})
        end

        if context.ante_end then
            proc()
        end
    end,
}
