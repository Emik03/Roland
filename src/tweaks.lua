local _, q = unpack(... or require "lib.shared")

SMODS.Joker:take_ownership("joker", {cost = 1}, true)
local orig_can_highlight = CardArea.can_highlight
local orig_set_debuff = Card.set_debuff
local orig_highlight = Card.highlight
local orig_copy_card = copy_card

---@diagnostic disable-next-line: duplicate-set-field
function CardArea:can_highlight(...)
    if self ~= G.consumeables then
        return orig_can_highlight(self, ...)
    end

    --- Allows more flexibility when using the Escapey joker to delete specific consumables.
    self.config.highlighted_limit = 1 / 0
    return true
end

---@diagnostic disable-next-line: duplicate-set-field
function Card:set_debuff(...)
    if self.config and self.config.center_key == "m_wild" then
        self.debuff = false
    else
        orig_set_debuff(self, ...)
    end
end

---@diagnostic disable-next-line: duplicate-set-field
function Card:highlight(is_highlighted, ...)
    self.highlighted = is_highlighted

    if not G.CONTROLLER.HID.controller then
        return orig_highlight(self, is_highlighted, ...)
    end
end

---@diagnostic disable-next-line: lowercase-global
function copy_card(other, new_card, ...)
    local ret = orig_copy_card(other, new_card, ...)

    if new_card and new_card.edition and new_card.edition.key == "e_negative" then
        --- Fixes an issue where using 'c_death' will make negative
        --- cards do the inverse of what they're supposed to do.
        new_card.ability.card_limit = math.max(new_card.ability.card_limit, 1)
    end

    return ret
end

q(function()
    local orig_can_highlight_area = Bakery_API.can_highlight_area

    ---@diagnostic disable-next-line: duplicate-set-field
    function Bakery_API.can_highlight_area(area, ...)
        return area == G.consumeables or orig_can_highlight_area(area, ...)
    end
end)
