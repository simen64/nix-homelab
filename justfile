rebuild:
    for machine in $(clan machines list); do \
        clan machines update "$machine"; \
    done

update: && rebuild
    nix flake update
