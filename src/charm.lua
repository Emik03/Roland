local _, q = unpack(... or require "src.functional")

Bakery_API.Charm {
    key = "tags",
    atlas = "void",
    pos = {x = 0, y = 0},
    calculate = function(_, _, context)
        local _ = context.skip_blind and q(function()
            G.round_eval = G.round_eval and G.round_eval:remove()
            G.blind_select = G.blind_select and G.blind_select:remove()
            G.blind_prompt_box = G.blind_prompt_box and G.blind_prompt_box:remove()
            G.GAME.current_round.jokers_purchased = 0
            G.STATE = G.STATES.SHOP
            G.GAME.shop_free = nil
            G.GAME.shop_d6ed = nil
            G.STATE_COMPLETE = false
        end)
    end,
}
