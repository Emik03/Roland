local _, q = unpack(... or require "lib.shared")

SMODS.Atlas {
    px = 34,
    py = 34,
    key = "tag",
    path = "tag.png",
}

SMODS.Tag {
    key = "invisible",
    atlas = "tag",
    min_ante = 2,
    pos = {x = 0, y = 0},
    apply = function(_, tag)
        local modifiers = G.GAME.modifiers

        if tag.triggered or
            not next(G.jokers.cards) or
            #G.jokers.cards + (modifiers.Roland_invisible or 0) >= G.jokers.config.card_limit then
            return
        end

        tag.triggered = true
        modifiers.Roland_invisible = (modifiers.Roland_invisible or 0) + 1

        tag:yep(localize "k_duplicated_ex", G.C.GREY, function()
            local copied = pseudorandom_element(G.jokers.cards, pseudoseed "Roland_invisible")
            local copy = copy_card(copied)
            G.jokers:emplace(copy)
            copy:add_to_deck()
            modifiers.Roland_invisible = (modifiers.Roland_invisible or 0) - 1
            return true
        end)
    end,
}
