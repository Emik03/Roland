local f, q = (... or require "lib.shared")[1], (... or require "lib.shared")[2]

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
    pronouns = "any_all",
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
            tag:yep("X", G.C.RED, f.tru)
        end

        if tag.triggered or
            (tag.ability.amount or self.config.amount) <= 0 or
            ((context.card or {}).edition or {}).Roland_frozen or
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
    pronouns = "any_all",
    min_ante = 2,
    pos = {x = 1, y = 0},
    config = {invis_rounds = 0, total_rounds = 2},
    loc_vars = function(self, _, tag)
        tag.ability = tag.ability or f(self.config):table()
        local main_end = {}

        local _ = f((G.jokers or {}).cards or {}):map "edition":any "negative" and
            localize {type = "other", key = "remove_negative", nodes = main_end, vars = {}}

        return {
            vars = {
                tag.ability.total_rounds or self.config.total_rounds,
                tag.ability.invis_rounds or self.config.invis_rounds,
            },
            main_end = main_end[1],
        }
    end,
    increment = function(self)
        f(G.GAME.tags):where("key", "tag_Roland_invisible"):each(function(v)
            v.ability = v.ability or {}
            v.ability.invis_rounds = (v.ability.invis_rounds or self.config.invis_rounds) + 1
            v:juice_up()
        end)
    end,
    apply = function(self, tag)
        local modifiers = G.GAME.modifiers
        tag.ability = tag.ability or {}
        local ab = tag.ability
        ab.invis_rounds = ab.invis_rounds or self.config.invis_rounds
        ab.total_rounds = ab.total_rounds or self.config.total_rounds

        if tag.triggered or
            not next(G.jokers.cards) or
            ab.invis_rounds < ab.total_rounds or
            #G.jokers.cards + (modifiers.Roland_invisible or 0) >= G.jokers.config.card_limit then
            return
        end

        tag.triggered = true
        modifiers.Roland_invisible = (modifiers.Roland_invisible or 0) + 1

        tag:yep("!", G.C.GREY, function()
            local copied = pseudorandom_element(G.jokers.cards, pseudoseed "Roland_invisible")
            local copy = copy_card(copied, nil, nil, nil, copied.edition and copied.edition.negative)
            G.jokers:emplace(copy)
            copy:add_to_deck()
            modifiers.Roland_invisible = (modifiers.Roland_invisible or 0) - 1
            return true
        end)
    end,
}
