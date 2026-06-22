local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("mini.completion").get_lsp_capabilities())

vim.lsp.config("*", { capabilities = capabilities })

vim.lsp.config("lua_ls", {
    settings = {
        Lua = {
            diagnostics = { globals = {"vim"} },
        },
    },
})

vim.lsp.config("nil_ls", {
    cmd = {"nil"},
    filetypes = {"nix"},
    root_markers = {"flake.nix", ".git"},
})

vim.lsp.enable({
    "lua_ls",
    "nil_ls"
})
