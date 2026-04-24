local M = {}

local settings = require("lsp-suspend.settings")

---@param config LspTimeoutSettings | nil
function M.setup(config)
    if config then
        settings.set(config)
    end

    require("lsp-suspend.autocmds")
end

return M
