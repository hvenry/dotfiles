return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    "williamboman/mason-lspconfig.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    -- ===== Diagnostics UI (global) =====
    vim.diagnostic.config({
      virtual_text = true,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.HINT] = "",
          [vim.diagnostic.severity.INFO] = "",
        },
      },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
    })

    -- ===== Keymaps (on attach) =====
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
      callback = function(ev)
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = ev.buf, desc = desc })
        end
        map("gr", "<cmd>Telescope lsp_references<CR>", "References")
        map("gd", "<cmd>Telescope lsp_definitions<CR>", "Definitions")
        map("gi", "<cmd>Telescope lsp_implementations<CR>", "Implementations")
        map("gt", "<cmd>Telescope lsp_type_definitions<CR>", "Type definitions")
        map("gb", "<C-o>", "Go Back")
        map("<leader>gf", "<C-i>", "Go Forward")
        map("<leader>rn", vim.lsp.buf.rename, "Rename")
        map("<leader>d", vim.diagnostic.open_float, "Line Diagnostics")
        map("K", vim.lsp.buf.hover, "Hover Doc")
        map("<leader>rs", ":LspRestart<CR>", "Restart LSP")
      end,
    })

    -- ===== Helpers for pure vim.lsp.start =====
    local capabilities = require("cmp_nvim_lsp").default_capabilities()
    local util = require("lspconfig.util") -- root_dir helpers only

    local function resolve_root(root_dir, bufnr)
      if type(root_dir) == "function" then
        local fname = vim.api.nvim_buf_get_name(bufnr)
        return root_dir(fname)
      end
      return root_dir
    end

    local function start_on_filetypes(opts)
      local filetypes = opts.filetypes
      opts.filetypes = nil

      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function(args)
          local conf = {
            name = opts.name,
            cmd = type(opts.cmd) == "function" and opts.cmd(args.buf) or opts.cmd,
            capabilities = capabilities,
            flags = { debounce_text_changes = 150 },
            on_attach = opts.on_attach,
            init_options = opts.init_options,
            settings = opts.settings,
            single_file_support = opts.single_file_support,
          }
          conf.root_dir = resolve_root(opts.root_dir, args.buf)
          vim.lsp.start(conf)
        end,
      })
    end

    -- ===== Servers =====

    -- clangd
    start_on_filetypes({
      name = "clangd",
      cmd = { "clangd" },
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      root_dir = util.root_pattern("compile_commands.json", "compile_flags.txt", ".git"),
    })

    -- cssls (vscode-css-language-server)
    start_on_filetypes({
      name = "cssls",
      cmd = { "vscode-css-language-server", "--stdio" },
      filetypes = { "css", "scss", "less" },
      root_dir = util.root_pattern("package.json", ".git"),
    })

    -- emmet_ls
    start_on_filetypes({
      name = "emmet_ls",
      cmd = { "emmet-ls", "--stdio" },
      filetypes = {
        "html",
        "css",
        "scss",
        "sass",
        "less",
        "javascriptreact",
        "typescriptreact",
        "vue",
        "svelte",
      },
      root_dir = util.root_pattern("package.json", ".git"),
    })

    -- html (vscode-html-language-server)
    start_on_filetypes({
      name = "html",
      cmd = { "vscode-html-language-server", "--stdio" },
      filetypes = { "html" },
      root_dir = util.root_pattern("package.json", ".git"),
    })

    -- lua_ls
    start_on_filetypes({
      name = "lua_ls",
      cmd = { "lua-language-server" },
      filetypes = { "lua" },
      root_dir = util.root_pattern(".luarc.json", ".luarc.jsonc", ".git"),
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
        },
      },
    })

    -- pyright
    start_on_filetypes({
      name = "pyright",
      cmd = { "pyright-langserver", "--stdio" },
      filetypes = { "python" },
      root_dir = util.root_pattern(
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        ".git"
      ),
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            autoImportCompletions = true,
          },
        },
      },
    })

    -- tailwindcss
    start_on_filetypes({
      name = "tailwindcss",
      cmd = { "tailwindcss-language-server", "--stdio" },
      filetypes = {
        "html",
        "css",
        "scss",
        "sass",
        "less",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "svelte",
        "vue",
        "astro",
      },
      root_dir = util.root_pattern(
        "tailwind.config.js",
        "tailwind.config.cjs",
        "tailwind.config.ts",
        "postcss.config.js",
        "package.json",
        ".git"
      ),
      settings = { tailwindCSS = { experimental = { classRegex = {} } } },
    })

    -- typescript (ts_ls)
    start_on_filetypes({
      name = "ts_ls",
      cmd = { "typescript-language-server", "--stdio" },
      filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
      root_dir = util.root_pattern("tsconfig.json", "package.json", ".git"),
      init_options = { hostInfo = "neovim" },
    })

    -- qmlls (prefer Arch system qmlls6; fall back to qmlls)
    local function find_qmlls_exe()
      local candidates = {
        "/usr/bin/qmlls6",
        "qmlls6", -- Arch system names
        "/usr/sbin/qmlls6", -- some setups place it here
        "/usr/bin/qmlls",
        "qmlls", -- fallbacks (Mason/other distros)
      }
      for _, exe in ipairs(candidates) do
        if vim.fn.executable(exe) == 1 then
          return exe
        end
      end
      return nil
    end

    local function find_qmlls_ini(startpath)
      local dir = util.search_ancestors(startpath, function(path)
        local ini = util.path.join(path, ".qmlls.ini")
        return util.path.exists(ini) and path or nil
      end)
      if dir then
        return util.path.join(dir, ".qmlls.ini")
      end
      -- personal fallback (keep if useful)
      local user_ini = vim.fn.expand("~/dotfiles/quickshell/.config/quickshell/build/.qmlls.ini")
      if util.path.exists(user_ini) then
        return user_ini
      end
      return nil
    end

    start_on_filetypes({
      name = "qmlls",
      cmd = function(bufnr)
        local exe = find_qmlls_exe()
        if not exe then
          vim.notify(
            "qmlls not found (tried qmlls6/qmlls). Install qt6-declarative/qt6-languageserver.",
            vim.log.levels.ERROR
          )
          return { "qmlls" } -- dummy; lsp.start will no-op if not executable
        end
        local bufdir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":p:h")
        local ini = find_qmlls_ini(bufdir)
        return ini and { exe, "--ini", ini } or { exe, "-E" }
      end,
      filetypes = { "qml", "qmljs", "qmltypes" },
      single_file_support = true,
      root_dir = util.root_pattern(".qmlls.ini", "CMakeLists.txt", "package.json", ".git"),
      on_attach = function(_, bufnr)
        -- tighten diagnostics just for QML buffers
        vim.diagnostic.config({
          virtual_text = { severity = { min = vim.diagnostic.severity.ERROR } },
          signs = { severity = { min = vim.diagnostic.severity.ERROR } },
          underline = { severity = { min = vim.diagnostic.severity.ERROR } },
        }, bufnr)
      end,
    })
  end,
}
