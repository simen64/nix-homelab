{pkgs, ...}: {
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama-cuda;
    host = "0.0.0.0";
    loadModels = [
      "qwen3.5:27b"
      "ornith:35b"
    ];
    syncModels = true;
  };
}
