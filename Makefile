#
# To update the version, run:
#
#    make update VERSION=a.b.c
#

ID := org.gaphor.Gaphor
# Do not change version by hand!
VERSION := 2.24.0

BUILD := build
DIST := dist
REPO := $(BUILD)/repo

all: dist

dist: $(DIST)/$(ID).flatpak

update: clean version appdata
	$(MAKE) clean all

only-update: clean version appdata gaphor-bin.yaml

version:
	sed -i "s/^VERSION .*/VERSION := ${VERSION}/" Makefile

appdata:
	python3 update-appdata.py $(VERSION)

gaphor-bin.yaml: depends.sh
	bash depends.sh ${VERSION} > gaphor-bin.yaml

$(DIST)/$(ID).flatpak: $(REPO)
	mkdir -p dist
	flatpak build-bundle $(REPO) $@ $(ID)

$(REPO): gaphor-bin.yaml graphviz.yaml org.gaphor.Gaphor.yaml
	flatpak-builder --force-clean --repo=$@ $(BUILD)/build $(ID).yaml
	flatpak build-update-repo $(REPO)

dist-flatpaks: $(DIST)/$(ID).flatpak

clean:
	rm -f gaphor-bin.yaml
	rm -rf $(BUILD)
	rm -rf $(DIST)
	rm -rf .flatpak-builder

# for local testing:

setup:
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub org.gnome.Sdk//45
	flatpak install flathub org.gnome.Platform//45

install: $(DIST)/$(ID).flatpak
	flatpak install --user --reinstall $(DIST)/$(ID).flatpak

uninstall:
	flatpak uninstall org.gaphor.Gaphor//master
