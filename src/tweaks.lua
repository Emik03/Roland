SMODS.Joker:take_ownership("joker", {cost = 1}, true)
local orig_set_debuff = Card.set_debuff

---@diagnostic disable-next-line: duplicate-set-field
function Card:set_debuff(...)
    if self.config and self.config.center_key == "m_wild" then
        self.debuff = false
    else
        orig_set_debuff(self, ...)
    end
end
