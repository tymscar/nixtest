{
  description = "Node.js project with private npm registry support";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = ["aarch64-darwin" "x86_64-linux"];

      perSystem = { pkgs, ... }: let
        nodeEnv = ''
          export HOME="$NIX_BUILD_TOP"
          export YARN_ENABLE_TELEMETRY=0
          yarn config set enableGlobalCache false
        '';

        supportedArchitecturesJSON = builtins.toJSON {
          os = [ "darwin" "linux" ];
          cpu = [ "arm" "arm64" "ia32" "x64" ];
          libc = [ "glibc" "musl" ];
        };

        yarnOfflineCache = pkgs.stdenvNoCC.mkDerivation {
          name = "super-nix-test-deps";
          src = ./.;
          nativeBuildInputs = with pkgs; [ yarn-berry ];
          NODE_EXTRA_CA_CERTS = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

          configurePhase = ''
            runHook preConfigure
            ${nodeEnv}
            yarn config set cacheFolder $out
            yarn config set supportedArchitectures --json '${supportedArchitecturesJSON}'
            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild
            yarn install --immutable --mode skip-build
            runHook postBuild
          '';

          dontInstall = true;
          outputHashAlgo = "sha256";
          outputHashMode = "recursive";
          outputHash = "sha256-WLURUf/xCDOEPOs5jKPAhYfv7Qvy+yxNMMLsq6lLCEQ=";
        };
      in {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "yarn-nix-private-repo-test";
          version = "0.0.1";
          src = ./.;

          nativeBuildInputs = with pkgs; [ nodejs yarn-berry ];

          configurePhase = ''
            runHook preConfigure
            ${nodeEnv}
            yarn config set cacheFolder ${yarnOfflineCache}
            runHook postConfigure
          '';

          buildPhase = ''
            runHook preBuild
            yarn install --immutable --immutable-cache
            runHook postBuild
          '';

          installPhase = ''
            mkdir -p $out
            cp -r . $out/
          '';
        };
      };
    };
}
