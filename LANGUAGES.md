# Language tooling setup (macOS)

This config does **not** use `mason.nvim` — every LSP server, formatter and
debug adapter must already be on your `$PATH`. `:checkhealth` (see
`lua/health.lua`) only checks a handful of core binaries; everything below is
the full picture per language.

Run `brew install` commands with Homebrew already installed
(https://brew.sh).

## Prerequisites (all languages)

```sh
xcode-select --install        # C compiler, needed to build treesitter parsers
brew install git make unzip ripgrep
```

## Go

- **LSP**: `gopls`
- **DAP**: `dlv` (Delve), used by `nvim-dap-go`

```sh
brew install go
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
```

Make sure `$(go env GOPATH)/bin` (usually `~/go/bin`) is on your `$PATH`.

## Lua

- **LSP**: `lua_ls`
- **Formatter**: `stylua`

```sh
brew install lua-language-server stylua
```

## Jsonnet

- **LSP**: `jsonnet_ls` → binary `jsonnet-language-server` (Grafana's)

```sh
go install github.com/grafana/jsonnet-language-server@latest
```

## TypeScript / JavaScript

- **LSP**: `ts_ls` → binary `typescript-language-server` (needs `typescript` itself)

```sh
brew install node
npm install -g typescript typescript-language-server
```

## JSON / JSONC

- **LSP**: `jsonls` → binary `vscode-json-language-server`
- **Formatter**: `jq`

```sh
npm install -g vscode-langservers-extracted
brew install jq
```

## OCaml

- **LSP**: `ocamllsp` (OCaml LSP server)
- **Formatter**: `ocamlformat`

```sh
brew install opam
opam init
opam install ocaml-lsp-server ocamlformat
eval $(opam env)   # add to your shell rc so `ocamllsp`/`ocamlformat` are on PATH
```

## Python

- **LSP**: `pyright` (types/hover/go-to-def) + `ruff` (lint, hover disabled to avoid dupes)
- **Formatter**: `ruff format` (via conform.nvim, `ruff_format`)
- **DAP**: `debugpy`, via `nvim-dap-python`

```sh
brew install pyright ruff
```

`debugpy` cannot be `pip install`-ed into the Homebrew Python directly
(PEP 668 "externally managed environment"). This config points
`nvim-dap-python` at a dedicated venv instead of system `python3`:

```sh
python3 -m venv ~/.local/share/nvim-dap-venv
~/.local/share/nvim-dap-venv/bin/python -m pip install --upgrade pip debugpy
```

(`lua/pack/dap.lua` already references
`~/.local/share/nvim-dap-venv/bin/python` — no further config changes
needed once the venv exists.)

## Rust

- **LSP**: `rust-analyzer`
- **Formatter**: `rustfmt` (invoked by rust-analyzer's formatting request, same
  implicit `lsp_format = 'fallback'` path Go uses — no `conform.nvim` entry
  needed)
- **Linter**: `clippy`, wired up via rust-analyzer's `checkOnSave` (see
  `lua/pack/lsp.lua`)
- **DAP**: `codelldb`, wired up manually in `lua/pack/dap.lua` (no
  `nvim-dap-rust` wrapper plugin exists, unlike `nvim-dap-go`)

```sh
brew install rustup   # formula was renamed from rustup-init; installs the
                       # `rustup` binary, which bootstraps a default toolchain
                       # on first use (no separate `rustup-init` step needed)
rustup component add rust-analyzer rustfmt clippy
```

> **Known issue**: Homebrew's `rustup` build disables the proxy-binary
> self-install step that the official `rustup-init` installer does, so
> `~/.cargo/bin` (on `$PATH` by convention) can end up empty even though the
> toolchain is installed — `rustc`/`cargo`/`rust-analyzer` then resolve to
> nothing and rust-analyzer can't start in Neovim (`:LspInfo` shows no
> `rust_analyzer` client). Tracked upstream: rust-lang/rustup#4934 and
> Homebrew/homebrew-core#291044 (both closed as "use the documented
> `$PATH` setup"). The formula's own caveat has the real fix — add its
> keg-only `bin/` dir (which contains proper dispatch shims, not raw
> binaries) *ahead of* `~/.cargo/bin` in `$PATH`:
> ```sh
> export PATH="/opt/homebrew/opt/rustup/bin:$HOME/.cargo/bin:$PATH"
> ```
> (already added to `~/.zshrc`). Unlike symlinking toolchain binaries
> directly, these shims dispatch through `rustup` itself, so they keep
> working across `rustup default <toolchain>` switches.

`codelldb` has no Homebrew formula — download the macOS release from
https://github.com/vadimcn/codelldb/releases, unzip it, and place the
extracted `extension` directory's contents under
`~/.local/share/nvim-dap-adapters/codelldb/` so that
`~/.local/share/nvim-dap-adapters/codelldb/adapter/codelldb` exists
(`lua/pack/dap.lua` already points at that path).

## Treesitter-only languages (highlighting, no LSP/formatter configured)

`bash`, `c`, `diff`, `html`, `markdown`/`markdown_inline`, `php`, `query`,
`vim`/`vimdoc`, `yaml` — parsers are compiled automatically by
`nvim-treesitter` the first time you open a matching file, as long as the C
toolchain from the Prerequisites step is installed. No extra binaries
needed.

> Note: C/C++ have a treesitter parser but no LSP is enabled and
> `conform.nvim` explicitly skips format-on-save for `c`/`cpp`
> (`lua/pack/lsp.lua`). Add `clangd` to `vim.lsp.enable {}` if you want
> C/C++ language features.

## Quick install-everything (Homebrew + npm + opam + go)

```sh
brew install go lua-language-server stylua node jq opam pyright ruff
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install github.com/grafana/jsonnet-language-server@latest
npm install -g typescript typescript-language-server vscode-langservers-extracted
opam init && opam install ocaml-lsp-server ocamlformat && eval $(opam env)
python3 -m venv ~/.local/share/nvim-dap-venv
~/.local/share/nvim-dap-venv/bin/python -m pip install --upgrade pip debugpy
brew install rustup && rustup component add rust-analyzer rustfmt clippy
# codelldb: download macOS release from https://github.com/vadimcn/codelldb/releases
# and place the extracted `extension` dir contents under
# ~/.local/share/nvim-dap-adapters/codelldb/
```
