local f, q = (... or require "lib.shared")[1], (... or require "lib.shared")[2]

local function save(ret)
    q(save_run)
    return ret
end

local back = (function()
    local x = 0

    ---@param tbl SMODS.Back|{is_alt: (fun(self: self): boolean), alt_apply?: fun(self: SMODS.Back|table, back: Back|table), alt_calculate?: fun(self: SMODS.Back|table, back: Back|table, context: CalcContext|table): table?, boolean?}
    return function(tbl)
        local key = tbl.key
        local apply = tbl.apply
        local calculate = tbl.calculate

        function tbl:apply(...)
            local _ = apply and G.GAME.selected_sleeve ~= "sleeve_Roland_" .. key and save(apply(self, ...))
        end

        function tbl:calculate(...)
            return (calculate and G.GAME.selected_sleeve ~= "sleeve_Roland_" .. key) and calculate(self, ...) or nil
        end

        tbl.pos = {x = x, y = 0}
        tbl.is_alt = f.fals
        tbl.atlas = "back"
        x = x + 1
        local back = q(SMODS.Back(tbl))

        local _ = CardSleeves and CardSleeves.Sleeve {
            key = key,
            pos = tbl.pos,
            atlas = "sleeve",
            config = tbl.config and f(tbl.config):table() or nil,
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

        return back
    end
end)()

SMODS.Atlas {
    key = "back",
    path = "back.png",
    px = 71,
    py = 95,
}

local _ = CardSleeves and SMODS.Atlas {
    key = "sleeve",
    path = "sleeve.png",
    px = 73,
    py = 95,
}

back {
    key = "blossom",
    pronouns = "any_all",
    config = {extra = {alt_times = 4, times = 2}},
    attributes = {"boss_blind"},
    loc_vars = function(self, _, _)
        return {vars = {self.config.extra.alt_times}}
    end,
    apply = function(_, _)
        G.GAME.modifiers.Roland_blossom_deck = true
    end,
    calculate = function(self, card, context)
        if not context.setting_blind then
            return
        end

        local blinds = G.GAME.round_resets.blind_states

        if blinds.Small ~= "Current" and blinds.Big ~= "Current" then
            return
        end

        local count = self:is_alt() and
            G.GAME.round_resets.ante * self.config.extra.alt_times or
            self.config.extra.times

        f(count):each(function(i)
            local _ = i == 1 and G.GAME.blind:disable()

            q {
                delay = 0.4,
                func = function()
                    local _ = i ~= 1 and G.GAME.blind:disable()
                    SMODS.calculate_effect({message = localize "ph_boss_disabled"}, card)
                    G.GAME.blind:wiggle()
                    play_sound "timpani"
                end,
            }
        end)
    end,
}

back {
    key = "swapper",
    pronouns = "he_him",
    attributes = {"spectral", "tarot"},
    apply = function(self)
        local modifiers = G.GAME.modifiers
        modifiers.Roland_swapper_deck = true
        modifiers.Roland_alt_swapper_deck = modifiers.Roland_alt_swapper_deck or self:is_alt()
    end,
    calculate = f.noop,
}

local swapper = {Spectral = "Tarot", Tarot = "Spectral"}
local orig_create_card = create_card

function create_card(_type, ...)
    if not G.GAME.modifiers.Roland_swapper_deck then
        return orig_create_card(_type, ...)
    end

    if not G.GAME.modifiers.Roland_alt_swapper_deck then
        return orig_create_card(swapper[_type] or _type, ...)
    end

    local type = f(SMODS.ConsumableTypes):keys():where(function(v)
        return v ~= _type
    end):table()

    local has_type = SMODS.ConsumableTypes[_type]
    return orig_create_card(has_type and pseudorandom_element(type, pseudoseed "Roland_alt_swapper_deck") or _type, ...)
end
