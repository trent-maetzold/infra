{
  bash = {
    deny = {
      credentials = [
        "*/.aws/*"
        "*/.config/gh/*"
        "*/.docker/config.json"
        "*/.git-credentials*"
        "*/.gnupg/*"
        "*/.netrc"
        "*/.oci/*"
        "*/.omp/agent/*"
        "*/.ssh/*"
        "*id_ed25519*"
        "*id_rsa*"
        "gh auth token"
      ];
      decryptors = [
        "age *"
        "gpg *"
        "op *"
        "pass *"
        "ragenix *"
        "sops *"
      ];
      environment = [
        "env"
        "env -0"
        "export"
        "export -p"
        "printenv"
        "set"
        "*/proc/*environ*"
      ];
    };

    prompt = {
      environment = [
        "env *"
        "printenv *"
      ];
      removals = [
        "rm *"
        "*rm -rf *"
        "*rm -fr *"
      ];
      remotes = [
        "ssh"
        "ssh *"
      ];
    };
  };
}
