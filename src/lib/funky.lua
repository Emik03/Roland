---@author Emik
---@copyright (c) 2026 Emik
---@license MPL-2.0
---@version 1.0.0
---
---@alias FFrom (fun<K, V>(iter: table<K, V>, fpairs?: fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K?, V?)): F | { [K]: V })|(fun(iter: number, fpairs?: number, step?: number): F | { [number]: number })|(fun<V>(iter: string): (fun(table: { [string]: V }): V))|(fun<V>(iter: string): (fun(table: { [string]: V }): V))|(fun<K, V>(iter: fun(): K, V): F | { [K]: V })|(fun(iter: false): fun(): false)|(fun(iter: true): fun(): true)|(fun(iter: nil): F)
---@class F
local f = {}

if not f then
    ---@generic T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, R
    ---@param self F
    ---@param first? T1
    ---@param second? T2
    ---@param third? T3
    ---@param fourth? T4
    ---@param fifth? T5
    ---@param sixth? T6
    ---@param seventh? T7
    ---@param eighth? T8
    ---@param ninth? T9
    ---@param tenth? T10
    ---@return fun(v: fun(first: T1, second: T2, third: T3, fourth: T4, fifth: T5, sixth: T6, seventh: T7, eighth: T8, ninth: T9, tenth: T10): R): R
    ---@nodiscard
    function f:call(first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth)
        error {first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth}
    end

    ---@generic T1, T2, T3, T4, T5, T6, T7, T8, T9, T10, R
    ---@param self string
    ---@param first? T1
    ---@param second? T2
    ---@param third? T3
    ---@param fourth? T4
    ---@param fifth? T5
    ---@param sixth? T6
    ---@param seventh? T7
    ---@param eighth? T8
    ---@param ninth? T9
    ---@param tenth? T10
    ---@return fun(v: {[string]: fun(self: self, first: T1, second: T2, third: T3, fourth: T4, fifth: T5, sixth: T6, seventh: T7, eighth: T8, ninth: T9, tenth: T10): R}): R
    ---@nodiscard
    function f.call(self, first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth)
        error {self, first, second, third, fourth, fifth, sixth, seventh, eighth, ninth, tenth}
    end

    ---@generic I, O
    ---@param first integer|string|fun(v: I): O
    ---@return fun(v: I): O
    ---@nodiscard
    function f.chain(first)
        error {first}
    end

    ---@generic I, T, O
    ---@param first integer|string|fun(v: I): T
    ---@param second integer|string|fun(v: T): O
    ---@return fun(v: I): O
    ---@nodiscard
    function f.chain(first, second)
        error {first, second}
    end

    ---@generic I, T1, T2, O
    ---@param first integer|string|fun(v: I): T1
    ---@param second integer|string|fun(v: T1): T2
    ---@param third integer|string|fun(v: T2): O
    ---@return fun(v: I): O
    ---@nodiscard
    function f.chain(first, second, third)
        error {first, second, third}
    end

    ---@generic I, T1, T2, T3, O
    ---@param first integer|string|fun(v: I): T1
    ---@param second integer|string|fun(v: T1): T2
    ---@param third integer|string|fun(v: T2): T3
    ---@param fourth integer|string|fun(v: T3): O
    ---@return fun(v: I): O
    ---@nodiscard
    function f.chain(first, second, third, fourth)
        error {first, second, third, fourth}
    end

    ---@generic I, T1, T2, T3, T4, O
    ---@param first integer|string|fun(v: I): T1
    ---@param second integer|string|fun(v: T1): T2
    ---@param third integer|string|fun(v: T2): T3
    ---@param fourth integer|string|fun(v: T3): T4
    ---@param fifth integer|string|fun(v: T4): O
    ---@return fun(v: I): O
    ---@nodiscard
    function f.chain(first, second, third, fourth, fifth)
        error {first, second, third, fourth, fifth}
    end

    ---@generic I, O
    ---@param all { [1]: (integer|string|fun(v: I): O) }
    ---@return fun(v: I): O
    ---@nodiscard
    function f.chain(all)
        error(all)
    end

    ---@generic I, T, O
    ---@param all { [1]: (integer|string|fun(v: I): T), [2]: (integer|string|fun(v: T): O) }
    ---@return fun(v: I): O
    ---@nodiscard
    function f.chain(all)
        error(all)
    end

    ---@generic I, T1, T2, O
    ---@param all { [1]: (integer|string|fun(v: I): T1), [2]: (integer|string|fun(v: T1): T2), [3]: (integer|string|fun(v: T2): O) }
    ---@return fun(v: I): O
    ---@nodiscard
    function f.chain(all)
        error(all)
    end

    ---@generic I, T1, T2, T3, O
    ---@param all { [1]: (integer|string|fun(v: I): T1), [2]: (integer|string|fun(v: T1): T2), [3]: (integer|string|fun(v: T2): T3), [4]: (integer|string|fun(v: T3): O) }
    ---@return fun(v: I): O
    ---@nodiscard
    function f.chain(all)
        error(all)
    end

    ---@generic I, T1, T2, T3, T4, O
    ---@param all { [1]: (integer|string|fun(v: I): T1), [2]: (integer|string|fun(v: T1): T2), [3]: (integer|string|fun(v: T2): T3), [4]: (integer|string|fun(v: T3): T4), [4]: (integer|string|fun(v: T4): O) }
    ---@return fun(v: I): O
    ---@nodiscard
    function f.chain(all)
        error(all)
    end

    ---@generic I, O
    ---@param first integer|string|fun(v: I): O
    ---@return fun(v: I): O
    ---@nodiscard
    function f.compose(first)
        error {first}
    end

    ---@generic I, T, O
    ---@param first integer|string|fun(v: T): O
    ---@param second integer|string|fun(v: I): T
    ---@return fun(v: I): O
    ---@nodiscard
    function f.compose(first, second)
        error {first, second}
    end

    ---@generic I, T1, T2, O
    ---@param first integer|string|fun(v: T2): O
    ---@param second integer|string|fun(v: T1): T2
    ---@param third integer|string|fun(v: I): T1
    ---@return fun(v: I): O
    ---@nodiscard
    function f.compose(first, second, third)
        error {first, second, third}
    end

    ---@generic I, T1, T2, T3, O
    ---@param first integer|string|fun(v: T3): O
    ---@param second integer|string|fun(v: T2): T3
    ---@param third integer|string|fun(v: T1): T2
    ---@param fourth integer|string|fun(v: I): T1
    ---@return fun(v: I): O
    ---@nodiscard
    function f.compose(first, second, third, fourth)
        error {first, second, third, fourth}
    end

    ---@generic I, T1, T2, T3, T4, O
    ---@param first integer|string|fun(v: T4): O
    ---@param second integer|string|fun(v: T3): T4
    ---@param third integer|string|fun(v: T2): T3
    ---@param fourth integer|string|fun(v: T1): T2
    ---@param fifth integer|string|fun(v: I): T1
    ---@return fun(v: I): O
    ---@nodiscard
    function f.compose(first, second, third, fourth, fifth)
        error {first, second, third, fourth, fifth}
    end

    ---@generic I, O
    ---@param all { [1]: (integer|string|fun(v: I): O) }
    ---@return fun(v: I): O
    ---@nodiscard
    function f.compose(all)
        error(all)
    end

    ---@generic I, T, O
    ---@param all { [1]: (integer|string|fun(v: T): O), [2]: (integer|string|fun(v: I): T) }
    ---@return fun(v: I): O
    ---@nodiscard
    function f.compose(all)
        error(all)
    end

    ---@generic I, T1, T2, O
    ---@param all { [1]: (integer|string|fun(v: T2): O), [2]: (integer|string|fun(v: T1): T2), [3]: (integer|string|fun(v: I): T1) }
    ---@return fun(v: I): O
    ---@nodiscard
    function f.compose(all)
        error(all)
    end

    ---@generic I, T1, T2, T3, O
    ---@param all { [1]: (integer|string|fun(v: T3): O), [2]: (integer|string|fun(v: T2): T3), [3]: (integer|string|fun(v: T1): T2), [4]: (integer|string|fun(v: I): T1) }
    ---@return fun(v: I): O
    ---@nodiscard
    function f.compose(all)
        error(all)
    end

    ---@generic I, T1, T2, T3, T4, O
    ---@param all { [1]: (integer|string|fun(v: T4): O), [2]: (integer|string|fun(v: T3): T4), [3]: (integer|string|fun(v: T2): T3), [4]: (integer|string|fun(v: T1): T2), [4]: (integer|string|fun(v: I): T1) }
    ---@return fun(v: I): O
    ---@nodiscard
    function f.compose(all)
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
    if func == false then
        return f.fals
    elseif func == true then
        return f.tru
    elseif type(func) == "number" then
        return f.arg(func)
    elseif type(func) == "string" then
        return f.indices(func)
    else
        return func or f.id
    end
