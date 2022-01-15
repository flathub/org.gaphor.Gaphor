#
# To update the version, run:
#
#    make update VERSION=a.b.c
#

ID := org.gaphor.Gaphor
# Do not change version by hand!
VERSION := 2.8.0

BUILD := build
DIST := dist
REPO := $(BUILD)/repo

all: dist

dist: $(DIST)/$(ID).flatpak

update: clean version appdata
	$(MAKE) clean all

version:
	sed -i "s/^VERSION .*/VERSION := ${VERSION}/" Makefile

appdata:
	sed -i '/  <releases>/a \ \ \ \ <release version="$(VERSION)" date="$(shell date +%Y-%m-%d)"/>' share/org.gaphor.Gaphor.appdata.xml

gaphor-bin.yaml:
	bash depends.sh ${VERSION} > gaphor-bin.yaml

$(DIST)/$(ID).flatpak: $(REPO)
	mkdir -p dist
	flatpak build-bundle $(REPO) $@ $(ID)

$(REPO): gaphor-bin.yaml org.gaphor.Gaphor.yaml
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
	flatpak install flathub org.gnome.Sdk//41
	flatpak install flathub org.gnome.Platform//41

install: $(DIST)/$(ID).flatpak
	flatpak install --reinstall $(DIST)/$(ID).flatpak
