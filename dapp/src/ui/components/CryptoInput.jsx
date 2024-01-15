import coinLogo from "../../assets/solanaLogo.png";
import arrDown from "../../assets/down-arrow.svg";
function CryptoInput({getSymbol, symbol, amount, setAmount}) {
  return (
    <div className="relative w-full">
      <button className="absolute inset-y-0 left-0 cursor-pointer bg-transparent px-[7px] py-[9px]">
        <div className="flex h-full items-center gap-x-1 rounded-[50px] border-[0.5px] border-solid border-[#c4c4c4] bg-[#430f5d] py-[9px] pl-[12px] pr-[30px] text-sm font-bold text-white">
          <img src={coinLogo} alt="" />
          <h4
            onLoad={getSymbol()}
          >{symbol}</h4>
          <img src={arrDown} alt="" className="ml-3" />
        </div>
      </button>
      <input
        type="text"
        className="w-full rounded-[50px] border-[0.5px] border-solid border-[#c4c4c4] bg-white px-6 py-[19px] text-right text-base font-bold text-black outline-none placeholder:text-[#3a3a3a]"
        placeholder="0"
        value={amount}
        onChange={(e) => {setAmount(e.target.value)}}
      />
    </div>
  );
}

export default CryptoInput;
