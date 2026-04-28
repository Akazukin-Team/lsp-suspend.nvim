local M = {}

--- get keys from table
---@param t table
---@return table
function M.get_keys(t)
    local keys = {}
    for k, _ in pairs(t) do
        table.insert(keys, k)
    end
    return keys
end

function M.has_value(t, val)
    if not t then
        return false
    end

    for _, value in ipairs(t) do
        if value == val then
            return true
        end
    end
    return false
end

function M.removeByValue(t, v)
    if not t then
        return false
    end

    local res = false
    for i = #t, 1, -1 do
        if t[i] == v then
            res = true
            table.remove(t, i)
        end
    end
    return res
end

function M.copy(t)
    if not t then
        return {}
    end

    return table.move(t, 1, #t, 1, {})
end

--- Append elements of one table to another
---@param t table the destination table to append to
---@param t2 table the source table to append from
---@return table the destination table after appending
function M.append(t, t2)
    if not t or not t2 then
        return M.copy(t or t2 or {})
    end

    local new = M.copy(t)
    table.move(t2, 1, #t2, #new + 1, new)
    return new
end

return M
