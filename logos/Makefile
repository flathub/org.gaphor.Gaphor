
ICON_FILES = \
	gaphor-24x24.png \
	gaphor-48x48.png \
	gaphor-96x96.png \
	gaphor-256x256.png

LOGO = org.gaphor.Gaphor.svg

all: $(ICON_FILES)

gaphor-24x24.png: $(LOGO)
	rsvg-convert -h 24 $(LOGO) > $@

gaphor-48x48.png: $(LOGO)
	rsvg-convert -h 48 $(LOGO) > $@

gaphor-96x96.png: $(LOGO)
	rsvg-convert -h 96 $(LOGO) > $@

gaphor-256x256.png: $(LOGO)
	rsvg-convert -h 256 $(LOGO) > $@

