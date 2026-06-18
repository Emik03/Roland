local f = (... or require "lib.shared")[1]

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
        Balatest.next_round "bl_small"
        Balatest.play_hand {"2S"}
    end,
    assert = function()
        Balatest.assert_chips(7 * 21)
    end,
}

Balatest.TestPlay {
    category = {"blind", "improbable"},
    name = "improbable_disabled",
    blind = "bl_Roland_improbable",
    jokers = {"j_oops", "j_oops", "j_oops", "j_chicot"},
    deck = {cards = {{s = "S", r = "2", e = "m_lucky"}, {s = "S", r = "3"}}},
    execute = function()
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

Balatest.TestPlay {
    category = {"blind", "nimble"},
    name = "nimble_disabled",
    blind = "bl_Roland_nimble",
    jokers = {"j_chicot"},
    execute = function()
        Balatest.wait_for_input()
    end,
    assert = function()
        Balatest.assert_chips(0)
    end,
}

Balatest.TestPlay {
    category = {"blind", "divide"},
    name = "divide",
    blind = "bl_Roland_divide",
    execute = function()
        Balatest.wait_for_input()
    end,
    assert = function()
        Balatest.assert_eq(#G.discard.cards, 26)
    end,
}

Balatest.TestPlay {
    category = {"blind", "divide"},
    name = "divide_odd",
    blind = "bl_Roland_divide",
    deck = {cards = {
        {s = "S", r = "2"},
        {s = "S", r = "2"},
        {s = "S", r = "2"},
        {s = "S", r = "2"},
        {s = "S", r = "2"},
    }},
    execute = function()
        Balatest.wait_for_input()
    end,
    assert = function()
        Balatest.assert_eq(#G.discard.cards, 2)
    end,
}

Balatest.TestPlay {
    category = {"blind", "divide"},
    name = "divide_disabled",
    blind = "bl_Roland_divide",
    jokers = {"j_chicot"},
    execute = function()
        Balatest.wait_for_input()
    end,
    assert = function()
        Balatest.assert_eq(#G.discard.cards, 0)
    end,
}

Balatest.TestPlay {
    category = {"blind", "tranquilizer"},
    name = "tranquilizer",
    blind = "bl_Roland_tranquilizer",
    execute = function()
        Balatest.wait_for_input()
    end,
    assert = function()
        f(G.hand.cards):each(function(v, k)
            local message = v.debuff and
                "Card " .. k .. " should not be debuffed" or
                "Card " .. k .. " should be debuffed"

            Balatest.assert(v.debuff == (v.base.value == "Ace"), message)
        end)
    end,
}

Balatest.TestPlay {
    category = {"blind", "tranquilizer"},
    name = "tranquilizer_change",
    blind = "bl_Roland_tranquilizer",
    jokers = {"j_dna", "j_dna"},
    deck = {cards = {
        {s = "S", r = "2"},
        {s = "S", r = "3"},
        {s = "S", r = "3"},
    }},
    execute = function()
        Balatest.wait_for_input()
        Balatest.play_hand {"2S"}
    end,
    assert = function()
        f(G.hand.cards):each(function(v, k)
            local message = v.debuff and
                "Card " .. k .. " should not be debuffed" or
                "Card " .. k .. " should be debuffed"

            Balatest.assert(v.debuff == (v.base.value == "2"), message)
        end)
    end,
}

Balatest.TestPlay {
    category = {"blind", "tranquilizer"},
    name = "tranquilizer_disabled",
    blind = "bl_Roland_tranquilizer",
    jokers = {"j_chicot"},
    execute = function()
        Balatest.wait_for_input()
    end,
    assert = function()
        f(G.hand.cards):each(function(v, k)
            Balatest.assert(not v.debuff, "Card " .. k .. " should not be debuffed")
        end)
    end,
}

Balatest.TestPlay {
    category = {"blind", "xerox"},
    name = "xerox",
    blind = "bl_Roland_xerox",
    execute = function()
        Balatest.discard {"2S"}
    end,
    assert = function()
        Balatest.assert_eq(#G.playing_cards, 53)
    end,
}

Balatest.TestPlay {
    category = {"blind", "xerox"},
    name = "xerox_disabled",
    blind = "bl_Roland_xerox",
    jokers = {"j_chicot"},
    execute = function()
        Balatest.discard {"2S"}
    end,
    assert = function()
        Balatest.assert_eq(#G.playing_cards, 52)
    end,
}
