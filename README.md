# nix-homelab

Homelab based on nix and clan.lol

## Hardware

Currently my homelab consists of these machines, all managed with clan:

| Name      | Machine                            | Role                                   |
| --------- | ---------------------------------- | -------------------------------------- |
| main      | Gaming PC repurposed as a sever    | Runs most apps like immich and seafile |
| offsite   | Offsite old desktop PC             | Stores offsite backups                 |
| im-backup | VM in a proxmox node               | Another offsite backup storage         |
| vps       | Hetzner VPS running netbird server |                                        |

## Software

|                                          Logo                                           | Name                                        | Description                      |
| :-------------------------------------------------------------------------------------: | ------------------------------------------- | -------------------------------- |
|  <img width="32" src="https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/immich.png">   | [Immich]((https://immich.app/))             | Image and Video management       |
|  <img width="32" src="https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/seafile.png">  | [Seafile](https://www.seafile.com/en/home/) | File syncing and backups         |
|  <img width="32" src="https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/ollama.png">   | [Ollama](https://ollama.com/)               | Local AI models                  |
| <img width="32" src="https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/pocket-id.png"> | [Pocket-ID](https://pocket-id.org/)         | SSO authentication with passkeys |

## Tech stack

My tech stack runs on NixOS usin clan.lol as a framework for managing multiple machines aswell as secret management.

### Virtualization / Containers

|                                       Logo                                        | Name                                                                  | Description                                      |
| :-------------------------------------------------------------------------------: | --------------------------------------------------------------------- | ------------------------------------------------ |
| <img width="32" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/proxmox.png">  | [Proxmox VE](https://www.proxmox.com/en/proxmox-virtual-environment/) | Open-source virtualization platform based on KVM |
|  <img width="32" src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/podman.svg">  | [Podman](https://podman.io/)                                          | Running OCI containers defined with Nix          |
| <img width="32" src="https://cdn.jsdelivr.net/gh/selfhst/icons/webp/docker.webp"> | [Docker](https://www.docker.com/)                                     | Running netbird                                  |

### IaC

|                                            Logo                                             | Name                          | Description                                 |
| :-----------------------------------------------------------------------------------------: | ----------------------------- | ------------------------------------------- |
|     <img width="32" src="https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/nixos.png">     | [NixOS](https://nixos.org/)   | Declaratively defined                       |
| <img width="32" src="https://clan.lol//images/blogpost-image-idea_hu_1a3415773c4ffc2d.png"> | [clan.lol](https://clan.lol/) | Framework for managing NixOS infrastructure |

### Network

| Logo                                                                                                                             | Name                                                                                                                                | Description                       |
| -------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| <img width="32" src="https://cdn.jsdelivr.net/gh/selfhst/icons/png/opnsense.png">                                                | [OPNsense](https://opnsense.org/)                                                                                                   | Open source firewall and router   |
| <img width="32" src="https://play-lh.googleusercontent.com/Hyedd-vjRpgJHAVdth6SkLaAKyxT_qJvRCzNYFX7qQ-IRZZihygR-29IWlcXORvBmN4"> | [Asus ET12](https://www.asus.com/no/networking-iot-servers/whole-home-mesh-wifi-system/zenwifi-wifi-systems/asus-zenwifi-pro-et12/) | Asus router being used in AP mode |
| <img width="32" src="https://cdn.jsdelivr.net/gh/selfhst/icons@main/png/netbird.png">                                            | [Netbird](https://netbird.io/)                                                                                                      | Self hosted overlay VPN           |
