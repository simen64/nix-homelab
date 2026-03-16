{pkgs, ...}: {
  imports = [
    ../../modules
  ];

  nixpkgs.config.allowUnfree = true;

  homelab.services = {
    pocket-id.enable = true;
    watchtower.enable = true;
    netbird.enable = false;
  };

  environment.systemPackages = with pkgs; [
    openssl
  ];

  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = ["docker0"];
  networking.firewall.extraCommands = ''
    iptables -A INPUT -i br+ -j ACCEPT
    iptables -A FORWARD -i br+ -j ACCEPT
    iptables -A FORWARD -o br+ -j ACCEPT
  '';

  virtualisation.docker = {
    enable = true;
  };
}
