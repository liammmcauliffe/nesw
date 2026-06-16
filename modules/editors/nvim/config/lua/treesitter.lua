-- Tree-sitter parsers are installed declaratively via nvim-treesitter.withPlugins
-- in modules/editors/nvim/default.nix. Do not call treesitter.install() on NixOS.

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function(args)
        local buf = args.buf
        local ft = vim.bo[buf].filetype

        local lang = vim.treesitter.language.get_lang(ft)
        if not lang then
            return
        end

        local ok_add = pcall(vim.treesitter.language.add, lang)
        if not ok_add then
            return
        end

        pcall(vim.treesitter.start, buf, lang)
    end,
})
