local f, q = unpack(... or require "src.functional")

local function save(ret)
    q(function()
        save_run()
    end)

    return ret
end

local function back(b)
    local key = b.key
    local apply = b.apply
    local calculate = b.calculate

    function b:apply(...)
        return apply and G.GAME.selected_sleeve ~= "sleeve_Roland_" .. key and save(apply(self, ...))
    end

    function b:calculate(...)
        return calculate and G.GAME.selected_sleeve ~= "sleeve_Roland_" .. key and calculate(self, ...)
    end

    b.atlas = "void"
    SMODS.Back(b)

    ---@diagnostic disable-next-line: undefined-global
    if not CardSleeves then
        return
    end

    ---@diagnostic disable-next-line: undefined-global
    CardSleeves.Sleeve {
        key = key,
        pos = b.pos,
        atlas = "void",
        config = b.config and f(b.config):into() or nil,
        loc_vars = function(self, ...)
            local ret = b.loc_vars and b.loc_vars(self, ...) or {}
            ret.key = self:is_alt() and self.key .. "_alt" or self.key
            return ret
        end,
        apply = function(self, ...)
            return (b.alt_apply and self:is_alt() and b.alt_apply or apply)(self, ...)
        end,
        calculate = function(self, ...)
            return (b.alt_calculate and self:is_alt() and b.alt_calculate or calculate)(self, ...)
        end,
        is_alt = function(self)
            return self.get_current_deck_key() == "b_Roland_" .. key
        end,
    }
end

-- SMODS.Atlas {
--     key = "back",
--     path = "back.png",
--     px = 71,
--     py = 95,
-- }
back {
    key = "blossom",
    name = "Blossom",
    pos = {x = 0, y = 0},
    config = {extra = {times = 2}},
    loc_vars = function(self, _, _)
        return {vars = {self.config.extra.times}}
    end,
    apply = function(_, _)
        G.GAME.modifiers.Roland_blossom_deck = true
    end,
    calculate = function(self, _, context)
        if not context.setting_blind then
            return
        end

        local blinds = G.GAME.round_resets.blind_states

        if blinds.Small ~= "Current" and blinds.Big ~= "Current" then
            return
        end

        local count = self:is_alt() and G.GAME.round_resets.ante or self.config.extra.times

        for _ = 1, count do
            G.GAME.blind:disable()

            q {
                delay = 0.4,
                func = function()
                    G.GAME.blind:wiggle()
                    play_sound "timpani"
                end,
            }
        end
    end,
}

back {
    key = "go",
    name = "Go",
    pos = {x = 0, y = 0},
    config = {extra = {times = 1, alt_times = 5}},
    loc_vars = function(self, _, _)
        return {vars = {self.config.extra.alt_times - self.config.extra.times}}
    end,
    apply = function(self)
        q(function()
            local count = self:is_alt() and self.config.extra.alt_times or self.config.extra.times

            for _ = 1, count do
                local c = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_credit_card", "Roland_go")
                c:add_to_deck()
                c:start_materialize()
                G.jokers:emplace(c)
            end
        end)
    end,
    calculate = function(_, _, context)
        local _ = context.starting_shop and ease_dollars(-G.GAME.dollars)
    end,
}
