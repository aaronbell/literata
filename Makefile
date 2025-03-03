SOURCES=$(shell yq e '.sources.[] | sub("^","sources/")' sources/config.yaml )
FAMILY=$(shell yq e '.familyName' sources/config.yaml )

help:
	@echo "###"
	@echo "# Build targets for $(FAMILY)"
	@echo "###"
	@echo
	@echo "  make build: Builds the fonts and places them in the fonts/ directory"
	@echo "  make test:  Tests the fonts with fontbakery"
	@echo "  make proof: Creates HTML proof documents in the proof/ directory"
	@echo

build: build.stamp sources/config.yaml $(SOURCES)

venv: venv/touchfile

build.stamp: venv
	. venv/bin/activate; python3 sources/preprocess.py; gftools builder sources/config.yaml; gftools builder sources/config_static.yaml; python3 sources/postprocessing.py && touch build.stamp
	mv fonts/variable/Literata[opsz,wght].ttf.fix fonts/variable/Literata[opsz,wght].ttf
	mv fonts/variable/Literata-Italic[opsz,wght].ttf.fix fonts/variable/Literata-Italic[opsz,wght].ttf

venv/touchfile: requirements.txt
	test -d venv || python3 -m venv venv
	. venv/bin/activate; pip install -Ur requirements.txt
	touch venv/touchfile

test: venv build.stamp
	. venv/bin/activate; fontbakery check-googlefonts --html fontbakery-report.html --ghmarkdown fontbakery-report.md $(shell find fonts -type f)

proof: venv build.stamp
	. venv/bin/activate; gftools gen-html proof $(shell find fonts/ttf -type f) -o proof

clean:
	rm -rf venv
	rm -rf sources/master_ufo
	rm -rf sources/designspace/instance_UFO
	find -iname "*.pyc" -delete
