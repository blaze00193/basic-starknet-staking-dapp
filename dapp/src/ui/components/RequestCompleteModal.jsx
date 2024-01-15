function RequestCompleteModal() {
  return (
    <div className="pt-[24px] text-center font-bold leading-6 text-black">
      <h1 className="mb-[12px] text-xl">Request Complete</h1>
      <p className="text-sm font-medium text-[#3a3a3a]">
        Congratulations, 10BWC was sent to your account.
      </p>

      <h3 className="mb-[12px] mt-8 text-sm">Transaction Hash</h3>
      <h5 className="text-xs font-medium text-[#3a3a3a]">
        0x883dfd4a02f4b5d29ec0663b6e115aff5e3216dce41c4735e7ff59a43e312f
      </h5>
      <button className="mt-[29px] w-[415px] rounded-[50px] bg-[#430F5D] px-[55px] py-[10px] text-base font-black text-white">
        Close
      </button>
    </div>
  );
}

export default RequestCompleteModal;
