{ lib, buildNpmPackage, fetchurl, jq, makeWrapper, nodejs_24 }:
buildNpmPackage rec {
  pname = "tokenburnmarket";
  version = "0.5.0";
  nodejs = nodejs_24;
  src = fetchurl {
    url = "https://registry.npmjs.org/${pname}/-/${pname}-${version}.tgz";
    hash = "sha256-Q2D5V5s4+fNoSIIDHho3YKWDNQp23POsHSjDnFZTS9c=";
  };
  sourceRoot = "package";
  nativeBuildInputs = [ makeWrapper ];
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';
  npmDepsHash = "sha256-Y5MLD3fgmL1+T1LTmuXJXT2rgR/GcK6O/BxpLr+CfXk=";
  dontNpmBuild = true;
  postInstall = ''
    wrapProgram $out/bin/tokenburnmarket --prefix PATH : ${lib.makeBinPath [ nodejs_24 ]}
  '';
  meta.mainProgram = "tokenburnmarket";
}
