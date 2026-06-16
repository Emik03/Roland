---@author Emik
---@copyright (c) 2026 Emik
---@license MPL-2.0
---@version 1.0.0
---
---@alias FFrom (fun<K, V>(iter: table<K, V>, fpairs?: fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K?, V?)): F | { [K]: V })|(fun(iter: number, fpairs?: number, step?: number): F | { [number]: number })|(fun<V>(iter: string): (fun(table: { [string]: V }): V))|(fun<V>(iter: string): (fun(table: { [string]: V }): V))|(fun<K, V>(iter: fun(): K, V): F | { [K]: V })|(fun(iter: false): fun(): false)|(fun(iter: true): fun(): true)|(fun(iter: nil): F)
---@class F
local f = {}

if not f then
    ---@generic I, O
    ---@param first fun(v: I): O
    ---@return fun(v: I): O
    function f.chain(first)
        error {first}
    end

    ---@generic I, T, O
    ---@param first fun(v: I): T
    ---@param second fun(v: T): O
    ---@return fun(v: I): O
    function f.chain(first, second)
        error {first, second}
    end

    ---@generic I, T1, T2, O
    ---@param first fun(v: I): T1
    ---@param second fun(v: T1): T2
    ---@param third fun(v: T2): O
    ---@return fun(v: I): O
    function f.chain(first, second, third)
        error {first, second, third}
    end

    ---@generic I, T1, T2, T3, O
    ---@param first fun(v: I): T1
    ---@param second fun(v: T1): T2
    ---@param third fun(v: T2): T3
    ---@param fourth fun(v: T3): O
    ---@return fun(v: I): O
    function f.chain(first, second, third, fourth)
        error {first, second, third, fourth}
    end

    ---@generic I, T1, T2, T3, T4, O
    ---@param first fun(v: I): T1
    ---@param second fun(v: T1): T2
    ---@param third fun(v: T2): T3
    ---@param fourth fun(v: T3): T4
    ---@param fifth fun(v: T4): O
    ---@return fun(v: I): O
    function f.chain(first, second, third, fourth, fifth)
        error {first, second, third, fourth, fifth}
    end

    ---@generic I, O
    ---@param all {[1]: (fun(v: I): O)}
    ---@return fun(v: I): O
    function f.chain(all)
        error(all)
    end

    ---@generic I, T, O
    ---@param all {[1]: (fun(v: I): T), [2]: (fun(v: T): O)}
    ---@return fun(v: I): O
    function f.chain(all)
        error(all)
    end

    ---@generic I, T1, T2, O
    ---@param all {[1]: (fun(v: I): T1), [2]: (fun(v: T1): T2), [3]: (fun(v: T2): O)}
    ---@return fun(v: I): O
    function f.chain(all)
        error(all)
    end

    ---@generic I, T1, T2, T3, O
    ---@param all {[1]: (fun(v: I): T1), [2]: (fun(v: T1): T2), [3]: (fun(v: T2): T3), [4]: (fun(v: T3): O)}
    ---@return fun(v: I): O
    function f.chain(all)
        error(all)
    end

    ---@generic I, T1, T2, T3, T4, O
    ---@param all {[1]: (fun(v: I): T1), [2]: (fun(v: T1): T2), [3]: (fun(v: T2): T3), [4]: (fun(v: T3): T4), [4]: (fun(v: T4): O)}
    ---@return fun(v: I): O
    function f.chain(all)
        error(all)
    end

    ---@generic K, V
    ---@param self F | { [K]: V }
    ---@return K?, V?
    function f:next()
        error()
    end
end

---@type F
local none

---@generic T: F|function|string|nil
---@param func T
---@return T
---@nodiscard
local function autofunc(func)
    return type(func) == "string" and f.index(func) or func or f.id
end

