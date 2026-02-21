---@author Emik
---@copyright (c) 2026 Emik
---@license MPL-2.0
---@version 1.0.0
---
---@class F
local f = {}

if not f then
    ---@generic K, V
    ---@param self F | { [K]: V }
    ---@return K?, V?
    function f:next()
        error()
    end
end

--- Always returns nil.
---@return nil
function f.noop()
end

--- Always returns false.
---@return false
function f.fals()
    return false
end

--- Always returns true.
---@return true
function f.tru()
    return true
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
        return x[v]
    end
end

---@generic K, V
---@param fnext? fun(): K?, V?
---@return F|{ [K]: V }
---@nodiscard
function f.new(fnext)
    local ret = {next = fnext or f.noop}

    for k, v in pairs(f) do
        ret[k] = v
    end

    return ret
end

---@generic K, V
---@param tbl table<K, V>
---@param fpairs? fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K, V)
---@return fun(tbl: table<K, V>, key: K): K, V
---@return K
---@return V
local function autopairs(tbl, fpairs)
    return (fpairs or tbl[#tbl] and ipairs or pairs)(tbl)
end

---@generic K, V, U
---@param self F|{ [K]: V }
---@param func F|fun(v: V, k: K): U
---@return F|{ [K]: U }
---@nodiscard
function f:map(func)
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
function f:flatmap(func, fpairs)
    -- local i = 0
    local vt, vk, vv, vp

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
---@return F|{ [K]: V }
---@nodiscard
function f:where(func)
    return f.new(function()
        local k, v

        while true do
            k, v = self:next()

            if k == nil then
                return
            end

            if func(v, k) then
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
---@param func F|fun(v: V, k: K): boolean
---@return boolean|V
---@nodiscard
function f:any(func)
    for k, v in self.next do
        if not func or func(v, k) then
            return v or true
        end
    end

    return false
end

---@generic K, V
---@param self F|{ [K]: V }
---@param func F|fun(v: V, k: K): boolean
---@return boolean|V
---@nodiscard
function f:all(func)
    for k, v in self.next do
        if not func or not func(v, k) then
            return v and false
        end
    end

    return true
end

---@generic K, V
---@param self F|{ [K]: V }
---@param func F|fun(v: V, k: K): boolean
---@return integer
---@nodiscard
function f:count(func)
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
---@param func? F|fun(v: V, k: K)
function f:each(func)
    for k, v in self.next do
        if func then
            func(v, k)
        end
    end
end

local none = f.new()

--- Creates an enumeration.
---@generic K, V
---@param tbl table<K, V>
---@param fpairs? fun(t: table<K, V>): (fun(table: table<K, V>, index?: K): K?, V?)
---@param step? nil
---@return F | { [K]: V }
---@overload fun(tbl: number, fpairs?: number, step?: number): F | { [number]: number }
---@overload fun(tbl: string|K): fun(table: { [string|K]: V }): V
---@overload fun(tbl: false): fun(): false
---@overload fun(tbl: true): fun(): true
---@overload fun(tbl: nil): F
return function(tbl, fpairs, step)
    if tbl == true then
        return f.tru
    elseif tbl == false then
        return f.fals
    elseif tbl == nil then
        return none
    end

    local tbl_type = type(tbl)

    if tbl_type == "string" then
        return f.index(tbl)
    elseif tbl_type == "number" then
        local ik = 0
        local start = fpairs and tbl or 1

        local stop = not fpairs and tbl or
            (type(fpairs) == "number") and fpairs or error("Invalid argument type for 'fpairs': " .. type(fpairs))

        if step and step ~= 0 and ((step < 0) == (start < stop)) then
            return none
        end

        return f.new(function()
            local iv = tbl + ik * (step or 1)
            ik = ik + 1

            if start > stop and iv >= stop or
                start < stop and iv <= stop or
                start == stop and iv == stop then
                return ik, iv
            end
        end)
    elseif tbl_type ~= "table" then
        error("Invalid argument type for 'tbl': " .. type(tbl))
    end

    local next, context, k, v = autopairs(tbl, fpairs)

    return f.new(function()
        k, v = next(context, k)
        return k, v
    end)
end
