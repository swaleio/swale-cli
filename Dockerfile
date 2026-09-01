# docker.io/library/debian:13-slim — an OCI index, so one digest serves both
# architectures this image is built for.
FROM docker.io/library/debian@sha256:28de0877c2189802884ccd20f15ee41c203573bd87bb6b883f5f46362d24c5c2 AS fetch

# The release to package. The workflow passes the tag of the release that
# triggered it, so shipping a new version never edits this file.
ARG VERSION

# Set by buildx, once per platform in the build.
ARG TARGETARCH

# The fingerprint is embedded and the key is not. Rotation replaces the key
# material every two years but preserves the fingerprint, so embedding the key
# would put this file on that schedule. Fetching a key and trusting whatever
# comes back would verify a signature made by an attacker's key just as
# happily — the fingerprint is what makes the fetch mean something.
ARG SIGNING_FINGERPRINT=F52CF38130C597453BE6BD7DD65BF0C473F6E965

# curl, gnupg and jq exist only to fetch and verify; the runtime stage below
# starts from the same base again so none of them ship.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates curl gnupg jq; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /fetch

# Two independent checks, because they answer different questions: the
# signature says Swale produced this release, the checksum says these are the
# bytes it described. The key comes from swale.io and the binary from GitHub —
# a key served beside the artifact it verifies would prove nothing.
#
# Unlike the install scripts, a build has no user to warn, so a missing gpg or
# a failed verification stops the build rather than degrading to a checksum.
RUN set -eux; \
    case "$TARGETARCH" in \
      amd64) rid=linux-x64 ;; \
      arm64) rid=linux-arm64 ;; \
      *) echo "no published Linux build for TARGETARCH=$TARGETARCH" >&2; exit 1 ;; \
    esac; \
    base="https://github.com/swaleio/swale-cli/releases/download/v${VERSION}"; \
    curl -fsSL -o manifest.json "$base/manifest.json"; \
    curl -fsSL -o manifest.json.sig "$base/manifest.json.sig"; \
    curl -fsSL -o key.asc https://swale.io/.well-known/pgp-key.txt; \
    gpg --batch --quiet --import key.asc; \
    gpg --list-keys --with-colons | grep -q "^fpr:::::::::${SIGNING_FINGERPRINT}:" \
      || { echo "the key at swale.io is not ${SIGNING_FINGERPRINT}" >&2; exit 1; }; \
    gpg --batch --verify manifest.json.sig manifest.json; \
    asset=$(jq -er --arg rid "$rid" '.platforms[$rid].asset' manifest.json); \
    sum=$(jq -er --arg rid "$rid" '.platforms[$rid].checksum' manifest.json); \
    curl -fsSL -o swale "$base/$asset"; \
    echo "$sum  swale" | sha256sum -c -; \
    chmod 0755 swale

FROM docker.io/library/debian@sha256:28de0877c2189802884ccd20f15ee41c203573bd87bb6b883f5f46362d24c5c2

# ca-certificates for HTTPS to the Swale service, and libicu because the CLI is
# a NativeAOT .NET binary: without it the process dies at startup with
# "Couldn't find a valid ICU package" before running any command, and slim
# bases do not carry it. Plus a non-root runtime user.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates libicu76; \
    rm -rf /var/lib/apt/lists/*; \
    useradd --create-home --user-group --uid 1000 swale; \
    mkdir -p /mnt/workspace; \
    chown swale:swale /mnt/workspace

COPY --from=fetch /fetch/swale /usr/local/bin/swale

USER swale

# /mnt/workspace because a task definition may not override the working
# directory, and that is where the platform mounts the workspace. Anyone
# running this image by hand can point it elsewhere with `docker run -w`.
WORKDIR /mnt/workspace

# Bare `swale`, so `docker run swaleio/swale-cli repo list` reads as the command
# it is. A task definition's exec.args append here the same way, and the
# variables the CLI authenticates from arrive through exec.env.
ENTRYPOINT ["swale"]
CMD ["--help"]

LABEL org.opencontainers.image.title="Swale CLI"
LABEL org.opencontainers.image.description="The Swale command line interface, for workflow tasks and for running it without installing."
LABEL org.opencontainers.image.source="https://github.com/swaleio/swale-cli"
LABEL org.opencontainers.image.documentation="https://docs.swale.io/reference/install-cli"
# The image carries Swale's CLI, which is not open source and grants no
# license by being downloadable. SPDX has no identifier for that, so the
# LicenseRef- form says it deliberately rather than leaving the field blank
# for a reader to fill in with the base image's terms.
LABEL org.opencontainers.image.licenses="LicenseRef-Proprietary"
