import asset from "../../assets/solanaLogo.png";

function OverviewContainer() {
  return (
    <div className="flex items-center justify-between rounded-[10px] bg-white px-[74px] py-[36px] text-black">
      <div className="flex md:gap-x-[60px]">
        <div className="text-center">
          <h2 className="mb-[14px] text-lg font-semibold">Liquidity Staked</h2>
          <h3 className="text-sm font-bold text-[#3a3a3a]">$567</h3>
        </div>
        <div className="text-center">
          <h2 className="mb-[14px] text-lg font-semibold">Asset</h2>
          <h3 className="flex items-center text-sm font-bold text-[#3a3a3a]">
            <img src={asset} className="mr-1 h-5 w-5" alt="" /> BWC
          </h3>
        </div>
        <div className="text-center">
          <h2 className="mb-[14px] text-lg font-semibold">Duration</h2>
          <h3 className="text-sm font-bold text-[#3a3a3a]">22 days</h3>
        </div>
        <div className="text-center">
          <h2 className="mb-[14px] text-lg font-semibold">Reward accured</h2>
          <h3 className="text-sm font-bold text-[#3a3a3a]">$78 RBWC</h3>
        </div>
      </div>
      <button className="rounded-[50px] bg-[#430F5D] px-[55px] py-[10px] text-base font-black text-white">
        Unstake
      </button>
    </div>
  );
}

export default OverviewContainer;
