local M = {}

--- get keys from table
---@param tbl table
---@return table
function M.get_keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

function M.has_value(t, val)
    for _, value in ipairs(t) do
        if value == val then
            return true
        end
    end
    return false
end

function M.removeByValue(t, v)
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
    return table.move(t, 1, #t, 1, {})
end

function M.append(t, t2)
    local new = copy(t)
    table.move(t2, new, #t2, #new + 1, new)
    return new
end

return M
