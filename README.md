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

To install a specific version, download the script and pass `--version`:

```sh
curl -fsSL https://get.swale.io/install.sh | sh -s -- --version 1.4.0
```

Or take a binary from the [latest release](../../releases/latest) and put it somewhere on your `PATH`. The installers verify what they download; a manual download is yours to check, and the section below is how.

## Verifying a download

Every release carries `manifest.json`, which lists a SHA-256 for each platform binary, and `manifest.json.sig`, a detached OpenPGP signature over it — so one signature covers every binary in the release.

The installers do this automatically when `gpg` is present, and warn rather than fail when it is not. By hand:

```sh
curl -fsSLO https://swale.io/.well-known/pgp-key.txt
curl -fsSLO https://github.com/swaleio/swale-cli/releases/latest/download/manifest.json
curl -fsSLO https://github.com/swaleio/swale-cli/releases/latest/download/manifest.json.sig

gpg --import pgp-key.txt
gpg --verify manifest.json.sig manifest.json
```

Then check the binary you downloaded against the checksum the manifest lists for your platform:

```sh
sha256sum swale-cli-linux-x64      # shasum -a 256 on macOS
```

The signing key is served from `swale.io`, deliberately not from this repository. A key published beside the artifacts it verifies would prove nothing, because anything able to replace a binary here could replace the key alongside it.

`gpg` reports `WARNING: This key is not certified with a trusted signature` unless you have signed the key yourself. That is expected, and does not mean the signature failed — the line to read is `Good signature`.

## Links

[swale.io](https://swale.io) · [Documentation](https://docs.swale.io)
