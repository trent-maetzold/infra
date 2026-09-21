pkgs: eval:
pkgs.nixosOptionsDoc {
  options = builtins.removeAttrs eval.options ["_module"];
}
