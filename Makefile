VERSION=$(shell git describe --tags)

build:
	go build -ldflags "-s -w -X main.Version=$(VERSION)" cmd/main.go

install:
	go install -ldflags "-s -w -X main.Version=$(VERSION)" cmd/main.go

release:
	CGO_ENABLED=0 gox --arch 'amd64 arm64' --os 'windows linux darwin' --output "dist/agents_{{.OS}}_{{.Arch}}/{{.Dir}}" -ldflags "-s -w -X main.Version=$(VERSION)" cmd/main.go
	zip      release/agents_windows_amd64.zip   dist/agents_windows_amd64/agents.exe -j
	tar zcvf release/agents_linux_amd64.tar.gz  -C dist/agents_linux_amd64/agents
	tar zcvf release/agents_linux_arm64.tar.gz  -C dist/agents_linux_arm64/agents
	tar zcvf release/agents_darwin_amd64.tar.gz -C dist/agents_darwin_amd64/agents
	tar zcvf release/agents_darwin_arm64.tar.gz -C dist/agents_darwin_arm64/agents

clean:
	rm -rf dist/
	rm -rf release/
