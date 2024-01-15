function WalletConnector({connection, disconnectWallet, connectWallet}) {
  return (
    <>
      {connection ? (
        <button
          className="px-6 rounded-[20px] py-3 bg-white font-bold text-sm text-[#121212] cursor-pointer"
          onClick={disconnectWallet}
        >
          Disconnect
        </button>
      ) : (
        <button
          className="px-6 rounded-[20px] py-3 bg-white font-bold text-sm text-[#121212] cursor-pointer"
          onClick={connectWallet}
        >
          Connect Wallet
        </button>
      )}
    </>

  );
}

export default WalletConnector;
