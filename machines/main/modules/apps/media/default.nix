{...}: {
  imports = [
    ./jellyfin.nix
    ./arr.nix
    ./seerr.nix
    ./qbittorrent.nix
    ./scanning.nix
  ];

  # Shared group so the downloader, Radarr and Jellyfin can all read/write the library.
  users.groups.media = {};

  # Downloads and library live on the same dataset so Radarr can hardlink instead of copy.
  # Setgid (2775) keeps new files in the media group.
  systemd.tmpfiles.rules = [
    "d /spare/data 2775 root media - -"
    "d /spare/data/torrents 2775 root media - -"
    "d /spare/data/torrents/movies 2775 root media - -"
    "d /spare/data/media 2775 root media - -"
    "d /spare/data/media/movies 2775 root media - -"
    "d /spare/data/quarantine 2770 root media - -"
  ];

  # Back up config only, movies can be re-downloaded.
  clan.core.state.media = {
    folders = [
      "/var/lib/jellyfin"
      "/var/lib/radarr"
      "/var/lib/private/prowlarr"
      "/var/lib/private/seerr"
      "/var/lib/qBittorrent"
    ];
  };
}
