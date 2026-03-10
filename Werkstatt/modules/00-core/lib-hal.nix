# [META] ID: NIXH-SYS-048 | ADR: TBD | Version: 1.0 | Stage: 1
/**
 * --- mynixos HAL Library (Aviation-Grade Functions) ---
 * Provides typed, tested, and documented helper functions for the HAL.
 */
{ lib, config, ... }:

{
  lib.nlib.storage.mkPath = {
    type = lib.types.functionTo (lib.types.functionTo lib.types.str);
    description = "Generates a standardized storage path based on Tier and Service-ID.";
    
    # Die Funktion selbst. Sie greift auf `config` zu, um die Pfade zu lesen.
    fn = nixhId: tier:
      "${config.mynixos.hal.storage.${tier}}/${nixhId}";
      
    # Quality Gate 7: Integrierter API-Test
    tests."generates a valid Tier-A path" = {
      # Wir simulieren hier die `config` für den Test
      config = {
        mynixos.hal.storage.tA-nvme = "/persist/tA-nvme";
      };
      args = { nixhId = "TEST-ID-001"; tier = "tA-nvme"; };
      expected = "/persist/tA-nvme/TEST-ID-001";
    };
  };
}
