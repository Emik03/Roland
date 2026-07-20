---@meta
---@alias Attributes "mult"|"chips"|"xmult"|"xchips"|"score"|"xscore"|"blindsize"|"xblindsize"|"balance"|"swap"|"retrigger"|"scaling"|"reset"|"suit"|"diamonds"|"hearts"|"spades"|"clubs"|"hand_type"|"rank"|"ace"|"two"|"three"|"four"|"five"|"six"|"seven"|"eight"|"nine"|"ten"|"jack"|"queen"|"king"|"face"|"economy"|"generation"|"destroy_card"|"hands"|"discard"|"hand_size"|"chance"|"joker_slot"|"mod_chance"|"copying"|"full_deck"|"passive"|"joker"|"tarot"|"planet"|"spectral"|"enhancements"|"seals"|"editions"|"tag"|"skip"|"modify_card"|"perma_bonus"|"prevents_death"|"boss_blind"|"reroll"|"on_sell"|"sell_value"|"food"|"space"|"bakery_double_sided"|"bakery_usable"|"bakery_werewolf"
---@type Card[]
CardArea.cards = CardArea.cards

--- @overload fun(tbl: SMODS.Joker): SMODS.GameObject
Bakery_API.Charm = Bakery_API.Charm

--- @generic T: SMODS.GameObject
--- @param obj T
--- @return T
function Bakery_API.credit(obj)
    error(obj)
end

---@type table
Balatest = Balatest

--- @type { constants?: { TEN: table }, new: (fun(self: self, arr?: number[], sign?: number, noNormalize?: boolean): table), pow: (fun(x: number, y: number): number) }
Big = Big

--- @type table?
CardSleeves = CardSleeves

--- @type table|fun(obj: SMODS.Back): SMODS.Back
CardSleeves.Sleeve = CardSleeves.Sleeve

--- @type {aliases: { [string]: [string] }}
Cryptid = Cryptid

--- @type fun(area: CardArea, ...: ...): Card
create_card_for_shop = create_card_for_shop

--- @type CardArea
G.Bakery_charm_area = G.Bakery_charm_area

--- @type boolean|table
G.Bakery_charm_area.cards[1].ability.extra = G.Bakery_charm_area.cards[1].ability.extra

---@type Card[]
G.playing_cards = G.playing_cards

---@type userdata|{getWidth: fun(self: self): number}
SMODS.Atlas.image_data = SMODS.Atlas.image_data

---@return Card
function copy_card(...)
    error(...)
end

SMODS.Mods.Roland.config = require "config"

---@type (fun(rem: number): number|table)[]
SMODS.Mods.Roland.harsh_ante_scaling = SMODS.Mods.Roland.harsh_ante_scaling

--- @type table
Talisman = Talisman

--- @type fun(obj: any): number
to_number = to_number

-- This exists to remove the @deprecated warning.
---Returns the elements from the given `list`. This function is equivalent to
---```lua
---    return list[i], list[i+1], ···, list[j]
---```
---
---
---[View documents](command:extension.lua.doc?["en-us/52/manual.html/pdf-unpack"])
---
---@generic T1, T2, T3, T4, T5, T6, T7, T8, T9, T10
---@param list {
--- [1]?: T1,
--- [2]?: T2,
--- [3]?: T3,
--- [4]?: T4,
--- [5]?: T5,
--- [6]?: T6,
--- [7]?: T7,
--- [8]?: T8,
--- [9]?: T9,
--- [10]?: T10,
---}
---@param i?   integer
---@param j?   integer
---@return T1, T2, T3, T4, T5, T6, T7, T8, T9, T10
---@nodiscard
function unpack(list, i, j)
    error {list, i, j}
end
