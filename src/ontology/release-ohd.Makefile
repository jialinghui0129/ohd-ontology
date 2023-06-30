MAKEFILE=					release-ohd.Makefile
URIBASE=					http://purl.obolibrary.org/obo
ONT=						ohd
ONTBASE=                    $(URIBASE)/$(ONT)
EDIT_FORMAT=                owl
SRC=                        $(ONT)-edit.$(EDIT_FORMAT)
RELEASEDIR=                 ../..
MIRRORDIR=                  mirror
IMPORTDIR=                  imports
SUBSETDIR=                  subsets
TMPDIR=                     tmp
SCRIPTSDIR=                 ../scripts
SPARQLDIR =                 ../sparql
COMPONENTSDIR =             components
CATALOG=                    catalog-v001.xml
ROBOT=                      robot --catalog $(CATALOG)
RELEASEDIR=                 ../..
TODAY ?=                    $(shell date +%Y-%m-%d)
VERSION=                    $(TODAY)
ANNOTATE_ONTOLOGY_VERSION= 	annotate -V $(ONTBASE)/releases/$(VERSION)/$@ --annotation owl:versionInfo $(VERSION)
OTHER_SRC =
RELEASE_ARTEFACTS=          $(ONT).owl $(ONT)-base.owl $(ONT)-non-classified.owl

$(TMPDIR) $(MIRRORDIR) $(IMPORTDIR):
	mkdir -p $@

# ----------------------------------------
# Release artifacts
# ----------------------------------------

.PHONY: all release clean
all: $(RELEASE_ARTEFACTS)

release: $(RELEASE_ARTEFACTS)
	@echo "\n** releasing $^ **"
	cp $^ $(RELEASEDIR)

clean:
	rm -f $(RELEASE_ARTEFACTS)

$(ONT).owl: $(SRC)
	@echo "\n** building $@ **"
	$(ROBOT) \
		merge -i $< \
	    reason --reasoner hermit --annotate-inferred-axioms true --exclude-duplicate-axioms true \
	    annotate \
	        --ontology-iri $(URIBASE)/$@ \
	        --version-iri $(ONTBASE)/releases/$(VERSION)/$@ \
	        --annotation owl:versionInfo $(VERSION) \
	    reduce \
	    convert -o $@.tmp.owl && mv $@.tmp.owl $@
	    
$(ONT)-base.owl: $(SRC)
	$(ROBOT) \
		remove --input $< --select imports --trim false \
	    annotate --link-annotation http://purl.org/dc/elements/1.1/type http://purl.obolibrary.org/obo/IAO_8000001 \
	    --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) \
	    --output $@.tmp.owl && mv $@.tmp.owl $@

$(ONT)-non-classified.owl: $(SRC)
	$(ROBOT) merge --input $< \
	    annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --annotation oboInOwl:date "$(OBODATE)" \
	    --output $@.tmp.owl && mv $@.tmp.owl $@

# ----------------------------------------
# ontology imports
# ----------------------------------------
.PHONY: refresh-imports no-mirror-refresh-imports

IMP=true # Global parameter to bypass import generation
MIR=true # Global parameter to bypass mirror generation
IMP_LARGE=true # Global parameter to bypass handling of large imports

IMPORTS = omo ro iao caro fma ecto obi omrse ogms

IMPORT_ROOTS = $(patsubst %, $(IMPORTDIR)/%_import, $(IMPORTS))
IMPORT_OWL_FILES = $(foreach n,$(IMPORT_ROOTS), $(n).owl)
IMPORT_FILES = $(IMPORT_OWL_FILES)


# ----------------------------------------
# Mirroring upstream ontologies
# ----------------------------------------
.PHONY: all-mirrors zip-mirrors download-mirrors

all-mirrors: download-mirrors zip-mirrors

zip-mirrors:
	@echo "*** zipping $(patsubst %, $(MIRRORDIR)/%.owl.gz, $(IMPORTS)) ***" # testing
	make -f $(MAKEFILE) $(patsubst %, $(MIRRORDIR)/%.owl.gz, $(IMPORTS)) -B

download-mirrors:
	@echo "*** initiate download $(patsubst %, $(MIRRORDIR)/%.owl, $(IMPORTS)) ***" # testing
	make -f $(MAKEFILE) $(patsubst %, mirror-%, $(IMPORTS))

$(MIRRORDIR)/%.owl: | $(MIRRORDIR)
	curl -L $(URIBASE)/$*.owl --create-dirs -o $@ --retry 4 --max-time 200

mirror-%:
	make -f $(MAKEFILE) $(MIRRORDIR)/$*.owl -B

mirror-omo:
	@echo "--- downloading $@" # testing
	curl -L $(URIBASE)/omo.owl --create-dirs -o $(TMPDIR)/omo.owl --retry 4 --max-time 200

# --- gzip ontology mirrors ---

$(MIRRORDIR)/omo.owl.gz:
	gzip -fk $(MIRRORDIR)/omo.owl

$(MIRRORDIR)/ro.owl.gz: 
	gzip -fk $(MIRRORDIR)/ro.owl

$(MIRRORDIR)/iao.owl.gz: 
	gzip -fk $(MIRRORDIR)/iao.owl

$(MIRRORDIR)/caro.owl.gz: 
	gzip -fk $(MIRRORDIR)/caro.owl

$(MIRRORDIR)/fma.owl.gz: 
	gzip -fk $(MIRRORDIR)/fma.owl

$(MIRRORDIR)/ecto.owl.gz: 
	gzip -fk $(MIRRORDIR)/ecto.owl

$(MIRRORDIR)/obi.owl.gz: 
	gzip -fk $(MIRRORDIR)/obi.owl

$(MIRRORDIR)/omrse.owl.gz: 
	gzip -fk $(MIRRORDIR)/omrse.owl

$(MIRRORDIR)/ogms.owl.gz: 
	gzip -fk $(MIRRORDIR)/ogms.owl