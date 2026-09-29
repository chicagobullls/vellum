.PHONY: all help test run build lint clean web-demo

help:
	@echo "Vellum Makefile Commands:"
	@echo "  make test      - Run all unit and algorithm tests"
	@echo "  make run       - Run Flutter app on connected device / simulator"
	@echo "  make lint      - Analyze Flutter code for linter warnings"
	@echo "  make web-demo  - Open the interactive Dark Academia Web Demo in browser"
	@echo "  make clean     - Clean build artifacts"

test:
	flutter test

run:
	flutter run

lint:
	flutter analyze

web-demo:
	open web_demo/index.html

clean:
	flutter clean
