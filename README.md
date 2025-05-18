# 📦 Custom Nix Packages

[![Build & Push to Cachix](https://github.com/ohheyrj/custom-nix-pkgs/actions/workflows/build.yml/badge.svg)](https://github.com/ohheyrj/custom-nix-pkgs/actions/workflows/build.yml)

This repository contains a curated collection of custom Nix packages for macOS (Darwin), built to fill gaps in the official [nixpkgs](https://github.com/NixOS/nixpkgs) repository.

These packages were created because they are **not currently available in `nixpkgs`**, or are pending review in upstream pull requests. The long-term goal is to contribute each package **back to upstream** once they meet the necessary quality and packaging standards.

Packages are grouped by category, and each entry includes metadata such as:

- ✅ Version
- 🔗 Homepage & changelog
- 🖥️ Supported platforms
- 🛡️ License
- 📦 PR & tracker links (if submitted upstream)


<!--table:start-->

## 📦 Packages by Category



### 🗂️ Table of Contents

- [💬 Chat](#chat)

- [☁️ Cloud](#cloud)

- [🛠️ Dev-tools](#dev-tools)

- [🎮 Gaming](#gaming)

- [🎵 Media](#media)

- [📦 Other](#other)



## 💬 Chat


### 🧰 chatterino `v2.5.3`
- 💡 **Description:** Chat client for Twitch
- 🛡️ **License:** mit
- 🖥️ **Platforms:** darwin
- 🌐 **Homepage:** [chatterino Website](https://chatterino.com)
- 📄 **Changelog:** [CHANGELOG](https://github.com/Chatterino/chatterino2/blob/master/CHANGELOG.md)



## ☁️ Cloud


### 🧰 proton-drive `v2.3.0`
- 💡 **Description:** Proton Drive Mac Client
- 🛡️ **License:** gpl3
- 🖥️ **Platforms:** darwin
- 🌐 **Homepage:** [proton-drive Website](https://proton.me/drive)



## 🛠️ Dev-tools


### 🧰 balenaEtcher `v2.1.2`
- 💡 **Description:** Flash OS images to SD cards & USB drives, safely and easily.
- 🛡️ **License:** asl20
- 🖥️ **Platforms:** aarch64-darwin, x86_64-darwin
- 🌐 **Homepage:** [balenaEtcher Website](https://github.com/balena-io/etcher)
- 📄 **Changelog:** [CHANGELOG](https://github.com/balena-io/etcher/blob/master/CHANGELOG.md)



## 🎮 Gaming


### 🧰 ps-remote-play `v8.0.0`
- 💡 **Description:** PS Remote Play is a free app that lets you stream and play your PS5 or PS4 games on compatible devices like smartphones, tablets, PCs, and Macs, allowing you to game remotely over Wi-Fi or mobile data.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** darwin
- 🌐 **Homepage:** [ps-remote-play Website](https://remoteplay.dl.playstation.net/remoteplay/lang/gb/)
- 🔗 **PR:** [#408206](https://github.com/NixOS/nixpkgs/pull/408206)
  • [Tracker](https://nixpkgs-tracker.ocfox.me/?pr=408206)
- 📦 **Status:** 🔄 Open



## 🎵 Media


### 🧰 kobo-desktop `v0-unstable-2025-05-11`
- 💡 **Description:** Kobo Desktop is a free app for Windows and Mac that lets you buy, read, and manage eBooks, as well as sync them with your Kobo eReader.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** unknown
- 🌐 **Homepage:** [kobo-desktop Website](https://www.kobo.com/gb/en/p/desktop)

### 🧰 OpenAudible `v4.5.3`
- 💡 **Description:** OpenAudible is a cross-platform desktop app that lets Audible users download, convert, and manage their audiobooks in MP3 or M4B formats for offline listening.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** darwin
- 🌐 **Homepage:** [OpenAudible Website](https://openaudible.org/)
- 📄 **Changelog:** [CHANGELOG](https://openaudible.org/versions)



## 📦 Other


### 🧰 garmin-basecamp `v4.8.13`
- 💡 **Description:** Garmin BaseCamp is a free desktop app for planning outdoor adventures and managing GPS data with Garmin devices.
- 🛡️ **License:** unfree
- 🖥️ **Platforms:** darwin
- 🌐 **Homepage:** [garmin-basecamp Website](https://www.garmin.com/en-GB/software/basecamp/)
- 📄 **Changelog:** [CHANGELOG](https://www8.garmin.com/support/download_details.jsp?id=4449)



<!--table:end-->

[pkg-homepage-OpenAudible]: https://openaudible.org/
[pkg-changelog-OpenAudible]: https://openaudible.org/versions
[pkg-homepage-proton-drive]: https://proton.me/drive
[pkg-homepage-kobo-desktop]: https://www.kobo.com/gb/en/p/desktop
[pkg-homepage-ps-remote-play]: https://remoteplay.dl.playstation.net/remoteplay/lang/gb/
[pkg-pr-ps-remote-play]: https://github.com/NixOS/nixpkgs/pull/408206
[pkg-tracker-ps-remote-play]: https://nixpkgs-tracker.ocfox.me/?pr=408206
[pkg-homepage-chatterino]: https://chatterino.com
[pkg-changelog-chatterino]: https://github.com/Chatterino/chatterino2/blob/master/CHANGELOG.md
[pkg-homepage-balenaEtcher]: https://github.com/balena-io/etcher
[pkg-changelog-balenaEtcher]: https://github.com/balena-io/etcher/blob/master/CHANGELOG.md
[pkg-homepage-garmin-basecamp]: https://www.garmin.com/en-GB/software/basecamp/
[pkg-changelog-garmin-basecamp]: https://www8.garmin.com/support/download_details.jsp?id=4449