---@generic K, V
---@param tbl table<K, V>
---@param fpairs? fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K, V)
---@return fun(tbl: table<K, V>, key: K): K, V
---@return table<K, V>
---@return V
---@nodiscard
local function autopairs(tbl, fpairs)
    return (fpairs or (tbl[#tbl] and ipairs or pairs))(tbl)
end

---@param any any
---@return boolean
---@nodiscard
local function is_f(any)
    return type(any) == "table" and any.from == f.from and any.new == f.new
end

--- Always returns nil.
---@return nil
---@nodiscard
function f.noop()
end

--- Always returns false.
---@return false
---@nodiscard
function f.fals()
    return false
end

--- Always returns true.
---@return true
---@nodiscard
function f.tru()
    return true
end

--- Returns the arguments.
---@generic T
---@param ... T
---@return T
---@nodiscard
function f.id(...)
    return ...
end

---@generic T
---@param value T
---@return fun(T): boolean
function f.eq(value)
    return function(v)
        return value == v
    end
end

---@generic T
---@param value T
---@return fun(T): boolean
function f.nq(value)
    return function(v)
        return value ~= v
    end
end

---@generic T
---@param v T
---@return fun(): T
---@nodiscard
function f.const(v)
    if v == true then
        return f.tru
    elseif v == false then
        return f.fals
    elseif v == nil then
        return f.noop
    end

    return function()
        return v
    end
end

---@generic K, V
---@param v K
---@return fun(x: { [K]: V }): V
---@nodiscard
function f.index(v)
    return function(x)
        return type(x) == "table" and x[v] or x
    end
end

---@generic K, V
---@param v { [K]: V }
---@return fun(x: K): V
---@nodiscard
function f.index_into(v)
    return type(v) == "table" and function(x)
        return v[x]
    end or f.const(v)
end

---@generic V
---@param v string
---@return fun(x: { [string]: V }): V
---@nodiscard
function f.indices(v)
    return function(x)
        if type(x) ~= "table" then
            return x
        end

        for i in v:gmatch "[^.]+" do
            x = x[i]
        end

        return x
    end
end

f[true and "chain"] = function(...)
    for _, v in ipairs(...) do
        if type(v) == "table" then
            for _, vv in ipairs(v) do
                ret = ret and function(...)
                    return vv(ret(...))
                end or vv
            end
        else
            ret = ret and function(...)
                return v(ret(...))
            end or v
        end
    end

    return ret or f.noop
end

---@generic K, V
---@param fnext? fun(): K?, V?
---@return F|{ [K]: V }
---@nodiscard
function f.new(fnext)
    -- Iterating over `f` is far easier, but we do this for performance sake.
    return {
        all = f.all,
        any = f.any,
        chain = f.chain,
        concat = f.concat,
        const = f.const,
        count = f.count,
        each = f.each,
        eq = f.eq,
        fals = f.fals,
        flatmap = f.flatmap,
        fold = f.fold,
        from = f.from,
        id = f.id,
        index = f.index,
        index_into = f.index_into,
        indices = f.indices,
        keys = f.keys,
        map = f.map,
        new = f.new,
        next = fnext or f.noop,
        noop = f.noop,
        nq = f.nq,
        pun = f.pun,
        skip = f.skip,
        slice = f.slice,
        string = f.string,
        swap = f.swap,
        table = f.table,
        take = f.take,
        tru = f.tru,
        values = f.values,
        where = f.where,
    }
end

--- Creates an enumeration.
---@type FFrom
function f.from(iter, fpairs, step)
    if iter == nil then
        return none
    elseif iter == true then
        return f.tru
    elseif iter == false then
        return f.fals
    end

    local t = type(iter)

    if t == "string" then
        return f.indices(iter)
    elseif t == "number" then
        local ik, is, start = 0, step or 1, fpairs and iter or 1

        local stop = not fpairs and iter or
            (type(fpairs) == "number") and fpairs or error("Invalid argument type for 'fpairs': " .. type(fpairs))

        if start ~= stop and (is == 0 or ((is < 0) == (start < stop))) then
            return none
        end

        return f.new(function()
            local iv = start + ik * is
            ik = ik + 1

            if start > stop and iv >= stop or
                start < stop and iv <= stop or
                start == stop and iv == stop then
                return ik, iv
            end
        end)
    elseif t == "function" then
        return f.new(iter)
    elseif t == "thread" then
        return f.new(function()
            local s, k, v = coroutine.resume(iter)

            if s then
                return k, v
            end
        end)
    else
        local next, context, k, v = autopairs(iter, type(fpairs) == "function" and fpairs or nil)

        return f.new(function()
            k, v = next(context, k)
            return k, v
        end)
    end
end

---@generic K, V
---@param self F|{ [K]: V }
---@param ... F|{ [K]: V }
---@return F|{ [K]: V }
---@nodiscard
function f:concat(...)
    local fsi = 0
    local fs = {...}
    local sum, last = 0, 0

    for i = 1, #fs do
        fs[i] = is_f(fs[i]) and fs[i] or f.from(fs[i])
    end

    return f.new(function()
        if fsi == 0 then
            local k, v = self:next()
            last = type(k) == "number" and math.max(k, last) or last

            if k ~= nil then
                return k, v
            end

            fsi, sum, last = 1, last, 0
        end

        while fsi <= #fs do
            local k, v = fs[fsi]:next()
            last = type(k) == "number" and math.max(k, last) or last

            if k ~= nil then
                return type(k) == "number" and k + sum or k, v
            end

            fsi, sum, last = fsi + 1, sum + last, 0
        end
    end)
end

---@generic K, V, U
---@param self F|{ [K]: V }
---@param func F|fun(v: V, k: K): U
---@return F|{ [K]: U }
---@nodiscard
---@overload fun(self: F|{ [K]: V }, func: string): F|{ [K]: U }
function f:map(func)
    func = autofunc(func)

    return f.new(function()
        local k, v = self:next()

        if k ~= nil then
            return k, func(v, k)
        end
    end)
end

---@generic K, V, U
---@param self F|{ [K]: V }
---@param func F|fun(v: V, k: K): { [any]: U }
---@param fpairs? fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K, V)
---@return F|{ [K]: U }
---@nodiscard
---@overload fun(self: F|{ [K]: V }, func: string, fpairs?: fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K, V)): F|{ [K]: U }
function f:flatmap(func, fpairs)
    -- local i = 0
    local vt, vk, vv, vp
    func = autofunc(func)

    return f.new(function()
        if vk then
            vk, vv = vp(vt, vk)

            if vk ~= nil then
                -- i = i + 1
                -- return i, vv
                return vk, vv
            end
        end

        while true do
            local k, v = self:next()

            if k == nil then
                return
            end

            v = func(v, k)

            if type(v) ~= "table" then
                -- i = i + 1
                -- return i, v
                return k, v
            end

            vp, vt, vk = autopairs(v, fpairs)
            vk, vv = vp(vt, vk)

            if vk ~= nil then
                -- i = i + 1
                -- return i, vv
                return vk, vv
            end
        end
    end)
end

---@generic K, V, U
---@param self F|{ [K]: V }
---@param func F|fun(v: V, k: K): { [any]: U }
---@param fpairs? fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K, V)
---@return F|{ [K]: U }
---@nodiscard
---@overload fun(self: F|{ [K]: V }, func: string, fpairs?: fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K, V)): F|{ [K]: U }
function f:flatmap(func, fpairs)
    -- local i = 0
    local vt, vk, vv, vp
    func = autofunc(func)

    return f.new(function()
        if vk then
            vk, vv = vp(vt, vk)

            if vk ~= nil then
                -- i = i + 1
                -- return i, vv
                return vk, vv
            end
        end

        while true do
            local k, v = self:next()

            if k == nil then
                return
            end

            v = func(v, k)

            if type(v) ~= "table" then
                -- i = i + 1
                -- return i, v
                return k, v
            end

            vp, vt, vk = autopairs(v, fpairs)
            vk, vv = vp(vt, vk)

            if vk ~= nil then
                -- i = i + 1
                -- return i, vv
                return vk, vv
            end
        end
    end)
