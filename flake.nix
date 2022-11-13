{
  description = "A very basic flake";

  inputs = {
    cppfront.url = "github:h0nzZik/cppfront/flake";
    kframework.url = "github:runtimeverification/k";
  };

  outputs = { self, nixpkgs, cppfront, kframework }:
    let
        # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ kframework.overlay self.overlay ]; });

    in

    {


      # A Nixpkgs overlay.
      overlay = final: prev: {

        kcpp2 = prev.pkgs.llvmPackages_12.stdenv.mkDerivation rec {
          name = "kcpp2-${version}";

          src = ./semantics;

          buildInputs = [ kframework.packages.${prev.system}.k ];

          buildPhase = ''
            kompile --version
          '';

          installPhase = ''
            mkdir -p $out/bin
            echo Hello > $out/bin/hello.txt
          '';
        };

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) kcpp2;
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      defaultPackage = forAllSystems (system: self.packages.${system}.kcpp2);
    };
}
