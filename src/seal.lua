local f, q = unpack(... or require "lib.shared")

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
    attributes = {"destroy_card", "tag"},
    badge_colour = HEX "a6a6a6ff",
    pronouns = "he_him",
    calculate = function(_, card, context)
        local function eq(v)
            return v == card
        end

        local function proc()
            card.Roland_glass = true
            local tag = Tag(get_next_tag_key "Roland_glass")

            if tag.name == "Orbital Tag" then
                local hands = f(G.GAME.hands):where "visible":keys():table()
                tag.ability.orbital_hand = pseudorandom_element(hands, pseudoseed "Roland_glass")
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

        local hand_drawn = context.hand_drawn

        if type(hand_drawn) ~= "table" or not f(hand_drawn):any(eq) then
            return
        end

        q(function()
            card:shatter()
        end)

        SMODS.calculate_context {remove_playing_cards = true, removed = {card}}
        proc()
    end,
}