end

---@generic K, V
---@param tbl table<K, V>
---@param fpairs? fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K, V)
---@return fun(tbl: table<K, V>, key: K): K, V
---@return table<K, V>
---@return V
---@nodiscard
local function autopairs(tbl, fpairs)
    return (fpairs or (tbl[1] and ipairs or pairs))(tbl)
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
---@return fun(v: T): boolean
---@nodiscard
function f.eq(value)
    return function(v)
        return value == v
    end
end

---@generic T
---@param value T
---@return fun(T): boolean
---@nodiscard
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

---@param i integer
---@return fun(...: any): any
---@nodiscard
function f.arg(i)
    return function(...)
        return ({...})[i]
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
        for i in v:gmatch "[^.]+" do
            if type(x) ~= "table" then
                return x
            end

            x = x[i]
        end

        return x
    end
end

---@generic K, V
---@param v V
---@param k K
---@return fun(x: { [K]: V }): { [K]: V }
---@nodiscard
function f.insert(v, k)
    return function(x)
        if type(x) == "table" then
            x[k] = v
        end

        return x
    end
end

---@generic T
---@param tbl T[]
---@return fun(t: T[], i?: integer): integer, T
---@return T[]
function f.revpairs(tbl)
    return function(t, i)
        local k = i and i - 1 or #t
        local v = t[k]

        if v ~= nil then
            return k, v
        end
    end, tbl
