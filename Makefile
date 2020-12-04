SHELL := /bin/bash

.PHONY: create synth impl reg init

CCZE := $(shell command -v ccze 2> /dev/null)
ifndef CCZE
COLORIZE =
else
COLORIZE = | ccze -A
endif

IFTIME := $(shell command -v time 2> /dev/null)
ifndef IFTIME
TIMECMD =
else
TIMECMD = time -p
endif

export LD_LIBRARY_PATH=/opt/cactus/lib

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

all: create synth impl

init:
	git submodule update --init --recursive

reg: decode
	rm registers/*_PKG.vhd
	rm registers/*_PKG.yml
	rm registers/*_map.vhd
	cd regmap && make

decode:
	/opt/cactus/bin/uhal/tools/gen_ipbus_addr_decode address_tables/etl_test_fw.xml
	mv ipbus_decode_etl_test_fw.vhd registers/

create:
	$(TIMECMD) Hog/CreateProject.sh etl_test_fw $(COLORIZE)

synth:
	$(TIMECMD) Hog/LaunchWorkflow.sh -synth_only etl_test_fw $(COLORIZE)

impl:
	$(TIMECMD) Hog/LaunchWorkflow.sh -impl_only etl_test_fw $(COLORIZE)

clean:
	rm -rf VivadoProject/
	cd regmap && make clean_regmap
