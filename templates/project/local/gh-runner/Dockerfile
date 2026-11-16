# One-job GitHub Actions runner for this computer (Dev Crew kit, playbook step 9).
# GitHub hands a waiting job that asks for this runner's label to this container instead of one of its own machines,
# so the job costs no GitHub minutes and can write to the computer's local-data folder.
# Base: GitHub's official runner image. GitHub stops accepting runner versions that fall too far behind, so rebuild
# this image now and then (scripts/gh-runner build) rather than pinning an old version forever.
FROM ghcr.io/actions/actions-runner:latest
USER root
ENV DEBIAN_FRONTEND=noninteractive
# Tools the project's jobs need on top of the base image. Keep this list to what the workflows actually use.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates git curl jq openssh-client python3 zip unzip \
    && rm -rf /var/lib/apt/lists/*
# The compose file mounts a memory-only folder at _work/_temp; without this, Docker creates _work as root and the
# runner cannot set the job up.
RUN mkdir -p /home/runner/_work/_temp && chown -R runner:runner /home/runner/_work
COPY entrypoint.sh /usr/local/bin/crew-gh-runner.sh
USER runner
ENTRYPOINT ["bash", "/usr/local/bin/crew-gh-runner.sh"]
