import OverviewContainer from "../ui/components/OverviewContainer";
import PortfolioContainer from "../ui/components/PortfolioContainer";

function PortfolioPage() {
  return (
    <div className="px-[80px] pb-[110px] pt-[36px] text-[#3a3a3a]">
      <h1 className="mb-2 text-2xl font-semibold text-white">Portfolio</h1>
      <PortfolioContainer />
      <div className="mb-[27px] mt-[38px] flex items-center gap-x-4">
        <button className=" rounded-[40px] bg-white px-[30px] py-[10px] text-lg font-semibold transition-all duration-200 ease-in-out hover:bg-white hover:text-[#3a3a3a]">
          Overview
        </button>
        <button className="rounded-[40px] bg-transparent  px-[30px] py-[10px] text-lg font-semibold text-white transition-all duration-300 ease-in-out hover:bg-white  hover:text-[#3a3a3a]">
          Transcation history
        </button>
      </div>
      <OverviewContainer />
    </div>
  );
}

export default PortfolioPage;