end

---@generic K, V
---@param self F|{ [K]: V }
---@param func F|fun(v: V, k: K): boolean
---@param is? any
---@return F|{ [K]: V }
---@nodiscard
---@overload fun(self: F|{ [K]: V }, func: string, is?: any): F|{ [K]: V }
function f:where(func, is)
    func = autofunc(func)

    return f.new(function()
        local k, v

        while true do
            k, v = self:next()

            if k == nil then
                return
            end

            if is == nil then
                if func(v, k) then
                    return k, v
                end
            elseif is == false then
                if not func(v, k) then
                    return k, v
                end
            elseif is == func(v, k) then
                return k, v
            end
        end
    end)
end

---@generic K, V
---@param self F|{ [K]: V }
---@return F|{ [integer]: K }
---@nodiscard
function f:keys()
    local i = 0

    return f.new(function()
        local k = self:next()

        if k ~= nil then
            i = i + 1
            return i, k
        end
    end)
end

---@generic K, V
---@param self F|{ [K]: V }
---@return F|{ [integer]: V }
---@nodiscard
function f:values()
    local i = 0

    return f.new(function()
        local k, v = self:next()

        if k ~= nil then
            i = i + 1
            return i, v
        end
    end)
end

---@generic K, V
---@param self F|{ [K]: V }
---@return F|{ [V]: K }
---@nodiscard
function f:swap()
    return f.new(function()
        local k, v = self:next()

        if k ~= nil then
            return v, k
        end
    end)
