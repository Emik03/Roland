local voucher = (function()
    local x = 0

    ---@param tbl SMODS.Voucher|{attributes: Attributes[]}
    ---@return SMODS.Voucher
    return function(tbl)
        tbl.pos = {x = x, y = 0}
        tbl.atlas = "voucher"
        tbl.cost = 10
        x = x + 1
        return SMODS.Voucher(tbl)
    end
end)()

SMODS.Atlas {
    px = 71,
    py = 95,
    key = "voucher",
    path = "voucher.png",
}

voucher {
    key = "ceres",
    pronouns = "it_its",
    config = {hand_type = "Flush House"},
    attributes = {"planet", "passive", "hand_type", "space"},
    in_pool = function(self)
        return G.GAME.hands[self.config.hand_type].visible
    end,
}

voucher {
    key = "neptune",
    pronouns = "it_its",
    requires = {"v_Roland_ceres"},
    config = {hand_type = "Straight Flush"},
    attributes = {"planet", "passive", "hand_type", "space"},
}
