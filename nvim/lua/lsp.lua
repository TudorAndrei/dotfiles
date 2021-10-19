local pypath = vim.g.current_python_path
  -- Setup lspconfig.
  require('lspconfig').pyright.setup {
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
        settings = {
      pyright = { disableLanguageServices = false},
      python = {
          pythonPath = pypath,
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "workspace",
            useLibraryCodeForTypes = false,
            typeCheckingMode = true
        }
      }
    }
  }
