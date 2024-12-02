bin/update:
	swift build -c release --package-path tools/update
	mkdir -p ./bin
	install $$(swift build -c release --package-path tools/update --show-bin-path)/update ./bin/
	rm -rf tools/update/.build

update: bin/update
	./bin/update .
