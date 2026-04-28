local tasks = require("lsp-suspend.tasks")

-- augroup for this config file
local augroup = vim.api.nvim_create_augroup("lsp-suspend", {})

-- wrapper function to use internal augroup
local function create_autocmd(event, opts)
    vim.api.nvim_create_autocmd(
        event,
        vim.tbl_extend("force", {
            group = augroup,
        }, opts)
    )
end

create_autocmd("FocusGained", {
    callback = function()
        tasks.on_win_focus()
    end,
})

create_autocmd("FocusLost", {
    callback = function()
        tasks.on_win_unfocus()
    end,
})

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        local buf = vim.api.nvim_get_current_buf()
        tasks.on_buf_enter(buf)
    end,
})

create_autocmd("LspAttach", {
    callback = function(args)
        tasks.on_lsp_attach(args.data.client_id)
    end,
})
create_autocmd("LspDetach", {
    callback = function(args)
        tasks.on_lsp_detach(args.data.client_id)
    end,
})
