.PHONY: all

PARSER := src/katt-blueprint-parser.pegjs
COMPILED_PARSER := lib/katt-blueprint-parser.js

all:
	@$(MAKE) -f .coffee.mk/coffee.mk $@
	@rm -rf lib/katt-blueprint-parser.pegjs
	@rm -rf lib/katt-blueprint-parser.js
	@$(MAKE) $(COMPILED_PARSER)

prepublish: clean lint all

$(COMPILED_PARSER): $(PARSER)
	@$(eval input := $<)
	@$(eval output := $@)
	@mkdir -p `dirname $(output)`
	@pegjs $(input) $(output)
