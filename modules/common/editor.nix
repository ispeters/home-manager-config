{ ... }:
{
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
          "cpp" "lua" "vim" "vimdoc" "query" "markdown" "markdown_inline"
        ];
        highlight.enable = true;
      };
    };
  };
}
