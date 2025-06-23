type VerifyConfig = {
  etherscan: {
    apiUrl: string;
    apiKey: string;
  };
};

export const getVerifyConfig = (network: string): VerifyConfig => {
  switch (network) {
    case "mainnet": {
      if (!process.env.MAINNET_ETHERSCAN_API_KEY) throw new Error("MAINNET_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.etherscan.io",
          apiKey: process.env.MAINNET_ETHERSCAN_API_KEY,
        },
      };
    }
    case "sepolia": {
      if (!process.env.MAINNET_ETHERSCAN_API_KEY) throw new Error("MAINNET_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api-sepolia.etherscan.io",
          apiKey: process.env.MAINNET_ETHERSCAN_API_KEY,
        },
      };
    }
    case "polygon": {
      if (!process.env.POLYGON_ETHERSCAN_API_KEY) throw new Error("POLYGON_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.polygonscan.com",
          apiKey: process.env.POLYGON_ETHERSCAN_API_KEY,
        },
      };
    }
    case "amoy": {
      if (!process.env.POLYGON_ETHERSCAN_API_KEY) throw new Error("POLYGON_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api-amoy.polygonscan.com",
          apiKey: process.env.POLYGON_ETHERSCAN_API_KEY,
        },
      };
    }
    case "arbiSepolia": {
      if (!process.env.ARBITRUM_ETHERSCAN_API_KEY) throw new Error("ARBITRUM_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api-sepolia.arbiscan.io",
          apiKey: process.env.ARBITRUM_ETHERSCAN_API_KEY,
        },
      };
    }
    case "optimism": {
      if (!process.env.OPTIMISM_ETHERSCAN_API_KEY) throw new Error("OPTIMISM_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api-optimistic.etherscan.io",
          apiKey: process.env.OPTIMISM_ETHERSCAN_API_KEY,
        },
      };
    }
    case "base": {
      if (!process.env.BASE_ETHERSCAN_API_KEY) throw new Error("BASE_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.basescan.org",
          apiKey: process.env.BASE_ETHERSCAN_API_KEY,
        },
      };
    }
    case "arbitrum": {
      if (!process.env.ARBITRUM_ETHERSCAN_API_KEY) throw new Error("ARBITRUM_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.arbiscan.io",
          apiKey: process.env.ARBITRUM_ETHERSCAN_API_KEY,
        },
      };
    }
    case "sonic": {
      if (!process.env.SONIC_ETHERSCAN_API_KEY) throw new Error("SONIC_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.sonicscan.org",
          apiKey: process.env.SONIC_ETHERSCAN_API_KEY,
        },
      };
    }
    case "sei": {
      if (!process.env.SEI_ETHERSCAN_API_KEY) throw new Error("SEI_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://seitrace.com/pacific-1",
          apiKey: process.env.SEI_ETHERSCAN_API_KEY,
        },
      };
    }
    case "avalanche": {
      return {
        etherscan: {
          apiUrl: "https://api.snowtrace.io",
          apiKey: "no-need",
        },
      };
    }
    case "bsc": {
      if (!process.env.BSC_ETHERSCAN_API_KEY) throw new Error("BSC_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.bscscan.com",
          apiKey: process.env.BSC_ETHERSCAN_API_KEY,
        },
      };
    }
    case "berachain": {
      if (!process.env.BERACHAIN_ETHERSCAN_API_KEY) throw new Error("BERACHAIN_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.berascan.com",
          apiKey: process.env.BERACHAIN_ETHERSCAN_API_KEY,
        },
      };
    }
    case "scroll": {
      if (!process.env.SCROLL_ETHERSCAN_API_KEY) throw new Error("SCROLL_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.scrollscan.com",
          apiKey: process.env.SCROLL_ETHERSCAN_API_KEY,
        },
      };
    }
    case "mantle": {
      if (!process.env.MANTLE_ETHERSCAN_API_KEY) throw new Error("MANTLE_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.mantlescan.xyz",
          apiKey: process.env.MANTLE_ETHERSCAN_API_KEY,
        },
      };
    }
    case "gnosis": {
      if (!process.env.GNOSIS_ETHERSCAN_API_KEY) throw new Error("GNOSIS_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.gnosisscan.io",
          apiKey: process.env.GNOSIS_ETHERSCAN_API_KEY,
        },
      };
    }
    case "unichain": {
      if (!process.env.UNICHAIN_ETHERSCAN_API_KEY) throw new Error("UNICHAIN_ETHERSCAN_API_KEY is not set");
      return {
        etherscan: {
          apiUrl: "https://api.uniscan.xyz",
          apiKey: process.env.UNICHAIN_ETHERSCAN_API_KEY,
        },
      };
    }
    case "ink": {
      return {
        etherscan: {
          apiUrl: "https://explorer.inkonchain.com",
          apiKey: "no-need",
        },
      };
    }
    case "hyperevm": {
      return {
        etherscan: {
          apiUrl: "https://www.hyperscan.com/",
          apiKey: "no-need",
        },
      };
    }
    default: {
      throw new Error(`${network} Network Verify not configured`);
    }
  }
};
