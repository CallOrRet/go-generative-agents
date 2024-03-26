.PHONY: clean build release

VERSION=0.0.1
REVISION=$(shell git rev-parse --short HEAD 2>/dev/null || echo "")

BIN=agents
SRC=./cmd

GO_ENV=CGO_ENABLED=0
GO_FLAGS=-ldflags "-s -w -X main.Version=$(VERSION) -X main.Revision=$(REVISION)"
GO=$(GO_ENV) $(shell which go)

build: generate
	@$(GO_ENV) $(GO) build $(GO_FLAGS) -o $(SRC)/$(BIN) $(SRC)


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

generate:
	@$(GO) install github.com/mitchellh/gox@latest
	@$(GO) mod tidy

clean:
	@rm -rf dist/
	@rm -rf package/*

all: clean build

