BUILD_DEPENDS := poetry setuptools

ID := org.gaphor.Gaphor

BUILD := build
DIST := dist
REPO := $(BUILD)/repo

all: $(REPO) dist-flatpaks

install: $(BUILD)/$(ID).flatpak
	flatpak install --reinstall --assumeyes $(BUILD)/$(ID).flatpak

$(BUILD)/$(ID).flatpak: $(REPO)
	flatpak build-bundle $(REPO) $@ $(ID)

$(REPO): build-depends.yaml lockfile-depends.yaml org.gaphor.Gaphor.yaml
	flatpak-builder --force-clean --repo=$@ $(BUILD)/build $(ID).yaml
	flatpak build-update-repo $(REPO)

$(DIST):
	mkdir -p $(DIST)

$(DIST)/%.flatpak: $(BUILD)/%.flatpak $(DIST)
	cp $< $@

dist-flatpaks: $(DIST)/$(ID).flatpak

clean:
	rm -rf $(BUILD)
	rm -rf $(DIST)
	rm -rf .flatpak-builder

setup:
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub org.gnome.Sdk//3.34
	flatpak install flathub org.gnome.Platform//3.34
