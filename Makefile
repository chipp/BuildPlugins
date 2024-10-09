bin/update:
	swift build -c release --package-path tools/update
	install $$(swift build -c release --package-path tools/update --show-bin-path)/update ./bin/

update: bin/update
	./bin/update .
