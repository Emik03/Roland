if not Balatest then
    return
end

Balatest.TestPlay {
    category = {"spectral", "afterimage"},
    name = "afterimage",
    consumeables = {"c_Roland_afterimage"},
    deck = {cards = {{s = "S", r = "2"}}},
    execute = function()
        Balatest.highlight({"2S"})
        Balatest.use(G.consumeables.cards[1])
        Balatest.end_round()
    end,
    assert = function()
        Balatest.assert_eq(G.hand.config.card_limit, 51)
        Balatest.assert(G.deck.cards[1].edition.negative)
    end,
}

Balatest.TestPlay {
    category = {"spectral", "void"},
    name = "spectral",
    consumeables = {"c_Roland_void"},
    execute = function()
        Balatest.end_round()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        Balatest.assert_eq(#G.deck.cards, 0)
        Balatest.assert_eq(#G.consumeables.cards, 2)
    end,
}
