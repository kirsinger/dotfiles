return {
  'williamboman/mason-lspconfig.nvim',
  opts = {
    ensure_installed = {
      'eslint',
      'html',
      'lua_ls',
      'pyright',
      'tailwindcss',
      'ts_ls',
    },
  },
  dependencies = {
    {'mason-org/mason.nvim', opts = {}},
    'neovim/nvim-lspconfig',
  },
}