end

---@generic K, V
---@param self F|{ [K]: V }
---@param skip? integer
---@param take? integer
---@return F|{ [K]: V }
---@nodiscard
function f:slice(skip, take)
    if (not skip or skip <= 0) and not take then
        return self
    end

    local i = 0

    return f.new(function()
        if take and take <= 0 then
            return
        end

        while skip and skip > 0 do
            skip = skip - 1
            self:next()
        end

        local k, v = self:next()

        if k ~= nil and (not take or i < take) then
            i = i + 1
            return i, v
        end
    end)
end

---@generic K, V
---@param self F|{ [K]: V }
---@param n? integer
---@return F|{ [K]: V }
---@nodiscard
function f:skip(n)
    return self:slice(n)
end

---@generic K, V
---@param self F|{ [K]: V }
---@param n? integer
---@return F|{ [K]: V }
---@nodiscard
function f:take(n)
    return self:slice(0, n)
end

---@generic K, V, A
---@param self F|{ [K]: V }
---@param seed A
---@param func fun(a: A, v: V, k: K): A
---@return A
---@overload fun(self: F|{ [K]: V }, seed: fun(a: A, v: V, k: K): A): A
---@nodiscard
function f:fold(seed, func)
    local k, v

    if not func then
        func = seed
        k, seed = self:next()

        if k == nil then
            return seed
        end
    end

    while true do
        k, v = self:next()

        if k == nil then
            return seed
        end

        seed = func(seed, v, k)
    end
end

---@generic K, V
---@param self F|{ [K]: V }
---@param func F|fun(v: V, k: K): any
---@return boolean|V
---@nodiscard
---@overload fun(self: F|{ [K]: V }, func: string?): boolean|V
function f:any(func)
    func = autofunc(func)

    for k, v in self.next do
        if not func or func(v, k) then
            return v or true
        end
    end

    return false
end

---@generic K, V
---@param self F|{ [K]: V }
---@param func F|fun(v: V, k: K): any
---@return boolean|V
---@nodiscard
---@overload fun(self: F|{ [K]: V }, func: string?): boolean|V
function f:all(func)
    func = autofunc(func)

    for k, v in self.next do
        if not func or not func(v, k) then
            return v and false
        end
    end

    return true
end

---@generic K, V
---@param self F|{ [K]: V }
---@param func F|fun(v: V, k: K): any
---@return integer
---@nodiscard
---@overload fun(self: F|{ [K]: V }, func: string): integer
function f:count(func)
    local ret = 0
    func = autofunc(func)

    for k, v in self.next do
        if not func or func(v, k) then
            ret = ret + 1
        end
    end

    return ret
end

---@generic K, V, T
---@param self F|{ [K]: V }
---@param _ `T`
---@return F|{ [K]: `T` }
---@nodiscard
function f:pun(_)
    return self
end

---@generic K, V
---@param self F|{ [K]: V }
---@return string
---@nodiscard
function f:string()
    local k, v = self:next()

    if k == nil then
        return "{}"
    end

    local ret = "{" .. (type(k) == "number" and "" or tostring(k) .. ": ") .. tostring(v)

    while true do
        k, v = self:next()

        if k == nil then
            return ret .. "}"
        end

        ret = ret .. ", " .. (type(k) == "number" and tostring(v) or tostring(k) .. ": " .. tostring(v))
    end
end

---@generic K, V
---@param self F|{ [K]: V }
---@return { [K]: V }
---@nodiscard
function f:table()
    local ret = {}

    for k, v in self.next do
        ret[k] = v
    end

    return ret
end

---@generic K, V
---@param self F|{ [K]: V }
---@param func? fun(v: V, k: K): nil
function f:each(func)
    for k, v in self.next do
        if func then
            func(v, k)
        end
    end
end

none = f.new()

---@type F|FFrom
local ret = (setmetatable or f.const(f.from))(f, {
    __call = function(_, ...)
        return f.from(...)
    end,
})

return ret
