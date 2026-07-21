_: {
  programs.nixvim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    opts = {
      number = true;
      ruler = true;
    };

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha";
    };

    plugins.treesitter = {
      enable = true;
      settings = {
        ensure_installed = [
          "cpp"
          "lua"
          "vim"
          "vimdoc"
          "query"
          "markdown"
          "markdown_inline"
        ];
        highlight.enable = true;
      };
    };

    plugins.lsp.enable = true;

    extraConfigLua = ''
      -- conditionally enable various LSPs based on whether they're
      -- available on in PATH; my Nix configuration mostly delegates
      -- LSP installation to Nix devshells, so the availability
      -- varies with what I'm editing

      vim.lsp.config("nixd", {
        cmd = { "nixd" },
        filetypes = { "nix" },
        root_markers = { "flake.nix", ".git" },
      })

      if vim.fn.executable("nixd") == 1 then
        vim.lsp.enable("nixd")
      end

      vim.lsp.config("clangd", {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
      })
      if vim.fn.executable("clangd") == 1 then
        vim.lsp.enable("clangd")
      end

      -- LSP semantic tokens are computed asynchronously and can race
      -- against Treesitter's synchronous, in-process highlighting --
      -- any server can push back stale token ranges after edits and
      -- visibly clobber correct Treesitter highlights. Disable semantic
      -- highlighting for all attached LSP clients and let Treesitter
      -- own syntax coloring exclusively.
      --
      -- Note to self: if a particular LSP is worth including in the
      --               syntax highlighting process, this is the place
      --               to special-case it.
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })
    '';
  };
}
