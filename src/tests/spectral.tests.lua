if not Balatest then
    return
end

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
