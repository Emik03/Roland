local f, q = unpack(... or require "src.functional")

local function save(ret)
    q(function()
        save_run()
    end)

    return ret
end

local back = (function()
    local x = 0

    ---@param tbl SMODS.Back|{alt_apply?: fun(self: SMODS.Back|table, back: Back|table), alt_calculate?: fun(self: SMODS.Back|table, back: Back|table, context: CalcContext|table): table?, boolean?}
    return function(tbl)
        local key = tbl.key
        local apply = tbl.apply
        local calculate = tbl.calculate

        function tbl:apply(...)
            ---@diagnostic disable-next-line: redundant-return-value
            return apply and G.GAME.selected_sleeve ~= "sleeve_Roland_" .. key and save(apply(self, ...))
        end

        function tbl:calculate(...)
            ---@diagnostic disable-next-line: return-type-mismatch
            return calculate and G.GAME.selected_sleeve ~= "sleeve_Roland_" .. key and calculate(self, ...)
        end

        tbl.pos = {x = x, y = 0}
        tbl.atlas = "back"
        SMODS.Back(tbl)
        x = x + 1

        ---@diagnostic disable-next-line: undefined-global
        if not CardSleeves then
            return
        end

        ---@diagnostic disable-next-line: undefined-global
        CardSleeves.Sleeve {
            key = key,
            pos = tbl.pos,
            atlas = "void",
            config = tbl.config and f(tbl.config):into() or nil,
            loc_vars = function(self, ...)
                local ret = tbl.loc_vars and tbl.loc_vars(self, ...) or {}
                ret.key = self:is_alt() and self.key .. "_alt" or self.key
                return ret
            end,
            apply = function(self, ...)
                return (tbl.alt_apply and self:is_alt() and tbl.alt_apply or apply)(self, ...)
            end,
            calculate = function(self, ...)
                return (tbl.alt_calculate and self:is_alt() and tbl.alt_calculate or calculate)(self, ...)
            end,
            is_alt = function(self)
                return self.get_current_deck_key() == "b_Roland_" .. key
            end,
        }
    end
end)()

SMODS.Atlas {
    key = "back",
    path = "back.png",
    px = 71,
    py = 95,
}

back {
    key = "blossom",
    name = "Blossom",
    pronouns = "any_all",
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
    pronouns = "he_him",
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
