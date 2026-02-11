local _, q = unpack(... or require "src.functional")

SMODS.Joker:take_ownership("joker", {cost = 1}, true)
local orig_can_highlight = CardArea.can_highlight
local orig_set_debuff = Card.set_debuff
local orig_highlight = Card.highlight

---@diagnostic disable-next-line: duplicate-set-field
function CardArea:can_highlight(...)
    if self ~= G.consumeables then
        return orig_can_highlight(self, ...)
    end

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

q(function()
    local orig_can_highlight_area = Bakery_API.can_highlight_area

    ---@diagnostic disable-next-line: duplicate-set-field
    function Bakery_API.can_highlight_area(area, ...)
        return area == G.consumeables or orig_can_highlight_area(area, ...)
    end
end)
