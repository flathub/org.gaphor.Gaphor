# Gaphor package for Flathub

Flathub is the central place for building and hosting Flatpak builds.

## Using the Flathub repository

To install Gaphor, use the following:

```
flatpak remote-add flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.gaphor.Gaphor
```

For more information and more applications see https://flathub.org.

## For maintainers

To make a new version run `make update VERSION=a.b.c`.

Check in the updated Appdata and `gaphor-bin.yaml` file and create a
pull request on https://github.com/flathub/org.gaphor.Gaphor.

***Note:*** *For issues related to Gaphor, open a ticket at https://github.com/gaphor/gaphor.*
