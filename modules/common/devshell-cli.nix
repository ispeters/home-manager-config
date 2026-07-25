{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellApplication {
      name = "devshell";
      runtimeInputs = [ pkgs.jq ];
      text = builtins.readFile ./devshell.sh;
    })
  ];
}
