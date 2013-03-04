# ===== Directories =====

SRC_DIR              = src
LIB_DIR              = lib
DIST_DIR             = dist
NODE_MODULES_DIR     = node_modules
NODE_MODULES_BIN_DIR = $(NODE_MODULES_DIR)/.bin

# ===== Files =====

PARSER_SRC_FILE = $(SRC_DIR)/katt-blueprint-parser.pegjs
PARSER_OUT_FILE = $(LIB_DIR)/katt-blueprint-parser.js

AST_SRC_FILE = $(SRC_DIR)/ast.coffee
AST_OUT_FILE = $(LIB_DIR)/ast.js

VERSION_FILE = VERSION

# ===== Executables =====

COFFEE = $(NODE_MODULES_BIN_DIR)/coffee
PEGJS  = $(NODE_MODULES_BIN_DIR)/pegjs
MOCHA  = $(NODE_MODULES_BIN_DIR)/mocha

# ===== Targets =====

all: build

$(LIB_DIR):
	mkdir -p $(LIB_DIR)

$(DIST_DIR):
	mkdir -p $(DIST_DIR)

$(AST_OUT_FILE): $(LIB_DIR) $(AST_SRC_FILE)
	$(COFFEE) --compile --bare --output $(LIB_DIR) $(AST_SRC_FILE)

$(PARSER_OUT_FILE): $(LIB_DIR) $(PARSER_SRC_FILE) $(AST_OUT_FILE)
	$(PEGJS) $(PARSER_SRC_FILE) $(PARSER_OUT_FILE)
	echo "" >> $(PARSER_OUT_FILE)
	echo "module.exports.ast = require(\"./ast\");" >> $(PARSER_OUT_FILE)

# Build the library
build: $(PARSER_OUT_FILE)

# Run the test suite
test: build
	$(MOCHA)

.PHONY: build test
.SILENT: build test $(LIB_DIR) $(DIST_DIR) $(AST_OUT_FILE) $(PARSER_OUT_FILE)
