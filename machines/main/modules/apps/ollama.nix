{pkgs, ...}: {
  services.ollama = {
    enable = true;
    package = pkgs.unstable.ollama-cuda;
    host = "0.0.0.0";
    loadModels = [
      "lfm2"
      "qwen3.5:27b"
      "qwen3-coder:30b"
      "glm-4.7-flash:latest"
      "devstral-small-2:24b"
    ];
    syncModels = true;
  };
}
