##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


##@ Development

VERSION=0.0.1
REVISION=$(shell git rev-parse --short HEAD 2>/dev/null || echo "")

BIN=agents
SRC=./cmd

GO=$(shell which go)
GO_ENV=CGO_ENABLED=0
GO_FLAGS=-ldflags "-s -w -X main.Version=$(VERSION) -X main.Revision=$(REVISION)"

.PHONY: test
TEST_ARGS ?= -v
TEST_TARGETS ?= ./...
test: ## Test the Go modules within this package.
	@ echo ▶️ go test $(TEST_ARGS) $(TEST_TARGETS)
	go test $(TEST_ARGS) $(TEST_TARGETS)
	@ echo ✅ success!


.PHONY: lint
LINT_TARGETS ?= ./...
lint: ## Lint Go code with the installed golangci-lint
	@ echo "▶️ golangci-lint run"
	golangci-lint run $(LINT_TARGETS)
	@ echo "✅ golangci-lint run"

.PHONY: build
build: generate
	@$(GO) build $(GO_FLAGS) -o $(BIN) $(SRC)

.PHONY: release
release: generate
	@cd $(SRC) && $(GO_ENV) gox --arch 'amd64 arm64 386' --os 'linux' --output "../dist/$(BIN)_{{.OS}}_{{.Arch}}/$(BIN)" $(GO_FLAGS)
	@cd $(SRC) && $(GO_ENV) gox --arch 'amd64 arm64' --os 'darwin' --output "../dist/$(BIN)_{{.OS}}_{{.Arch}}/$(BIN)" $(GO_FLAGS)
	@cd $(SRC) && $(GO_ENV) gox --arch 'amd64 386' --os 'windows' --output "../dist/$(BIN)_{{.OS}}_{{.Arch}}/$(BIN)" $(GO_FLAGS)
	@tar zcvf package/$(BIN)_windows_amd64.tar.gz   -C dist/$(BIN)_windows_amd64/ $(BIN).exe
	@tar zcvf package/$(BIN)_windows_386.tar.gz   -C dist/$(BIN)_windows_386/ $(BIN).exe
	@tar zcvf package/$(BIN)_linux_amd64.tar.gz  -C dist/$(BIN)_linux_amd64/ $(BIN)
	@tar zcvf package/$(BIN)_linux_arm64.tar.gz  -C dist/$(BIN)_linux_arm64/ $(BIN)
	@tar zcvf package/$(BIN)_linux_386.tar.gz  -C dist/$(BIN)_linux_386/ $(BIN)
	@tar zcvf package/$(BIN)_darwin_amd64.tar.gz -C dist/$(BIN)_darwin_amd64/ $(BIN)
	@tar zcvf package/$(BIN)_darwin_arm64.tar.gz -C dist/$(BIN)_darwin_arm64/ $(BIN)

.PHONY: generate
generate:
	@$(GO) install github.com/mitchellh/gox@latest
	@$(GO) mod tidy

.PHONY: clean
clean:
	@$(GO) clean ./...
	@rm -rf $(BIN)
	@rm -rf dist/
	@rm -rf package/*

all: clean build

