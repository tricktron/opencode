workspace "opencode" {

    model {
        developer = person "Developer" "Uses opencode CLI/TUI for AI-assisted coding"

        opencode = softwareSystem "opencode" "Local-first AI coding assistant" {
            cli = container "CLI / TUI" "Yargs commands, TUI renderer, worker thread" "TypeScript / Bun"
            server = container "HTTP Server" "Hono REST API + SSE event stream" "TypeScript / Hono"
            agent = container "Agent" "LLM orchestration loop, tool dispatch, session processing" "TypeScript / Effect + Vercel AI SDK"
            storage = container "SQLite DB" "Sessions, messages, parts, accounts, projects" "SQLite / Drizzle"
            mcp = container "MCP Client" "Model Context Protocol client for external tool servers" "TypeScript"
            lsp = container "LSP Manager" "Language Server Protocol client pool" "TypeScript"
            npm = container "NPM Manager" "Plugin installation via @npmcli/arborist" "TypeScript"
            sdk = container "JS SDK" "Generated TypeScript client for opencode HTTP API" "TypeScript"
        }

        webapp = softwareSystem "Web App" "SolidJS SPA served from app.opencode.ai or embedded" {
            app = container "SPA" "SolidJS UI, connects to local server via HTTP/SSE" "SolidJS"
        }

        desktop = softwareSystem "Desktop App" "Tauri / Electron wrapper around opencode server + web UI" {
            shell = container "Desktop Shell" "Native window, sidecar opencode process" "Tauri / Electron"
        }

        cloud = softwareSystem "opencode Cloud" "Optional sharing and enterprise features" {
            shareApi = container "Share API" "Cloudflare Worker for session sharing" "TypeScript / Hono"
            syncServer = container "Sync Server" "Durable Object for WebSocket-based session sync" "Cloudflare DO"
            r2 = container "R2 Bucket" "Persistent shared session JSON" "Cloudflare R2"
        }

        console = softwareSystem "Console" "SaaS web console for teams, billing, auth" {
            consoleApp = container "Console App" "SolidStart SSR app" "SolidStart"
            consoleCore = container "Console Core" "Domain logic, Drizzle schemas" "TypeScript"
            consoleDb = container "Console DB" "MySQL / Cloudflare D1" "MySQL"
        }

        llmProviders = softwareSystem "LLM Providers" "Anthropic, OpenAI, Google, AWS Bedrock, Azure, etc." {
            tags "External"
        }
        github = softwareSystem "GitHub" "Source control, PRs, Actions" {
            tags "External"
        }
        mcpServers = softwareSystem "MCP Servers" "External tool servers via Model Context Protocol" {
            tags "External"
        }
        lspServers = softwareSystem "LSP Servers" "Language servers for code intelligence" {
            tags "External"
        }
        npmRegistry = softwareSystem "npm Registry" "Package registry for plugin installation" {
            tags "External"
        }

        # System Context relationships
        developer -> opencode "Uses" "CLI / TUI / Web UI"
        opencode -> llmProviders "Streams prompts and responses" "HTTPS"
        opencode -> github "Reads repos, creates PRs" "HTTPS"
        opencode -> mcpServers "Invokes tools" "stdio / SSE / HTTP"
        opencode -> lspServers "Code intelligence queries" "stdio / TCP"
        opencode -> cloud "Shares sessions (optional)" "HTTPS / WebSocket"
        opencode -> npmRegistry "Installs plugins" "HTTPS"
        webapp -> opencode "Calls API, subscribes to events" "HTTP / SSE"
        desktop -> opencode "Sidecar process" "HTTP / SSE"
        console -> cloud "Manages teams, billing" "HTTPS"

        # Container relationships
        cli -> server "Starts and calls" "In-process / HTTP"
        cli -> agent "Spawns via worker thread" "Rpc (postMessage)"
        server -> agent "Dispatches prompts" "Direct import"
        agent -> storage "Reads/writes via SyncEvent projectors" "Drizzle / SQLite"
        agent -> mcp "Invokes MCP tools" "stdio / SSE"
        agent -> lsp "Queries code intelligence" "stdio / TCP"
        server -> storage "Reads for API responses" "Drizzle / SQLite"
        npm -> npmRegistry "Fetches packages" "HTTPS"
        sdk -> server "Generated HTTP client" "HTTP"
        app -> server "REST + SSE" "HTTP"
        shell -> server "Sidecar HTTP" "HTTP"
        shareApi -> syncServer "Routes share requests" "Internal"
        syncServer -> r2 "Persists shared sessions" "R2 API"
        consoleApp -> consoleCore "Domain logic" "Direct import"
        consoleCore -> consoleDb "Reads/writes" "Drizzle / MySQL"
    }

    views {
        systemContext opencode "SystemContext" {
            include *
            autoLayout
        }

        container opencode "Containers" {
            include *
            autoLayout
        }

        theme default

        styles {
            element "External" {
                background #999999
                color #ffffff
            }
        }
    }

}
