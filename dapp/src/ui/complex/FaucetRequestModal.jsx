import { useState } from "react";
import RequestModalControl from "./RequestModalControl";
import WaitingForConfirmationModal from "../components/WaitingForConfirmationModal";
import RequestCompleteModal from "../components/RequestCompleteModal";

function FaucetRequestModal({setModal}) {
  const [step, setStep] = useState(2);
  return (
    <div className="absolute inset-0 z-[200] flex justify-center bg-overlayPrimary pt-[140px]">
      <div className=" h-fit rounded-[5px] bg-white px-[45px] py-[27px] shadow-shadowPrimary">
        <RequestModalControl step={step} setStep={setStep} />
        {step === 2 && <WaitingForConfirmationModal setModal={setModal} />}
        {step === 3 && <RequestCompleteModal />}
      </div>
    </div>
  );
}

export default FaucetRequestModal;
