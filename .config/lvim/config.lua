-- ==============================
--    LunarVim Config for Java
-- ==============================

-- Основные настройки LunarVim
lvim.log.level = "warn"
lvim.format_on_save = true
lvim.colorscheme = "lunar"

-- Настройка лидера клавиш
lvim.leader = "space"

-- Настройка горячих клавиш
lvim.keys.normal_mode = {
  ["<C-s>"] = ":w<cr>",  -- Сохранить файл
  ["gd"] = "<cmd>lua vim.lsp.buf.definition()<CR>",       -- Перейти к определению
  ["gr"] = "<cmd>lua vim.lsp.buf.references()<CR>",       -- Найти ссылки
  ["K"] = "<cmd>lua vim.lsp.buf.hover()<CR>",             -- Просмотр документации
  ["<leader>rn"] = "<cmd>lua vim.lsp.buf.rename()<CR>",   -- Переименовать
}

-- Дополнительные плагины
lvim.plugins = {
  { "mfussenegger/nvim-jdtls" },
  { "glepnir/lspsaga.nvim" },
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui" },
  { "simrat39/symbols-outline.nvim" },
  { "nvim-lua/plenary.nvim" },
}

-- Настройка LSP для Java
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.fn.stdpath('data') .. '/site/java/workspace-root/' .. project_name

local config = {
  cmd = {
    'java',
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '-javaagent:' .. vim.fn.stdpath('data') .. '/mason/packages/jdtls/lombok.jar',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', vim.fn.glob(vim.fn.stdpath('data') .. '/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar'),
    '-configuration', vim.fn.stdpath('data') .. '/mason/packages/jdtls/config_linux',
    '-data', workspace_dir,
  },

  root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }),

  settings = {
    java = {
      signatureHelp = { enabled = true },
      contentProvider = { preferred = 'fernflower' },
      configuration = {
        runtimes = {
          {
            name = "JavaSE-11",
            path = "/usr/lib/jvm/java-11-openjdk/",
          },
          {
            name = "JavaSE-17",
            path = "/usr/lib/jvm/java-17-openjdk/",
          },
        }
      }
    }
  },

  init_options = {
    bundles = {},
  },

  on_attach = function(client, bufnr)
    require('jdtls').setup_dap({ hotcodereplace = 'auto' })
    require('lvim.lsp').on_attach(client, bufnr)
  end,
}

-- Автоматически запускать jdtls для файлов Java
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "java" },
  callback = function()
    require('jdtls').start_or_attach(config)
  end,
})

-- Настройка LSPSaga
require('lspsaga').setup({})

-- Настройка DAP UI
require("dapui").setup()

-- Настройка symbols-outline
require("symbols-outline").setup()

-- Настройка автодополнения
local cmp = require('cmp')
cmp.setup {
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
  },
}

-- Настройка форматирования кода
local formatters = require("lvim.lsp.null-ls.formatters")
formatters.setup {
  {
    command = "google_java_format",
    filetypes = { "java" },
  },
}

-- Настройка filetype для файлов properties и yaml
vim.cmd([[
  autocmd BufRead,BufNewFile *.properties set filetype=conf
  autocmd BufRead,BufNewFile *.yml,*.yaml set filetype=yaml
]])
