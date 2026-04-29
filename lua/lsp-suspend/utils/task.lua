local M = {}

---@param ms number time to wait
---@param callback function a function for calling when passed the time
function M.wait(ms, callback)
    local timer = vim.uv.new_timer()
    timer:start(ms, 0, function()
        timer:stop()
        timer:close()

        callback()
    end)
end

return M
