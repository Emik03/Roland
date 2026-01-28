if not Balatest then
    return
end

Balatest.TestPlay {
    category = {"blind", "improbable"},
    name = "improbable",
    blind = "bl_Roland_improbable",
    jokers = {"j_oops", "j_oops", "j_oops"},
    deck = {cards = {{s = "S", r = "2", e = "m_lucky"}, {s = "S", r = "3"}}},
    execute = function()
        Balatest.play_hand {"2S"}
    end,
    assert = function()
        Balatest.assert_chips(7)
    end,
}

Balatest.TestPlay {
    category = {"blind", "improbable"},
    name = "improbable_not_leaky",
    blind = "bl_Roland_improbable",
    jokers = {"j_oops", "j_oops", "j_oops"},
    deck = {cards = {{s = "S", r = "2", e = "m_lucky"}, {s = "S", r = "3"}}},
    execute = function()
        Balatest.play_hand {"2S"}
        Balatest.next_round("bl_small")
        Balatest.play_hand {"2S"}
    end,
    assert = function()
        Balatest.assert_chips(7 * 21)
    end,
}

Balatest.TestPlay {
    category = {"blind", "nimble"},
    name = "nimble",
    blind = "bl_Roland_nimble",
    deck = {cards = {
        {s = "S", r = "2"},
        {s = "S", r = "2"},
        {s = "S", r = "2"},
        {s = "S", r = "2"},
        {s = "S", r = "2"},
    }},
    no_auto_start = true,
    execute = function()
        Balatest.q(function()
            G.FUNCS.select_blind {
                config = {ref_table = G.P_BLINDS[Balatest.current_test_object.blind]},
                UIBox = {get_UIE_by_ID = function() end},
            }
        end)

        Balatest.wait_for_input()
        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_chips(2720)
    end,
}
