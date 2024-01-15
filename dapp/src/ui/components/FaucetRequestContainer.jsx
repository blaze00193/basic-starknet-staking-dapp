import coinLogo from "../../assets/solanaLogo.png";
import arrDown from "../../assets/down-arrow.svg";
import { useState } from "react";

function FaucetRequestContainer({sendFaucet}) {
  const [address, setAddress] = useState("");
  return (
    <div className="shadow-shadowPrimary flex flex-col rounded-[5px] bg-white px-6 pb-10 pt-6">
      <h2 className="text-lg font-medium text-[#3a3a3a]">Account Address</h2>
      <div className="relative mt-[23px] w-full">
        <button className="absolute inset-y-0 right-0 cursor-pointer bg-transparent py-[9px] pr-[24px]">
          <div className="flex h-full items-center gap-x-1 rounded-[50px] border-[0.5px] border-solid border-[#c4c4c4] bg-[#430f5d] py-[9px] pl-[12px] pr-[30px] text-sm font-bold text-white">
            <img src={coinLogo} alt="" />
            <h4>BWC</h4>
            <img src={arrDown} alt="" className="ml-3" />
          </div>
        </button>
        <input
          type="text"
          className="w-full rounded-[50px] border-[0.5px] border-solid border-[#c4c4c4] bg-white px-6 py-[19px] text-base font-bold text-black outline-none placeholder:text-[#3a3a3a]"
          placeholder="0x0000.."
          value={address}
          onChange={(e) => {
            setAddress(e.target.value);
          }}
        />
      </div>
      <button onClick={() => {sendFaucet(address)}} className="mt-[60px] self-center rounded-[50px] bg-[#430F5D] px-[172px] py-[10px]">
        Send Request
      </button>
    </div>
  );
}

export default FaucetRequestContainer;
