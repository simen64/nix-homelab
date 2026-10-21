{...}: {
  # eMudhra intermediate CA key compromise (Oct 2026):
  # https://emudhra.we-have-a-problem.com
  # Distrust the roots the compromised intermediates chain to until
  # nixpkgs ships cacert >= 3.131.1, then remove this module.
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
  ];
}
