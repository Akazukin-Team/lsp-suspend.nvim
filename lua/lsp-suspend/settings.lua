local M = {}

---@class LspTimeoutSettings
---@field timeout number
---@field notify boolean
---@field filetypes table
---@field filetypes.ignore table
local DEFAULT_SETTINGS = {
    timeout = 3 * 60 * 1000,
    notify = false,
    filetypes = {
        ignore = {},
    },
}

M._DEFAULT_SETTINGS = DEFAULT_SETTINGS
M.current = M._DEFAULT_SETTINGS

---@param opts LspTimeoutSettings
function M.set(opts)
    M.current = vim.tbl_deep_extend("force", M.current, opts)
    -- Check if running Neovim 0.11.2+ for new vim.validate syntax
    if vim.fn.has("nvim-0.11.2") == 1 then
        -- New 0.11.2+ syntax
        vim.validate("timeout", M.current.timeout, "number", true)
        vim.validate("notify", M.current.notify, "boolean", true)
        vim.validate("filetypes", M.current.filetypes, "table", true)
        vim.validate("filetypes.ignore", M.current.filetypes.ignore, "table", true)
    else
        -- Backwards compatible syntax for older versions
        vim.validate({
            timeout = { M.current.timeout, "number", true },
            notify = { M.current.notify, "boolean", true },
            filetypes = { M.current.filetypes, "table", true },
            filetypes_ignore = { M.current.filetypes.ignore, "table", true },
        })
    end
end

return M
