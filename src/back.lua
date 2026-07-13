local f, q = (... or require "lib.shared")[1], (... or require "lib.shared")[2]

local function save(ret)
    q(save_run)
    return ret
end

local back = (function()
    local x = 0

    ---@param tbl SMODS.Back|{attributes?: Attributes[], is_alt: (fun(self: self): boolean), alt_apply?: fun(self: SMODS.Back|table, back: Back|table), alt_calculate?: fun(self: SMODS.Back|table, back: Back|table, context: CalcContext|table): table?, boolean?}
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
    config = {extra = {alt_times = 9, times = 3}},
    attributes = {"passive", "boss_blind"},
    loc_vars = function(self, _, _)
        return {vars = {self.config.extra.alt_times}}
    end,
    apply = function(_, _)
        G.GAME.modifiers.Roland_blossom_deck = true
    end,
    calculate = function(self, b, context)
        if not context.forcetrigger and not context.setting_blind then
            return
        end

        local blinds = G.GAME.round_resets.blind_states

        if not context.forcetrigger and
            blinds.Small ~= "Current" and
            blinds.Big ~= "Current" then
            return
        end

        local function debuff(times)
            return function()
                if times <= 0 then
                    return
                end

                G.GAME.blind:disable()
                SMODS.calculate_effect({message = localize "ph_boss_disabled"}, b)
                G.GAME.blind:wiggle()
                play_sound "timpani"
                q {func = debuff(times - 1)}
            end
        end

        local times = self:is_alt() and
            G.GAME.round_resets.ante * self.config.extra.alt_times or
            self.config.extra.times

        debuff(times)()
    end,
}

back {
    key = "swapper",
    pronouns = "he_him",
    attributes = {"passive", "editions", "sell_value"},
    apply = function(self)
        local modifiers = G.GAME.modifiers
        modifiers.Roland_swapper_deck = true
        modifiers.Roland_alt_swapper_deck = modifiers.Roland_alt_swapper_deck or self:is_alt()
    end,
    calculate = f.noop,
}

back {
    key = "dropship",
    pronouns = "he_him",
    attributes = {"passive", "generation"},
    unlocked = false,
    discovered = false,
    check_for_unlock = function(_, args)
        return args ~= "Bakery_nothing" and
            G.jokers and
            next((G.jokers or {}).cards) and
            not not f(G.jokers.cards):map "ability":all "perishable"
    end,
    apply = function(self)
        G.GAME.modifiers.Roland_dropship = true
        G.GAME.modifiers.Roland_dropship_alt = self:is_alt()
    end,
    calculate = f.noop,
}

local swapper = {Spectral = "Tarot", Tarot = "Spectral"}
local orig_create_card = create_card

local function create_dropshipped_card(_type, ...)
    local ret = orig_create_card(_type, ...)
    local ok = _type == "Joker" and ret.ability

    if ok and G.GAME.modifiers.Roland_dropship_alt then
        ret:set_edition({negative = true}, true)
        ret.ability.perish_tally = 1 / 0
    end

    if ok and G.GAME.modifiers.Roland_dropship then
        ret.ability.perishable = true
        ret.cost, ret.sell_cost = 0, 0
        ret.ability.perish_tally = G.GAME.modifiers.Roland_dropship_alt and 1 / 0 or 5
    end

    return ret
end

function create_card(_type, ...)
    if not G.GAME.modifiers.Roland_swapper_deck then
        return create_dropshipped_card(_type, ...)
    end

    if not G.GAME.modifiers.Roland_alt_swapper_deck then
        return create_dropshipped_card(swapper[_type] or _type, ...)
    end

    local type = f(SMODS.ConsumableTypes):keys():where(function(v)
        return v ~= _type
    end):table()

    local has_type = SMODS.ConsumableTypes[_type]
    return create_dropshipped_card(
        has_type and pseudorandom_element(type, pseudoseed "Roland_alt_swapper_deck") or _type, ...)
end

local function redeem(key, fast)
    if fast then
        G.GAME.used_vouchers[key] = true
    end

    q {
        delay = 1,
        func = function()
            local voucher = SMODS.create_card {key = key, set = "Voucher"}
            voucher.cost = 0
            voucher.T.x = (fast and pseudorandom(pseudoseed "Roland_wish_deck") + 0.5 or 1) * 9
            voucher.T.y = (fast and pseudorandom(pseudoseed "Roland_wish_deck") + 0.5 or 1) * 4.25
            voucher:start_materialize()

            q {
                delay = 1,
                func = function()
                    if fast then
                        play_sound "card1"
                        voucher:apply_to_run()
                        voucher:juice_up(0.3, 0.5)
                    else
                        local state = G.STATE
                        voucher:redeem()
                        G.STATE = state
                    end

                    q {
                        delay = 1,
                        func = function()
                            voucher:start_dissolve()
                        end,
                    }
                end,
            }
        end,
    }
end

back {
    key = "wish",
    pronouns = "he_him",
    attributes = {"passive", "generation"},
    unlocked = false,
    discovered = false,
    check_for_unlock = function(_, args)
        return args ~= "Bakery_nothing" and f(G.P_CENTER_POOLS.Voucher):all "discovered"
    end,
    apply = function(self)
        G.GAME.modifiers.Roland_no_voucher = true
        local _ = self:is_alt() and f(G.P_CENTER_POOLS.Voucher):map "key":each(redeem)
    end,
    calculate = function(_, _, context)
        local _ = (context.forcetrigger or
                context.blind_defeated and
                not context.repetition and
                not G.GAME.blind.boss) and
            f(G.P_CENTER_POOLS.Voucher)
            :map "key"
            :where(f.index_into(G.GAME.used_vouchers), false)
            :any() and
            redeem(get_next_voucher_key())
    end,
}

local orig_add_voucher_to_shop = SMODS.add_voucher_to_shop

function SMODS.add_voucher_to_shop(...)
    if not G.GAME.modifiers.Roland_no_voucher then
        return orig_add_voucher_to_shop(...)
    end
end
