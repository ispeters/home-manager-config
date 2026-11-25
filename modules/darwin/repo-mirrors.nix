{ config, pkgs, ... }:

let
  # Repos that someone other than me (e.g. Claude) can push to. GitHub only
  # protects branches in private repos on paid plans, so a force-push or a
  # branch deletion there can't be prevented; these local mirrors make it
  # recoverable instead.
  mirrors = [
    {
      name = "claude-wg21";
      url = "git@github.com:ispeters/claude-wg21.git";
    }
  ];

  mirrorRoot = "${config.home.homeDirectory}/Backups/git-mirrors";
  logFile = "${config.home.homeDirectory}/Library/Logs/repo-mirrors.log";

  repo-mirrors = pkgs.writeShellApplication {
    name = "repo-mirrors";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.git
      pkgs.gnugrep
      pkgs.openssh
    ];
    text = ''
      # Usage: repo-mirrors ROOT NAME=URL...
      #
      # Fetches each URL into the bare repo ROOT/NAME.git with refspecs that
      # have no leading `+`, so git refuses any update that isn't a fast
      # forward. A force-push upstream therefore leaves the old history
      # here, and the rejection is reported instead of applied. Branches
      # and tags deleted upstream are kept.
      root=$1
      shift

      status=0
      for spec in "$@"; do
        name=''${spec%%=*}
        url=''${spec#*=}
        dir=$root/$name.git

        if [ ! -d "$dir" ]; then
          mkdir -p "$root"
          git init --quiet --bare "$dir"
          git -C "$dir" remote add origin "$url"
          # `remote add` installs a forced refspec; replace it
          git -C "$dir" config --replace-all remote.origin.fetch 'refs/heads/*:refs/heads/*'
          git -C "$dir" config --add remote.origin.fetch 'refs/tags/*:refs/tags/*'
          # keep a reflog for every ref, even in a bare repo
          git -C "$dir" config core.logAllRefUpdates always
        fi

        echo "$(date '+%Y-%m-%d %H:%M:%S') fetching $name"
        if ! output=$(git -C "$dir" fetch --no-prune origin 2>&1); then
          status=1
          printf '%s\n' "$output"
          # Network failures (e.g. offline) are only logged; a rejected
          # update means upstream history was rewritten, so say so loudly.
          if printf '%s\n' "$output" | grep -q '\[rejected\]'; then
            /usr/bin/osascript -e "display notification \"Upstream history was rewritten; the mirror kept the old refs. See ${logFile}.\" with title \"$name mirror\""
          fi
        elif [ -n "$output" ]; then
          printf '%s\n' "$output"
        fi
      done

      exit "$status"
    '';
  };
in
{
  launchd.agents.repo-mirrors = {
    enable = true;
    config = {
      ProgramArguments = [
        "${repo-mirrors}/bin/repo-mirrors"
        mirrorRoot
      ]
      ++ map (m: "${m.name}=${m.url}") mirrors;
      StartInterval = 3600;
      RunAtLoad = true;
      ProcessType = "Background";
      StandardOutPath = logFile;
      StandardErrorPath = logFile;
    };
  };
}
