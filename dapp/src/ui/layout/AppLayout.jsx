import Navbar from "../components/Navbar";
import { Outlet } from "react-router-dom";
import { useState, useEffect } from "react";
import { connect, disconnect } from "starknetkit";

function AppLayout() {
  const [connection, setConnection] = useState("");
  const [provider, setProvider] = useState("");
  const [address, setAddress] = useState("");

  useEffect(() => {
    const connectToStarknet = async () => {
      const connection = await connect({ modalMode: "neverAsk" });

      if (connection && connection.isConnected) {
        setConnection(connection);
        setProvider(connection.account);
        setAddress(connection.selectedAddress);
      }
    };

    connectToStarknet();
  }, []);

  const connectWallet = async () => {
    const connection = await connect();

    if (connection && connection.isConnected) {
      setConnection(connection);
      setProvider(connection.account);
      setAddress(connection.selectedAddress);
    }
  };

  const disconnectWallet = async () => {
    await disconnect();

    setConnection(undefined);
    setProvider(undefined);
    setAddress("");
  };

  return (
    <div className="flex min-h-[100vh] w-full flex-col bg-mainBg bg-cover bg-center bg-no-repeat pt-[140px]">
      <Navbar
        connection={connection}
        connectWallet={connectWallet}
        disconnectWallet={disconnectWallet}
        address={address}
      />
      {connection && <Outlet context={[provider, address]} />}
    </div>
  );
}

export default AppLayout;
