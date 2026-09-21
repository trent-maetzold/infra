{
  nixpkgs,
  overlays,
}: system:
import nixpkgs {
  inherit system;
  overlays = [overlays.default];
}
