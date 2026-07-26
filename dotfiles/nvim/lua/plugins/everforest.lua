return {
  {
    "neanias/everforest-nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("everforest").setup({
        background = "hard",
      })
      vim.cmd.colorscheme("everforest")
    end,
  },
}
