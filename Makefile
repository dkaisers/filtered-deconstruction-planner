PACKAGE := $(shell cat info.json | jq -r .name)
VERSION := $(shell cat info.json | jq -r .version)

OUT_DIR := $(PACKAGE)_$(VERSION)
MOD_DIR := $(shell cat .factorio_mods)

FILES := $(shell find . -type f -not -path './build/*' -not -path '*/\.*' -not -iname 'Makefile')

all: install

install: package
ifeq ($(MOD_DIR),)
	$(error MOD_DIR not set)
else
	rm -rf $(MOD_DIR)/$(PACKAGE)_*
	cp build/$(OUT_DIR).zip $(MOD_DIR)/$(OUT_DIR).zip
endif

package: clean
	mkdir -p build/$(OUT_DIR)
	rsync -R $(FILES) build/$(OUT_DIR)
	cd build && zip -r $(OUT_DIR).zip $(OUT_DIR)

clean:
	rm -rf build
