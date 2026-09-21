# nixosOptionsDoc for one of the evals above, minus the `_module` internals.
pkgs: eval:
pkgs.nixosOptionsDoc {
  options = builtins.removeAttrs eval.options ["_module"];
}
