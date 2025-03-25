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
    boss = {min = 1, max = 10},
    boss_colour = HEX("0291fb"),
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

local function disable()
    local orig = (getmetatable(G.GAME.probabilities) or {}).orig

    if orig then
        G.GAME.probabilities = orig
    end
end

local orig_pseudorandom = pseudorandom

---@diagnostic disable-next-line: lowercase-global
function pseudorandom(seed, min, max)
    return getmetatable(G.GAME.probabilities) and 0 / 0 or orig_pseudorandom(seed, min, max)
end

SMODS.Blind {
    key = "improbable",
    boss = {min = 1, max = 10},
    boss_colour = HEX("aaaaaa"),
    atlas = "blind",
    pos = {x = 0, y = 0},
    mult = 2,
    dollars = 5,
    defeat = disable,
    disable = disable,
    set_blind = function(_)
        local orig = G.GAME.probabilities

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
    end,
}
