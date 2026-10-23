{ lib, applyPatches, buildGoModule, buildNpmPackage, fetchFromGitHub }:
let
  rev = "dd04439e1b3ce0731168feb2b92a2bb66ca94718";
  version = "0-unstable-${builtins.substring 0 7 rev}";
  src = applyPatches {
    name = "seedstrem-source";
    src = fetchFromGitHub {
      owner = "kipsilabs";
      repo = "seedstrem";
      inherit rev;
      hash = "sha256-md/e3dzEP0+j5pdm8ZdKCKwZ1ZFMlzd/01h44GhaXck=";
    };
    patches = [ ./deferred-torrent-metadata.patch ];
  };
  web = buildNpmPackage {
    pname = "seedstrem-web";
    inherit version;
    src = "${src}/web";
    npmDepsHash = "sha256-G4WUiFnDxXuN76dfFY8xQit3gCdTRb6jbI+A5KqA304=";
    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };
in
buildGoModule {
  pname = "seedstrem";
  inherit version src;
  vendorHash = "sha256-cOLjcM33k296TlQfXVHzixrdW+vfNhfh8TOG/pXX71g=";
  subPackages = [ "cmd/seedstrem" ];
  env.CGO_ENABLED = 0;
  ldflags = [ "-s" "-w" "-X main.version=${version}" ];
  preBuild = ''
    rm -rf web/dist
    cp -r ${web} web/dist
  '';
  overrideModAttrs = _: { preBuild = ""; };
  meta.mainProgram = "seedstrem";
}
