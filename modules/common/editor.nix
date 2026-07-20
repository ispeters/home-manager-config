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
    '';
  };
}
