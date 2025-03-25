SMODS.Atlas {
    px = 34,
    py = 34,
    frames = 21,
    key = "blind",
    path = "blind.png",
    atlas_table = "ANIMATION_ATLAS",
}

local function disable_improbable()
    G.GAME.improbable = nil
    local orig = (getmetatable(G.GAME.probabilities) or {}).orig

    if orig then
        G.GAME.probabilities = orig
    end
end

if cry_prob then
    local orig_prob = cry_prob

    ---@diagnostic disable-next-line: lowercase-global
    cry_prob = function(owned, den, rigged)
        return G.GAME.improbable and 0 or orig_prob(owned, den, rigged)
    end
end

local orig_update = Game.update

---@diagnostic disable-next-line: duplicate-set-field
function Game:update(dt)
    orig_update(self, dt)
    local orig = G.GAME.probabilities

    if not G.GAME.improbable or not getmetatable(orig) then
        return
    end

    local mt = {
        orig = orig,
        __index = function (_, k)
            return k == "normal" and 0 or orig[k]
        end,
        __newindex = function (_, k, v)
            if k ~= "normal" or v ~= 0 then
                orig[k] = v
            end
        end,
    }

    local proxy = {}
    setmetatable(proxy, mt)
    G.GAME.probabilities = proxy
end

SMODS.Blind {
    key = "improbable",
    boss = {min = 1, max = 10},
    boss_colour = HEX("009966"),
    atlas = "blind",
    pos = {x = 0, y = 0},
    mult = 2,
    dollars = 5,
    defeat = disable_improbable,
    disable = disable_improbable,
    set_blind = function(_)
        G.GAME.improbable = true
    end,
}

SMODS.Blind	{
    key = "nimble",
    boss = {min = 1, max = 10},
    boss_colour = HEX("0291fb"),
    atlas = "blind",
    pos = {x = 0, y = 1},
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
                delay = 1,
                trigger = "after",
                func = force_hand,
            }))
        end
    end,
    set_blind = function(self)
        self.disabled = false
    end,
}
