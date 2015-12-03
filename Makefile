PANDOC = pandoc
LATEX = platex
DVI_PDF = dvipdfmx

RM = rm -rf
MKDIR = mkdir -p
CP = cp -r

MD_FMT = markdown_github

ARTS_DIR = arts
BASE_DIR = base
STY_DIR = sty

TMP_DIR = tmp
OUT_DIR = out

MDSOURCES := $(wildcard $(ARTS_DIR)/*.md)
ATEXSOURCES := $(wildcard $(ARTS_DIR)/*.tex)
BTEXSOURCES := $(wildcard $(BASE_DIR)/*.tex)
STYSOURCES := $(wildcard $(STY_DIR)/*.sty)
INDEX_SOURCE = $(TMP_DIR)/index.tex

MAIN_PREFIX = main

TARGET = $(OUT_DIR)/$(MAIN_PREFIX).pdf
TARGET_RESOURCE = $(TMP_DIR)/$(MAIN_PREFIX).dvi

TARGETS_MDTEX := $(MDSOURCES:$(ARTS_DIR)/%.md=$(TMP_DIR)/%.tex)
TARGETS_ATEX := $(ATEXSOURCES:$(ARTS_DIR)/%.tex=$(TMP_DIR)/%.tex)
TARGETS_BTEX := $(BTEXSOURCES:$(BASE_DIR)/%.tex=$(TMP_DIR)/%.tex)
TARGETS_STY := $(STYSOURCES:$(STY_DIR)/%.sty=$(TMP_DIR)/%.sty)

.PHONY: all
all: $(TARGET)

$(TARGET): $(TARGET_RESOURCE)
	@[ -d $(OUT_DIR) ] || $(MKDIR) $(OUT_DIR)
	$(DVI_PDF) -o $@ $<

$(TARGET_RESOURCE): $(TARGETS_MDTEX) $(TARGETS_ATEX) $(TARGETS_BTEX) $(TARGETS_STY)
	cat $(INDEX_SOURCE) >> $(TMP_DIR)/$(MAIN_PREFIX).tex
	echo | $(LATEX) \
      -output-directory=$(TMP_DIR) \
      -halt-on-error \
      $(TMP_DIR)/$(MAIN_PREFIX).tex

$(TARGETS_MDTEX): $(TMP_DIR)/%.tex: $(ARTS_DIR)/%.md
	@[ -d $(TMP_DIR) ] || $(MKDIR) $(TMP_DIR)
	$(PANDOC) -f $(MD_FMT) -t latex $< -o $@

$(TARGETS_ATEX): $(TMP_DIR)/%.tex: $(ARTS_DIR)/%.tex
	@[ -d $(TMP_DIR) ] || $(MKDIR) $(TMP_DIR)
	$(CP) $< $@

$(TARGETS_BTEX): $(TMP_DIR)/%.tex: $(BASE_DIR)/%.tex
	@[ -d $(TMP_DIR) ] || $(MKDIR) $(TMP_DIR)
	$(CP) $< $@

$(TARGETS_STY): $(TMP_DIR)/%.sty: $(STY_DIR)/%.sty
	@[ -d $(TMP_DIR) ] || $(MKDIR) $(TMP_DIR)
	$(CP) $< $@

.PHONY: clean
clean:
	$(RM) $(TMP_DIR)

.PHONY: remove
remove: clean
	$(RM) $(OUT_DIR)
