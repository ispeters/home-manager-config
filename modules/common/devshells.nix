{ devshells, ... }:
{
  home.file.".config/devshells".source = devshells.outPath;
}
