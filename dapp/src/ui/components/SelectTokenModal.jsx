function SelectTokenModal() {
  return (
    <div className="absolute inset-0 z-[100] flex justify-center pt-[50px]">
      <div className="w-[32%] rounded-xl bg-[#430f5d] p-5 text-white">
        <h2 className="text-[18px] font-medium">Select a token</h2>
        <input
          type="text"
          className="mt-4 w-full rounded-md px-4 py-3 text-[#333] outline-none"
          placeholder="Search name or paste address"
        />

        <div></div>
      </div>
    </div>
  );
}

export default SelectTokenModal;
