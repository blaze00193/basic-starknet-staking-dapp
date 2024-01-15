export const feltToString = felt => felt
  // To hex
  .toString(16)
  // Split into 2 chars
  .match(/.{2}/g)
  // Get char from code
  .map( c => String.fromCharCode(parseInt( c, 16 ) ) )
  // Join to a string
  .join('');

  import { RpcProvider, Contract } from "starknet";
  
  export const bwcContractAddress =
    "0x7bcdcc132a6030b1a98c0b4a438f555c834ec7abd33f3d1a9803160d0be85cd";

  export const rpcProvider = new RpcProvider({
    nodeUrl:
      "https://starknet-goerli.infura.io/v3/c61b0457e5004368ac942e464b8d1f62",
  });