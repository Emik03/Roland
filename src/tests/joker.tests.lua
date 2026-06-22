if not Balatest then
    return
end

Balatest.TestPlay {
    category = {"joker", "martingale"},
    name = "martingale_oops",
    jokers = {"j_Roland_martingale", "j_oops"},
    execute = function()
        Balatest.play_hand {"2S"}
    end,
    assert = function()
        Balatest.assert_chips(7)
    end,
}

Balatest.TestPlay {
    category = {"joker", "martingale"},
    name = "martingale_improbable",
    blind = "bl_Roland_improbable",
    jokers = {"j_Roland_martingale"},
    execute = function()
        Balatest.play_hand {"2S"}
    end,
    assert = function()
        Balatest.assert_chips(1 / 0)
    end,
}
