local f, q = unpack(... or require "lib.shared")

SMODS.Atlas {
    px = 34,
    py = 34,
    key = "tag",
    path = "tag.png",
}

local function apply_frozen(tag, context)
    return function()
        q {
            delay = 0.4,
            trigger = "after",
            func = function()
                play_sound "tarot1"
                tag:juice_up(0.3, 0.5)
            end,
        }

        q {
            delay = 0.15,
            trigger = "after",
            func = function()
                context.card:flip()
                play_sound("card1", 0.85)
                context.card:juice_up(0.3, 0.3)
            end,
        }

        delay(0.2)

        q {
            delay = 0.1,
            trigger = "after",
            func = function()
                context.card:set_edition {Roland_frozen = true}
            end,
        }

        q {
            delay = 0.15,
            trigger = "after",
            func = function()
                context.card:flip()
                play_sound("tarot2", 0.85, 0.6)
                context.card:juice_up(0.3, 0.3)
            end,
        }

        delay(0.1)
    end
end

SMODS.Tag {
    key = "freeze",
    atlas = "tag",
    min_ante = 1,
    pos = {x = 0, y = 0},
    config = {amount = 5},
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.e_Roland_frozen
        tag.ability = tag.ability or {}
        return {vars = {tag.ability.amount or self.config.amount}}
    end,
    apply = function(self, tag, context)
        tag.ability = tag.ability or {}

        if not tag.triggered and context.type == "Bakery_play_hand_late" and tag.ability.amount == 0 then
            tag.triggered = true
            tag:yep("X", G.C.RED, f().tru)
        end

        if tag.triggered or
            (tag.ability.amount or self.config.amount) <= 0 or
            context.type ~= "Bakery_score_card" then
            return
        end

        tag.ability.amount = (tag.ability.amount or self.config.amount) - 1
        return {func = apply_frozen(tag, context)}
    end,
}

SMODS.Tag {
    key = "invisible",
    atlas = "tag",
    min_ante = 2,
    pos = {x = 1, y = 0},
    apply = function(_, tag)
        local modifiers = G.GAME.modifiers

        if tag.triggered or
            not next(G.jokers.cards) or
            #G.jokers.cards + (modifiers.Roland_invisible or 0) >= G.jokers.config.card_limit then
            return
        end

        tag.triggered = true
        modifiers.Roland_invisible = (modifiers.Roland_invisible or 0) + 1

        tag:yep("!", G.C.GREY, function()
            local copied = pseudorandom_element(G.jokers.cards, pseudoseed "Roland_invisible")
            local copy = copy_card(copied)
            G.jokers:emplace(copy)
            copy:add_to_deck()
            modifiers.Roland_invisible = (modifiers.Roland_invisible or 0) - 1
            return true
        end)
    end,
}
