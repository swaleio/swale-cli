# Swale CLI

`swale` is the command line interface to [Swale](https://swale.io) — create and run workflows, and manage projects, task definitions and secrets from a terminal.

This repository publishes the released binaries. The CLI is built elsewhere; releases are all that is hosted here.

## Install

**macOS and Linux**

```sh
curl -fsSL https://get.swale.io/install.sh | sh
```

**Windows**

```powershell
irm https://get.swale.io/install.ps1 | iex
```

The installer picks the binary for your platform, verifies it, and installs it. For a specific version, a different install location, or the Windows form that takes arguments, see [Install the CLI](https://docs.swale.io/reference/install-cli).

Or take a binary from the [latest release](../../releases/latest) and put it somewhere on your `PATH`. The installers verify what they download; a manual download is yours to check.

## Run it in a container

If you would rather not install anything:

```sh
docker run --rm -v "$PWD:/mnt/workspace" swaleio/swale-cli repo list
```

Built for `linux/amd64` and `linux/arm64`. The image contains the same released
binary this repository publishes, fetched at build time and checked against the
signature below, so it needs no verification of its own. Authentication is by
environment variable — pass `SWALE_ACCOUNT_NAME` and `SWALE_ACCOUNT_TOKEN` with
`-e`, or mount your existing configuration.

## Verifying a download

Every release carries `manifest.json`, listing a SHA-256 for each platform binary, and `manifest.json.sig`, a detached OpenPGP signature over it — so one signature covers every binary in the release. The installers check both automatically when `gpg` is available.

The signing key is served from `swale.io`, deliberately not from this repository: a key published beside the artifacts it verifies proves nothing, because whatever could replace a binary here could replace the key alongside it.

The commands to check a download by hand are in [Install the CLI](https://docs.swale.io/reference/install-cli#verifying-a-download).

## Links

[Documentation](https://docs.swale.io) · [swale.io](https://swale.io)
