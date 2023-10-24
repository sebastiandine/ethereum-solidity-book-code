import './App.css';

import { useState } from "react";
import { BrowserProvider, formatEther, Contract } from "ethers";
import abi from "./CounterAbi.json";

function App() {

  const NETWORK_ID = 4711;
  const CONTRACT_ADDR = "0x5FbDB2315678afecb367f032d93F642f64180aa3";

  const [provider, setProvider] = useState(null);
  const [signer, setSigner] = useState(null);
  const [networkId, setNetworkId] = useState(-1);
  const [signerBalance, setSignerBalance] = useState(-1);
  const [counterContract, setCounterContract] = useState(null);
  const [counterValue, setCounterValue] = useState(-1);
  const [inputVal, setInputVal] = useState(1);

  const connect = async () => {
    const {ethereum} = window; 
    if (! (ethereum && ethereum.isMetaMask)){
      alert("Please install Metamask!");
      return;
    }
    else {
      const _provider = new BrowserProvider(ethereum);
      setProvider(_provider);

      try {
        const _signer = await _provider.getSigner();
        setSigner(_signer);
        setSignerBalance(await _provider.getBalance(_signer.address));
        const _networkId = parseInt((await _provider.getNetwork()).chainId);
        setNetworkId(_networkId);
        if (_networkId === NETWORK_ID) {
          const _contract = new Contract(CONTRACT_ADDR, abi, _provider);
          setCounterContract(_contract);
          setCounterValue(await _contract.number());
        }
      }
      catch(e) {
        alert(e.message);
      }
    }
  }

  const triggerIncrement = async () => {
    if (counterContract != null) {
      const tx = await counterContract.connect(signer).increment();
      await tx.wait();
      setCounterValue(await counterContract.number());
      setSignerBalance(await provider.getBalance(signer.address));
    }
  }

  const triggerDecrement = async () => {
    if (counterContract != null) {
      const tx = await counterContract.connect(signer).decrement();
      await tx.wait();
      setCounterValue(await counterContract.number());
      setSignerBalance(await provider.getBalance(signer.address));
    }
  }

  const triggerSetNumber = async () => {
    if (counterContract != null) {
      const tx = await counterContract.connect(signer).setNumber(inputVal);
      await tx.wait();
      setCounterValue(await counterContract.number());
      setSignerBalance(await provider.getBalance(signer.address));
    }
  }

  return (
    <div className="App">
      <h1>Counter DApp</h1>
      <div>{signer ? `address: ${signer.address}` : <button onClick={connect}>Connect Wallet</button>}</div>
      <div>{signer ? `balance: ${formatEther(signerBalance)}` : ""}</div>
      <div>{networkId === NETWORK_ID 
        ? <div>
            <div>{`Counter Value: ${counterValue}`}</div>
            <div><button onClick={triggerIncrement}>Increment</button></div>
            <div><button onClick={triggerDecrement}>Decrement</button></div>
            <div>
              <input type="number" value={inputVal} min={1} step={1} 
                onChange={(e) => setInputVal(e.target.value)}/>
              <button onClick={triggerSetNumber}>Set</button></div>
          </div>
        : <p style={{color: "red"}}>
            {`Current network: ${networkId}. Please switch to network ${NETWORK_ID} and refresh the page.`}
          </p>
        }
      </div>
    </div>
  );
}

export default App;
