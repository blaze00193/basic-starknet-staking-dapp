# Basic Starknet Staking DApp 
A full stack Starknet Dapp with functionalities that allows staking of ERC20 tokens deployed to Starknet and getting a reward for the staked token after a period of time. 

The project has three tokens to interact with:
1. `BWCERC20TOKEN`: ERC20 Token that users can use to interact with the project. 
2. `ReceiptToken`: ERC20 Token that users gets as a receipt for staking the `BWCERC20TOKEN`. This token has no intrisic value and can only be used to withdraw the `BWCERC20TOKEN` after the staking period has elapsed.
3. `RewardToken`: ERC20 token that users get as a reward for staking `BWCERC20TOKEN` after a specific period of time.

## How It Works
1. User stakes a specific amount of `BWCERC20TOKEN` into the contract.
    - The contract sends the equivalent of `ReceiptToken` into the user's wallet as a receipt for staking `BWCERC20TOKEN`.
    - The staked token is locked in the contract for period of time.
    - Within this period which the token is locked, the user cannot withdraw the staked token unless the locked period is over.
    - The user can still stake more tokens within this locked period.
    - If at anytime during the locked period, the user stakes more token, the locked period is reset.
2. After the locked period is over, the user is then allowed to withdraw their staked `BWCERC20TOKEN`. 
3. After withdrawal of `BWCERC20TOKEN`, the user is rewarded with `RewardToken` that is directly propotional to the amount of `BWCERC20TOKEN` token staked.


## Getting Started
1. 

## File Structure
```
├── README.md
├── Scarb.lock
├── Scarb.toml
├── dapp
│   ├── README.md
│   ├── index.html
│   ├── node_modules
│   ├── package-lock.json
│   ├── package.json
│   ├── postcss.config.js
│   ├── prettier.config.cjs
│   ├── public
│   │   └── vite.svg
│   ├── src
│   │   ├── App.css
│   │   ├── App.jsx
│   │   ├── assets
│   │   │   ├── bg.jpg
│   │   │   ├── completeLogo.png
│   │   │   ├── down-arrow.svg
│   │   │   ├── react.svg
│   │   │   ├── searchIcon.svg
│   │   │   ├── solanaLogo.png
│   │   │   └── walletIcon.svg
│   │   ├── helpers.js
│   │   ├── index.css
│   │   ├── main.jsx
│   │   ├── pages
│   │   │   ├── FaucetPage.jsx
│   │   │   └── PortfolioPage.jsx
│   │   ├── ui
│   │   │   ├── complex
│   │   │   │   ├── FaucetRequestModal.jsx
│   │   │   │   ├── RequestModalControl.jsx
│   │   │   │   └── StakeContainer.jsx
│   │   │   ├── components
│   │   │   │   ├── CryptoInput.jsx
│   │   │   │   ├── DataROw.jsx
│   │   │   │   ├── FaucetRequestContainer.jsx
│   │   │   │   ├── Logo.jsx
│   │   │   │   ├── Navbar.jsx
│   │   │   │   ├── NavigationLink.jsx
│   │   │   │   ├── NavigationLinks.jsx
│   │   │   │   ├── OverviewContainer.jsx
│   │   │   │   ├── PortfolioContainer.jsx
│   │   │   │   ├── RequestCompleteModal.jsx
│   │   │   │   ├── SelectTokenModal.jsx
│   │   │   │   ├── StepBadge.jsx
│   │   │   │   ├── WaitingForConfirmationModal.jsx
│   │   │   │   └── WalletConnector.jsx
│   │   │   └── layout
│   │   │       ├── AppLayout.jsx
│   │   │       ├── FlexContainer.jsx
│   │   │       └── index.js
│   │   └── utils
│   │       ├── bwc_abi.json
│   │       └── index.js
│   ├── tailwind.config.js
│   └── vite.config.js
├── data
│   └── constructor_args.txt
├── package-lock.json
├── package.json
├── src
│   ├── bwc_erc20_token.cairo
│   ├── bwc_staking_contract.cairo
│   ├── lib.cairo
│   ├── receipt_token.cairo
│   └── reward_token.cairo
├── target
└── tests
    └── test_contract.cairo
```