end

---@param any any
---@return boolean
---@nodiscard
function f.isf(any)
    return type(any) == "table" and any.from == f.from and any.new == f.new
end

local unpack = table.unpack or unpack

f[true and "call"] = function(self, ...)
    local args = {...}

    return type(self) == "string" and function(v)
        return v[self](v, unpack(args))
    end or function(v)
        return v(unpack(args))
    end
end

f[true and "chain"] = function(...)
    local ret

    for _, v in ipairs {...} do
        v = f.isf(v) and v:table() or v

        if type(v) == "table" then
            for _, vv in ipairs(v) do
                local copy = ret
                vv = autofunc(vv)

                ret = ret and function(...)
                    return vv(copy(...))
                end or vv
            end
        else
            local copy = ret
            v = autofunc(v)

            ret = ret and function(...)
                return v(copy(...))
            end or v
        end
    end

    return ret or f.noop
end

f[true and "compose"] = function(...)
    return f.chain(f.from({...}, f.revpairs):values())
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
        arg = f.arg,
        call = f.call,
        chain = f.chain,
        compose = f.compose,
        concat = f.concat,
        const = f.const,
        count = f.count,
        diff = f.diff,
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
        insert = f.insert,
        isf = f.isf,
        keys = f.keys,
        map = f.map,
        new = f.new,
        next = fnext or f.noop,
        noop = f.noop,
        nq = f.nq,
        peek = f.peek,
        pun = f.pun,
        rev = f.rev,
        revpairs = f.revpairs,
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
        local next, tbl, k, v = autopairs(iter, type(fpairs) == "function" and fpairs or nil)

        return f.new(function()
            k, v = next(tbl, k)
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
    self = f.isf(self) and self or f.from(self)
    local fsi = 0
    local fs = {...}
    local sum, last = 0, 0

    for i = 1, #fs do
        local s = fs[i]
        fs[i] = f.isf(s) and s or f.from(s)
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

---@generic K, V
---@param self F|{ [K]: V }
---@param func fun(v: V, k: K): any
---@return F|{ [K]: V }
---@nodiscard
function f:peek(func)
    self = f.isf(self) and self or f.from(self)
    func = autofunc(func)

    return f.new(function()
        local k, v = self:next()

        if k ~= nil then
            func(v, k)
            return k, v
        end
    end)
end

---@generic K, V, U
---@param self F|{ [K]: V }
---@param func fun(v: V, k: K): U
---@return F|{ [K]: U }
---@overload fun(self: F|{ [K]: V }, func: string): F|{ [K]: U }
---@nodiscard
function f:map(func)
    self = f.isf(self) and self or f.from(self)
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
---@param func fun(v: V, k: K): { [any]: U }
---@param fpairs? fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K, V)
---@return F|{ [K]: U }
---@overload fun(self: F|{ [K]: V }, func: string, fpairs?: fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K, V)): F|{ [K]: U }
---@nodiscard
function f:flatmap(func, fpairs)
    self = f.isf(self) and self or f.from(self)
    -- local i = 0
    local vt, vk, vp
    func = autofunc(func)

    return f.new(function()
        local vv

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
---@param func fun(v: V, k: K): boolean
---@param is? any
---@return F|{ [K]: V }
---@nodiscard
---@overload fun(self: F|{ [K]: V }, func: string, is?: any): F|{ [K]: V }
function f:where(func, is)
    self = f.isf(self) and self or f.from(self)
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
    self = f.isf(self) and self or f.from(self)
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
    self = f.isf(self) and self or f.from(self)
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
    self = f.isf(self) and self or f.from(self)

    return f.new(function()
        local k, v = self:next()

        if k ~= nil then
            return v, k
        end
    end)
end

---@generic K, V
---@param self F|{ [K]: V }
---@return F|{ [K]: V }
---@nodiscard
function f:rev()
    self = f.isf(self) and self or f.from(self)
    local t, p, k

    return f.new(function()
        if not t then
            p, t = f.revpairs(self:table())
        end

        local v
        k, v = p(t, k)

        if k ~= nil then
            return k, v
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
    self = f.isf(self) and self or f.from(self)

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
    self = f.isf(self) and self or f.from(self)
    return self:slice(n)
end

---@generic K, V
---@param self F|{ [K]: V }
---@param n? integer
---@return F|{ [K]: V }
---@nodiscard
function f:take(n)
    self = f.isf(self) and self or f.from(self)
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
    self = f.isf(self) and self or f.from(self)
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
---@param func fun(v: V, k: K): any
---@return boolean|V
---@overload fun(self: F|{ [K]: V }, func: string?): boolean|V
---@nodiscard
function f:any(func)
    self = f.isf(self) and self or f.from(self)
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
---@param func fun(v: V, k: K): any
---@return boolean|V
---@overload fun(self: F|{ [K]: V }, func: string?): boolean|V
---@nodiscard
function f:all(func)
    self = f.isf(self) and self or f.from(self)
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
---@param func fun(v: V, k: K): any
---@return integer
---@overload fun(self: F|{ [K]: V }, func: string): integer
---@nodiscard
function f:count(func)
    self = f.isf(self) and self or f.from(self)
    func = autofunc(func)
    local ret = 0

    for k, v in self.next do
        if not func or func(v, k) then
            ret = ret + 1
        end
    end

    return ret
end

---@generic K, V
---@param self F|{ [K]: V }
---@param other { [K]: V }
---@param func? fun(v: V, k: K): any
---@return K?, V?
---@overload fun(self: F|{ [K]: V }, func: string): integer
---@nodiscard
function f:diff(other, func)
    self = f.isf(self) and self or f.from(self)
    func = autofunc(func)

    for k, v in self.next do
        if (not func or func(v, k)) and other[k] ~= v then
            return k, v
        end
    end
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
    self = f.isf(self) and self or f.from(self)
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
    self = f.isf(self) and self or f.from(self)
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
    self = f.isf(self) and self or f.from(self)

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
