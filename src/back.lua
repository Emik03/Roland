local _, q = unpack(... or require "src.functional")

-- SMODS.Atlas {
--     key = "back",
--     path = "back.png",
--     px = 71,
--     py = 95,
-- }
SMODS.Back {
    key = "blossom",
    name = "Blossom",
    atlas = "void",
    pos = {x = 0, y = 0},
    config = {extra = {times = 2}},
    loc_vars = function(self, _, _)
        return {vars = {self.config.extra.times}}
    end,
    apply = function(_, _)
        G.GAME.modifiers.Roland_blossom_deck = true
        save_run()
    end,
    calculate = function(self, _, context)
        local function disable()
            for _ = 1, self.config.extra.times do
                G.GAME.blind:disable()
            end

            play_sound("timpani")
            return true
        end

        if not context.setting_blind then
            return
        end

        local blinds = G.GAME.round_resets.blind_states

        if blinds.Small == "Current" or blinds.Big == "Current" then
            q(disable)
        end
    end,
}

SMODS.Back {
    key = "go",
    name = "Go",
    atlas = "void",
    pos = {x = 0, y = 0},
    apply = function(_, _)
        local function add_credit_card()
            local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_credit_card", "Roland_go")
            card:add_to_deck()
            card:start_materialize()
            G.jokers:emplace(card)
            save_run()
            return true
        end

        q(add_credit_card)
    end,
    calculate = function(_, _, context)
        if context.starting_shop then
            ease_dollars(-G.GAME.dollars)
        end
    end,
}
