{ pkgs }:

pkgs.mkShell {
  name = "cuda";

  packages = with pkgs; [
    cudaPackages_12.cudatoolkit
    cudaPackages_12.cudnn
    cudaPackages_12.cuda_nvcc
    python313
    numpy
  ];

  env = {
    CUDA_PATH = "${pkgs.cudaPackages_12.cudatoolkit}";
    EXTRA_LDFLAGS = "-L${pkgs.cudaPackages_12.cudatoolkit}/lib -L${pkgs.cudaPackages_12.cudnn}/lib";
    EXTRA_CFLAGS = "-I${pkgs.cudaPackages_12.cudatoolkit}/include -I${pkgs.cudaPackages_12.cudnn}/include";
  };

  shellHook = ''
    echo "CUDA ${pkgs.cudaPackages_12.cudaVersion} + cuDNN ${pkgs.cudaPackages_12.cudnn.version}"
  '';
}