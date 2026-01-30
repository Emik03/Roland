if not Balatest then
    return
end

Balatest.TestPlay {
    category = {"joker", "escapey", "escape"},
    name = "escapey_none",
    jokers = {"j_Roland_escapey"},
    execute = function() end,
    assert = function()
        Balatest.assert(not G.jokers.cards[1].config.center:Bakery_can_use(G.jokers.cards[1]))
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "escape"},
    name = "escapey_one_consumable",
    jokers = {"j_Roland_escapey"},
    consumeables = {"c_strength"},
    execute = function()
        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(G.GAME.hands["High Card"].level, 2)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "escape"},
    name = "escapey_two_consumables",
    jokers = {"j_Roland_escapey"},
    consumeables = {"c_strength", "c_strength"},
    execute = function()
        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(G.GAME.hands["High Card"].level, 3)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "escape"},
    name = "escapey_one_tag",
    jokers = {"j_Roland_escapey"},
    no_auto_start = true,
    execute = function()
        Balatest.skip_blind("tag_investment")

        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(G.GAME.hands["High Card"].level, 2)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "escape"},
    name = "escapey_two_tags",
    jokers = {"j_Roland_escapey"},
    no_auto_start = true,
    execute = function()
        Balatest.skip_blind("tag_investment")
        Balatest.skip_blind("tag_investment")

        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(G.GAME.hands["High Card"].level, 3)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "escape"},
    name = "escapey_consumables_and_tags",
    jokers = {"j_Roland_escapey"},
    consumeables = {"c_strength"},
    no_auto_start = true,
    execute = function()
        Balatest.skip_blind("tag_investment")
        Balatest.skip_blind("tag_investment")

        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(G.GAME.hands["High Card"].level, 2)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "escape"},
    name = "escapey_partial_selected_consumables_and_tags",
    jokers = {"j_Roland_escapey"},
    consumeables = {"c_strength", "c_strength"},
    no_auto_start = true,
    execute = function()
        Balatest.skip_blind("tag_investment")
        Balatest.skip_blind("tag_investment")

        Balatest.q(function()
            G.consumeables:add_to_highlighted(G.consumeables.cards[1])
        end)

        Balatest.wait()

        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(G.GAME.hands["High Card"].level, 2)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "escape"},
    name = "escapey_full_selected_consumables_and_tags",
    jokers = {"j_Roland_escapey"},
    consumeables = {"c_strength"},
    no_auto_start = true,
    execute = function()
        Balatest.skip_blind("tag_investment")
        Balatest.skip_blind("tag_investment")

        Balatest.q(function()
            G.consumeables:add_to_highlighted(G.consumeables.cards[1])
        end)

        Balatest.wait()

        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(G.GAME.hands["High Card"].level, 3)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "fuse"},
    name = "escapey_fusion",
    jokers = {"j_Roland_escapey", "j_Roland_escapey"},
    execute = function()
        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(#G.jokers.cards, 1)
        Balatest.assert_eq(G.jokers.cards[1].sell_cost, 8)
        Balatest.assert_eq(G.jokers.cards[1].ability.extra.level_up_by, 2)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "fuse"},
    name = "escapey_consumable_takes_precedence",
    jokers = {"j_Roland_escapey", "j_Roland_escapey"},
    consumeables = {"c_strength"},
    execute = function()
        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(#G.jokers.cards, 2)
        Balatest.assert_eq(G.GAME.hands["High Card"].level, 2)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "fuse"},
    name = "escapey_tag_takes_precedence",
    jokers = {"j_Roland_escapey", "j_Roland_escapey"},
    no_auto_start = true,
    execute = function()
        Balatest.skip_blind("tag_investment")

        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(#G.jokers.cards, 2)
        Balatest.assert_eq(G.GAME.hands["High Card"].level, 2)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "fuse"},
    name = "escapey_fusion_takes_precedence",
    jokers = {"j_Roland_escapey", "j_Roland_escapey"},
    consumeables = {"c_strength"},
    execute = function()
        Balatest.q(function()
            G.consumeables:add_to_highlighted(G.consumeables.cards[1])
        end)

        Balatest.wait()

        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        Balatest.assert_eq(#G.jokers.cards, 1)
        Balatest.assert_eq(G.jokers.cards[1].sell_cost, 8)
        Balatest.assert_eq(G.jokers.cards[1].ability.extra.level_up_by, 2)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "fuse"},
    name = "escapey_scribe_fusion",
    jokers = {"j_Roland_escapey"},
    execute = function()
        if not G.P_CENTERS.c_Bakery_Scribe then
            sendWarnMessage("escapey_scribe_fusion cannot run without c_Bakery_Scribe, skipping test.")
            return
        end

        Balatest.q(function()
            local scribe = create_card(nil, G.consumeables, nil, nil, nil, nil, "c_Bakery_Scribe", "balatest")
            scribe:add_to_deck()
            G.consumeables:emplace(scribe)
        end)

        Balatest.wait()

        Balatest.q(function()
            G.jokers:add_to_highlighted(G.jokers.cards[1])
        end)

        Balatest.wait()
        Balatest.use(function() return G.consumeables.cards[1] end)

        Balatest.q(function()
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[1]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        if not G.P_CENTERS.c_Bakery_Scribe then
            return
        end

        Balatest.assert_eq(#G.jokers.cards, 1)
        Balatest.assert_eq(G.jokers.cards[1].sell_cost, 8)
        Balatest.assert_eq(G.jokers.cards[1].ability.extra.level_up_by, 1)
    end,
}

Balatest.TestPlay {
    category = {"joker", "escapey", "fuse"},
    name = "escapey_scribe_fusion_alt",
    jokers = {"j_Roland_escapey"},
    execute = function()
        if not G.P_CENTERS.c_Bakery_Scribe then
            sendWarnMessage("escapey_scribe_fusion_alt cannot run without c_Bakery_Scribe, skipping test.")
            return
        end

        Balatest.q(function()
            local scribe = create_card(nil, G.consumeables, nil, nil, nil, nil, "c_Bakery_Scribe", "balatest")
            scribe:add_to_deck()
            G.consumeables:emplace(scribe)
        end)

        Balatest.wait()

        Balatest.q(function()
            G.jokers:add_to_highlighted(G.jokers.cards[1])
        end)

        Balatest.wait()
        Balatest.use(function() return G.consumeables.cards[1] end)

        Balatest.q(function()
            G.jokers:add_to_highlighted(G.jokers.cards[2])
            G.FUNCS.Bakery_use_joker {config = {ref_table = G.jokers.cards[2]}}
        end)

        Balatest.wait()
    end,
    assert = function()
        if not G.P_CENTERS.c_Bakery_Scribe then
            return
        end

        Balatest.assert_eq(#G.jokers.cards, 1)
        Balatest.assert_eq(G.jokers.cards[1].sell_cost, 8)
        Balatest.assert_eq(G.jokers.cards[1].ability.extra.level_up_by, 1)
    end,
}

Balatest.TestPlay {
    category = {"joker", "martingale"},
    name = "martingale_oops",
    jokers = {"j_Roland_martingale", "j_oops"},
    execute = function()
        Balatest.play_hand {"2S"}
    end,
    assert = function()
        Balatest.assert_chips(7 * 2)
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
        Balatest.assert_chips(7 * math.pow(2, 32))
    end,
}
