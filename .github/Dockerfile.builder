# Builder image for foyer-cores matrix.
#
# Extends devkitpro/devkita64 with the Switch portlibs pre-installed so
# CI jobs don't have to hit pkg.devkitpro.org's flaky CDN every run.
# Built + pushed to ghcr.io/foyer-frontend/foyer-cores-builder by
# .github/workflows/build-image.yml, consumed by build-cores.yml.

FROM devkitpro/devkita64:latest

# Same retry loop as the in-line workflow had — but this only needs to
# succeed once during image-build, so 20 attempts × 60s gives us a
# generous 20 min window across CDN outages.
RUN delay=10; \
    for attempt in $(seq 1 20); do \
        if dkp-pacman -Syu --needed --noconfirm \
            switch-portlibs switch-sdl2 switch-sdl2-libs; then \
            exit 0; \
        fi; \
        echo "dkp-pacman attempt $attempt failed; sleeping ${delay}s..."; \
        sleep "$delay"; \
        delay=$(( delay + 10 )); \
        [ "$delay" -gt 60 ] && delay=60; \
    done; \
    echo "dkp-pacman failed after 20 attempts" >&2; \
    exit 1
