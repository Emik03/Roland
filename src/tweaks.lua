local f, q = unpack(... or require "lib.shared")

SMODS.Joker:take_ownership("joker", {cost = 1}, true)
local orig_can_highlight = CardArea.can_highlight
local orig_set_debuff = Card.set_debuff
local orig_highlight = Card.highlight
local orig_copy_card = copy_card

function CardArea:can_highlight(...)
    if self ~= G.consumeables or not SMODS.Mods.Roland.config.no_highlight_limit then
        return orig_can_highlight(self, ...)
    end

    --- Allows more flexibility when using the Escapey joker to delete specific consumables.
    self.config.highlighted_limit = 1 / 0
    return true
end

function Card:set_debuff(...)
    if self.config and
        self.config.center_key == "m_wild" and
        SMODS.Mods.Roland.config.no_wild_debuff then
        self.debuff = false
    else
        orig_set_debuff(self, ...)
    end
end

function Card:highlight(is_highlighted, ...)
    self.highlighted = is_highlighted

    if not G.CONTROLLER.HID.controller or not SMODS.Mods.Roland.config.no_highlight_limit then
        return orig_highlight(self, is_highlighted, ...)
    end
end

local orig_use_consumeable = Card.use_consumeable

function Card:use_consumeable(area, copier, ...)
    local seal_spectrals = {["Deja Vu"] = true, Medium = true, Talisman = true, Trance = true}

    if not seal_spectrals[self.ability.name] then
        return orig_use_consumeable(self, area, copier, ...)
    end

    f(Bakery_API.get_highlighted()):each(function(v)
        q(function()
            play_sound "tarot1"
            local card = (copier or self)
            card:juice_up(0.3, 0.5)
        end)

        q {
            delay = 0.1,
            trigger = "after",
            func = function()
                v:set_seal(self.ability.extra, nil, true)
            end,
        }
    end)

    q {
        delay = 0.7,
        trigger = "after",
        func = function()
            Bakery_API.unhighlight_all()
        end,
    }
end

function copy_card(other, new_card, ...)
    local ret = orig_copy_card(other, new_card, ...)

    if new_card and new_card.edition and new_card.edition.key == "e_negative" then
        --- Fixes an issue where using 'c_death' will make negative
        --- cards do the inverse of what they're supposed to do.
        local ability = new_card.ability
        ability.card_limit = math.max(ability.card_limit, 1)
    end

    return ret
end

q(function()
    local orig_can_highlight_area = Bakery_API.can_highlight_area

    function Bakery_API.can_highlight_area(area, ...)
        return (area == G.consumeables and
                SMODS.Mods.Roland.config.no_highlight_limit) or
            orig_can_highlight_area(area, ...)
    end
end)

local orig_create_card_for_shop = create_card_for_shop

function create_card_for_shop(...)
    ---@type Card
    local ret = orig_create_card_for_shop(...)

    if not SMODS.Mods.Roland.config.illusion_seal or
        not G.GAME.used_vouchers.v_illusion or
        not ({Default = true, Enhanced = true})[(((ret or {}).config or {}).center or {}).set] or
        pseudorandom(pseudoseed "Roland_illusion") <= 0.8 then
        return ret
    end

    local seal = SMODS.poll_seal {
        type_key = "Roland_illusion_seal",
        guaranteed = true,
    }

    ret:set_seal(seal, true, true)
    return ret
end

local hundred, orig_get_blind_amount = f().const(100), get_blind_amount

---@type fun(x: table|number): number
local function blind(offset)
    return (_G["to_number"] or f().id)(orig_get_blind_amount(offset))
end

function get_blind_amount(ante, ...)
    if ante <= 38 or not _G["Talisman"] or not SMODS.Mods.Roland.config.harsh_ante_scaling then
        return orig_get_blind_amount(ante, ...)
    end

    if ante >= 100 then
        return 1 / 0
    end

    --- @type { new: fun(self: self, arr?: number[], sign?: number, noNormalize?: boolean): table }
    local big = _G["Big"]

    if ante >= 91 then
        local offset = ante - 91
        local table = f(blind(offset)):map(hundred):table()
        return big:new(table)
    end

    if ante >= 63 then
        local offset = ante - 63
        local table = f((offset / 4) + 1):map(hundred):concat {blind((offset % 4) * 8)}:table()
        return big:new(table)
    end

    if ante >= 42 then
        local offset = ante - 42
        return big:new {blind((offset % 3) * 8), math.floor(offset / 3) + 2}
    end

    return big:new {ante - 36, 2}
end
