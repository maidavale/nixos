{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;

    plugins = [
      { plugin = pkgs.vimPlugins.gruvbox; }
      { plugin = pkgs.vimPlugins.telescope-nvim; }
      { plugin = pkgs.vimPlugins.telescope-fzf-native-nvim; }
      { plugin = pkgs.vimPlugins.plenary-nvim; }
    ];

    extraConfig = ''
      set number
      set relativenumber
      set cursorline

      " Enable termguicolors for better theme support
      if has("termguicolors")
        set termguicolors
      endif

      " Optionally, set your colorscheme
      colorscheme gruvbox

      " Telescope configuration via Lua:
      lua << EOF
        local telescope = require("telescope")
        telescope.setup{
          defaults = {
            prompt_prefix = "> ",
            -- Add more default options here if desired.
          },
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = "smart_case",
            },
          },
        }
        -- Load the fzf extension (if installed)
        telescope.load_extension("fzf")

        -- Define key mappings for Telescope pickers
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
        vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
      EOF
    '';
  };
}

