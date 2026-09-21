{pkgs, ...}: {
  home.packages = with pkgs.llm-agents; [kilocode-cli];
}
