{
  description = "Development environment for PairedPitches++";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              uv
              git
              duckdb
            ];

            # Let uv manage the Python interpreter and all Python packages.
            UV_PYTHON_PREFERENCE = "managed";

            shellHook = ''
              echo "PairedPitches++ development shell"
              echo "Python dependencies are managed with uv."
            '';
          };
        });
    };
}
