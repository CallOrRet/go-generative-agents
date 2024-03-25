VERSION=$(shell git describe --tags)

build:
	go build -ldflags "-s -w -X main.Version=$(VERSION)" -o cmd/agents cmd/main.go


release:
	cd ./cmd && CGO_ENABLED=0 gox --arch 'amd64 arm64 386' --os 'linux' --output "../dist/agents_{{.OS}}_{{.Arch}}/agents" -ldflags "-s -w -X main.Version=$(VERSION)"
	cd ./cmd && CGO_ENABLED=0 gox --arch 'amd64 arm64' --os 'darwin' --output "../dist/agents_{{.OS}}_{{.Arch}}/agents" -ldflags "-s -w -X main.Version=$(VERSION)"
	cd ./cmd && CGO_ENABLED=0 gox --arch 'amd64 386' --os 'windows' --output "../dist/agents_{{.OS}}_{{.Arch}}/agents" -ldflags "-s -w -X main.Version=$(VERSION)"
	tar zcvf package/agents_windows_amd64.tar.gz   -C dist/agents_windows_amd64/ agents.exe
	tar zcvf package/agents_windows_386.tar.gz   -C dist/agents_windows_386/ agents.exe
	tar zcvf package/agents_linux_amd64.tar.gz  -C dist/agents_linux_amd64/ agents
	tar zcvf package/agents_linux_arm64.tar.gz  -C dist/agents_linux_arm64/ agents
	tar zcvf package/agents_linux_386.tar.gz  -C dist/agents_linux_386/ agents
	tar zcvf package/agents_darwin_amd64.tar.gz -C dist/agents_darwin_amd64/ agents
	tar zcvf package/agents_darwin_arm64.tar.gz -C dist/agents_darwin_arm64/ agents

clean:
	rm -rf dist/
	rm -rf package/*
