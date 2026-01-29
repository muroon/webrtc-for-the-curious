.PHONY: serve stop clean

# Hugo server port
PORT ?= 1314

# Path to Hugo binary (use older version for theme compatibility)
HUGO_BIN ?= /tmp/hugo

# Start Hugo server
serve:
	$(HUGO_BIN) server --port $(PORT) --disableFastRender

# Start Hugo server in background
serve-bg:
	$(HUGO_BIN) server --port $(PORT) --disableFastRender &

# Stop Hugo server
stop:
	pkill -f "hugo server" || true

# Restart Hugo server
restart: stop serve

# Build static site
build:
	$(HUGO_BIN)

# Clean generated files
clean:
	rm -rf public/

# Download Hugo v0.126.3 (compatible with theme)
setup-hugo:
	@if [ ! -f /tmp/hugo ]; then \
		echo "Downloading Hugo v0.126.3..."; \
		curl -sL https://github.com/gohugoio/hugo/releases/download/v0.126.3/hugo_extended_0.126.3_darwin-universal.tar.gz -o /tmp/hugo.tar.gz; \
		tar -xzf /tmp/hugo.tar.gz -C /tmp; \
		rm /tmp/hugo.tar.gz; \
		echo "Hugo v0.126.3 installed at /tmp/hugo"; \
	else \
		echo "Hugo already exists at /tmp/hugo"; \
	fi

# Show help
help:
	@echo "Usage:"
	@echo "  make serve      - Start Hugo server (foreground)"
	@echo "  make serve-bg   - Start Hugo server (background)"
	@echo "  make stop       - Stop Hugo server"
	@echo "  make restart    - Restart Hugo server"
	@echo "  make build      - Build static site"
	@echo "  make clean      - Remove generated files"
	@echo "  make setup-hugo - Download Hugo v0.126.3"
	@echo ""
	@echo "Options:"
	@echo "  PORT=1313       - Change server port (default: 1314)"
