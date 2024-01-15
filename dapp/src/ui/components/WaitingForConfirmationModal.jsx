function WaitingForConfirmationModal({setModal}) {
  return (
    <div className="pt-[24px] text-center font-bold leading-6 text-black">
      <h1 className="text-xl mb-[12px]">Waiting for Confirmation</h1>
      <p className="text-sm font-medium text-[#3a3a3a]">
        Transcation has been initialized. Waiting for confirmation
      </p>

      <h3 className="mt-8 text-sm mb-[12px]">Transaction Hash</h3>
      <h5 className="text-xs font-medium text-[#3a3a3a]">
        0x883dfd4a02f4b5d29ec0663b6e115aff5e3216dce41c4735e7ff59a43e312f
      </h5>
      <button onClick={() => {setModal(false)}} className="mt-[29px] w-[415px] rounded-[50px] bg-[#430F5D] px-[55px] py-[10px] text-base font-black text-white">
        Close
      </button>
    </div>
  );
}

export default WaitingForConfirmationModal;
