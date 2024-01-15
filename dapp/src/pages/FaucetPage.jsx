import { useState } from "react";
import { createPortal } from "react-dom";
import FaucetRequestContainer from "../ui/components/FaucetRequestContainer";
import FaucetRequestModal from "../ui/complex/FaucetRequestModal";
import { useOutletContext } from "react-router-dom";
import {Contract} from 'starknet';
import { bwcContractAddress } from "../helpers";
import { bwcAbi } from "../utils";

function FaucetPage() {

  const [step, setStep] = useState(false)
  const [provider, address] = useOutletContext();

  const writeContract = new Contract(bwcAbi, bwcContractAddress, provider);

  const sendFaucet = async (recipient) => {
    
    try {
        const amount = 10

        await writeContract.transfer(recipient, amount)
        setStep(true)
        
    } catch (error) {
        alert(error.message)
        console.log(error)
    }
}

  return (
    <div className="px-[324px] text-white">
      <h1 className="text-2xl font-bold">Request testnet tokens</h1>
      <p className="mb-5 mt-3 text-lg font-medium">
        This Faucet sends small amounts of Bwc to an account address on Starknet
        Bwc You can use it to pay transaction fee in Starknet.
      </p>
      <FaucetRequestContainer sendFaucet={sendFaucet} />

      {step && createPortal(<FaucetRequestModal setModal={setStep} />, document.body)}
    </div>
  );
}

export default FaucetPage;
