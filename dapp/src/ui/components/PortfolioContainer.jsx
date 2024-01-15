function PortfolioContainer() {
  return (
    <div className="flex w-full items-center justify-between rounded-[10px] bg-white pb-[18px] pl-[62px] pr-[48px] pt-[22px]">
      <div className="flex gap-x-[97px]">
        <div className="flex flex-col items-center text-center">
          <h5 className="mb-[25px] text-xl font-semibold">
            Total Liquidity Staked
          </h5>
          <h2 className="text-[48px] font-bold">$567</h2>
        </div>
        <div className="h-[136px] w-[0.5px] bg-[#3a3a3a]"></div>
        <div className="flex flex-col items-center text-center">
          <h5 className="mb-[25px] text-xl font-semibold">Intrest Accrued</h5>
          <h2 className="text-[48px] font-bold">$78</h2>
        </div>
      </div>
      <div className="text-center">
        <div className="flex h-[134px] w-[134px] items-center justify-center rounded-full border-[1px] border-solid border-[#430F5D] text-center text-[48px] font-bold">
          1
        </div>
        <h6 className="mt-2 text-base font-semibold">Interactions</h6>
      </div>
    </div>
  );
}

export default PortfolioContainer;
