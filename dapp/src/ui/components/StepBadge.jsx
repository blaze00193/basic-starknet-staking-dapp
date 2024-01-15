/* eslint-disable react/prop-types */
import complete from "../../assets/completeLogo.png";

function StepBadge({ step, value }) {
  return (
    <>
      {value > step ? (
        <div className="flex h-[30px] w-[30px] items-center justify-center rounded-full bg-[#430F5D] text-center text-sm font-medium text-white">
          {value}
        </div>
      ) : (
        <img src={complete} className="h-[30px] w-[30px]" />
      )}
    </>
  );
}

export default StepBadge;
