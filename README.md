# Basic Starknet Staking DApp 
A full stack Starknet Dapp with functionalities that allows staking of ERC20 tokens deployed to Starknet and getting a reward for the staked token after a period of time. 

The project has three tokens to interract with:
1. `BWCERC20TOKEN`: ERC20 Token that users can use to interact with the project. 
2. `ReceiptToken`: ERC20 Token that users gets as a receipt for staking the `BWCERC20TOKEN`. This token has no intrisic value and can only be used to withdraw the `BWCERC20TOKEN` after the staking period has elapsed.
3. `RewardToken`: ERC20 token that users get as a reward for staking `BWCERC20TOKEN` after a specific period of time.

## How It Works
1.


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