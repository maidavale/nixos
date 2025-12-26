{ config, lib, ... }:

let
  cfg = config.services.myNextDNS;
in {
  options.services.myNextDNS = {
    enable = lib.mkEnableOption "Custom NextDNS configuration";

    nextdnsId = lib.mkOption {
      type = lib.types.str;
      description = "NextDNS configuration ID";
    };
  };

  config = lib.mkIf cfg.enable {
    services.nextdns = {
      enable = true;
      arguments = [
        "-config" cfg.nextdnsId
        "-report-client-info"
        "-listen" "127.0.0.1:53"
        "-cache-size" "0"
      ];
    };

    systemd.services.nextdns.serviceConfig = {
      Restart = "always";
      RestartSec = lib.mkForce "5s";
    };

    services.resolved = {
      enable = true;
      extraConfig = ''
        [Resolve]
        LLMNR=no
        MulticastDNS=no
        DNS=127.0.0.1
        DNSOverTLS=no
        DNSStubListener=yes
        Domains=~.
        FallbackDNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
      '';
    };
  };
}

