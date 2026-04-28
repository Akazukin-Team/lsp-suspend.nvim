local uv = vim.uv
local settings = require("lsp-suspend.settings")
local array_utils = require("lsp-suspend.utils.array")

local M = {}

local timers = {}
local lsps = {}
local window_unactive_timer

local function get_or_new_timer(lsp_id)
    local timer
    if timers[lsp_id] then
        timer = timers[lsp_id]
    else
        timer = uv.new_timer()
        timers[lsp_id] = timer
    end
    return timer
end

local function destroy_lsp_timer(lsp_id, timer)
    local cur_timer = timers[lsp_id]
    if not cur_timer then
        return
    end

    if timer ~= nil and cur_timer ~= timer then
        return
    end

    timers[lsp_id] = nil

    cur_timer:stop()
    cur_timer:close()
end

local function destroy_lsp(lsp_id)
    local cl = vim.lsp.get_client_by_id(lsp_id)
    if cl then
        cl:stop(true)
    end

    destroy_lsp_timer(lsp_id, nil)
end

local function destroy_win_timer()
    if not window_unactive_timer then
        return
    end

    window_unactive_timer:stop()
    window_unactive_timer:close()
    window_unactive_timer = nil
end

function M.on_win_unfocus()
    vim.notify("Schedule timer to destroy all LSP.", vim.log.levels.DEBUG)
    window_unactive_timer = uv.new_timer()

    window_unactive_timer:start(settings.current.timeout, 0, function()
        for _, cl in ipairs(vim.lsp.get_clients()) do
            if cl:is_stopped() then
                goto continue
            end

            local cl_data
            if lsps[cl.name] then
                cl_data = lsps[cl.name]

                local ok = vim.wait(1000 * 1000 * 1000, function()
                    return not cl_data.lock
                end)
                if not ok then
                    vim.notify("", vim.log.levels.ERROR)
                    return
                end
            else
                lsps[cl.name] = {}
                cl_data = lsps[cl.name]
            end

            lsps[cl.name].lock = true

            local buffers
            if lsps[cl.name] then
                buffers = array_utils.append(array_utils.get_keys(cl.attached_buffers), lsps[cl.name].buffers)
            else
                buffers = array_utils.get_keys(cl.attached_buffers)
            end

            lsps[cl.name] = {
                config = cl.config,
                buffers = buffers,
            }

            vim.schedule(function()
                destroy_lsp(cl.id)
            end)

            ::continue::
        end

        destroy_win_timer()
        vim.notify("Destroy all LSP.", vim.log.levels.INFO)
    end)
end

function M.on_win_focus()
    destroy_win_timer()
    vim.notify("Destroy the timer scheduled when unfocus window.", vim.log.levels.DEBUG)

    local cur_buf = vim.api.nvim_get_current_buf()
    for cl_name, cl_data in pairs(lsps) do
        if array_utils.removeByValue(cl_data.buffers, cur_buf) then
            array_utils.removeByValue(cl_data.buffers, cur_buf)

            vim.notify("Attach LSP [" .. cl_name .. "] to buf " .. cur_buf, vim.log.levels.DEBUG)
            local cls = vim.lsp.get_clients({ name = cl_name })
            if #cls == 0 then
                vim.notify("Launching LSP [" .. cl_name .. "]", vim.log.levels.INFO)
                vim.lsp.start(cl_data.config, {
                    bufnr = cur_buf,
                    silent = true,
                })
            elseif #cls == 1 then
                vim.notify("Attaching existing LSP [" .. cl_name .. "] to buf " .. cur_buf, vim.log.levels.DEBUG)
                vim.lsp.buf_attach_client(cls[1].id, cur_buf)
            end

            if #cl_data.buffers == 0 then
                lsps[cl_name] = nil
            end
        end
    end
end

function M.on_lsp_attach(lsp_id)
    vim.notify("Destroy LSP [" .. lsp_id .. "] timer.", vim.log.levels.DEBUG)
    destroy_lsp_timer(lsp_id, nil)
end

function M.on_lsp_detach(lsp_id)
    local cl = vim.lsp.get_client_by_id(lsp_id)
    if #cl.attached_buffers ~= 0 then
        return
    end

    vim.notify("Schedule timer to destroy LSP [" .. cl.name .. "]", vim.log.levels.DEBUG)
    local timer = get_or_new_timer(lsp_id)
    timer:start(settings.current.timeout, 0, function()
        vim.schedule(function()
            destroy_lsp(lsp_id)
        end)
        vim.notify("Destroy LSP [" .. cl.name .. "]", vim.log.levels.INFO)
    end)
end

return M
