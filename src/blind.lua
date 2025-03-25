SMODS.Atlas {
    px = 34,
    py = 34,
    frames = 21,
    key = "blind",
    path = "blind.png",
    atlas_table = "ANIMATION_ATLAS",
}

SMODS.Blind	{
    key = "nimble",
    boss = {min = 1, max = 10, no_orb = true, hardcore = true},
    boss_colour = HEX("8be9fd"),
    atlas = "blind",
    pos = {x = 0, y = 0},
    mult = 2,
    dollars = 5,
    defeat = function(self)
        self.disabled = false
    end,
    disable = function(self)
        self.disabled = true
    end,
    drawn_to_hand = function(self)
        local function force_hand()
            for i, v in ipairs(G.hand.cards) do
                if i > 5 then
                    break
                end

                G.hand:add_to_highlighted(v, true)
            end

            G.FUNCS.play_cards_from_highlighted(nil)
            return true
        end

        if not self.disabled then
            self.disabled = true
            G.E_MANAGER:add_event(Event({
                delay = 0.1,
                trigger = "after",
                func = force_hand,
            }))
        end
    end,
    set_blind = function(self)
        self.disabled = false
    end,
}
