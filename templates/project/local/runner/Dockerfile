# Runner image for this project's local checks (Dev Crew kit, playbook step 7).
# Ubuntu 24.04, like GitHub's ubuntu-24.04 runners, plus Git and the project's toolchain. Built by
# scripts/local.cmd rebuild (or scripts/local.sh rebuild). Pin toolchain versions to what CI or production uses.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        git ca-certificates curl unzip zip jq python3 \
    && rm -rf /var/lib/apt/lists/*

# ---- The project's toolchain goes here. Examples (pick, pin, adapt; see recipes/ in the kit): -----------------------
# Node (Ubuntu's package; for a specific major version use NodeSource or a node:<major> base image instead):
# RUN apt-get update && apt-get install -y --no-install-recommends nodejs npm && rm -rf /var/lib/apt/lists/*
# Java 17:
# RUN apt-get update && apt-get install -y --no-install-recommends openjdk-17-jdk-headless && rm -rf /var/lib/apt/lists/*
# PHP 8.3 at an exact version, as GitHub's runners have it (ondrej/php archive):
# RUN apt-get update && apt-get install -y --no-install-recommends software-properties-common gnupg \
#     && add-apt-repository -y ppa:ondrej/php && apt-get update \
#     && apt-get install -y --no-install-recommends php8.3-cli php8.3-mbstring php8.3-xml php8.3-curl php8.3-zip \
#     && rm -rf /var/lib/apt/lists/*
# ---------------------------------------------------------------------------------------------------------------------

# Git settings for every user the container may run as (the Linux helper runs it as the host user's id).
RUN git config --system --add safe.directory '*' \
    && git config --system advice.detachedHead false \
    && useradd --create-home --uid 1001 runner \
    && mkdir -p /work /evidence \
    && chmod 1777 /work
ENV HOME=/work/home
COPY run-checks.sh /usr/local/bin/run-checks
RUN chmod 0755 /usr/local/bin/run-checks
USER runner
WORKDIR /work
ENTRYPOINT ["bash", "/usr/local/bin/run-checks"]
