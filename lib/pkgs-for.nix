# nixpkgs with asgard's overlays applied, for one system.
{
  nixpkgs,
  overlays,
}: system:
import nixpkgs {
  inherit system;
  overlays = [overlays.default];
}
