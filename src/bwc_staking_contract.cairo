use starknet::ContractAddress;

#[starknet::interface]
trait IStake<TContractState> {
    fn stake(
        ref self: TContractState,
        amount: u256,
        BWCERC20TokenAddr: ContractAddress,
        receipt_token: ContractAddress
    ) -> bool;
    fn withdraw(ref self: TContractState, amount: u256, BWCERC20TokenAddr: ContractAddress) -> bool;
    fn get_user_stake_balance(self: @TContractState) -> u256;
    fn time_has_passed(self: @TContractState, time: u64) -> bool;
}

#[starknet::contract]
mod BWCStakingContract {
    /////////////////////////////
    //LIBRARY IMPORTS
    /////////////////////////////    
    use basic_staking_dapp::bwc_staking_contract::IStake;
    use basic_staking_dapp::bwc_erc20_token::IBWCERC20TokenDispatcherTrait;
    use core::serde::Serde;
    use core::integer::u64;
    use core::zeroable::Zeroable;
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};

    use basic_staking_dapp::bwc_erc20_token::{IBWCERC20TokenDispatcher};
    use basic_staking_dapp::receipt_token::{
        IBWCReceiptTokenDispatcher, IBWCReceiptTokenDispatcherTrait
    };

    /////////////////////
    //STAKING DETAIL
    /////////////////////
    // #[derive(Drop)]
    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct StakeDetail {
        time_staked: u64,
        amount: u256,
        status: bool,
    }

    ////////////////////
    //STORAGE
    ////////////////////
    #[storage]
    struct Storage {
        staker: LegacyMap::<ContractAddress, StakeDetail>,
        bwcerc20_token_address: ContractAddress,
    }

    //////////////////
    // CONSTANTS
    //////////////////
    const MIN_STAKE_TIME: u64 =
        3600_u64; // Minimun time (in seconds) staked token can be withdrawn from pool. Equivalent to 1 hour

    /////////////////
    //EVENTS
    /////////////////

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        TokenStaked: TokenStaked,
        TokenWithdraw: TokenWithdraw
    }

    #[derive(Drop, starknet::Event)]
    struct TokenStaked {
        staker: ContractAddress,
        amount: u256,
        time: u64
    }

    #[derive(Drop, starknet::Event)]
    struct TokenWithdraw {
        staker: ContractAddress,
        amount: u256,
        time: u64
    }

    /////////////////
    //CUSTOM ERRORS
    /////////////////
    mod Errors {
        const INSUFFICIENT_FUND: felt252 = 'Insufficient fund';
        const INSUFFICIENT_BALANCE: felt252 = 'Insufficient balance';
        const ADDRESS_ZERO: felt252 = 'Address zero';
        const NOT_TOKEN_ADDRESS: felt252 = 'Not token address';
        const ZERO_AMOUNT: felt252 = 'Zero amount';
        const INSUFFICIENT_FUNDS: felt252 = 'Insufficient funds';
        const NOT_WITHDRAW_TIME: felt252 = 'Not withdraw time';
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        bwcerc20_token_address: ContractAddress,
        receipt_token: ContractAddress,
        amount: u256
    ) {
        // transfer receipt tokens to staking contract
        let address_this: ContractAddress = get_contract_address();
        let caller: ContractAddress = get_caller_address();
        self.bwcerc20_token_address.write(bwcerc20_token_address);
        IBWCReceiptTokenDispatcher { contract_address: receipt_token }
            .transfer_token(address_this, amount);
    }

    #[external(v0)]
    impl IStakeImpl of super::IStake<ContractState> {
        // Function allows caller to stake their token
        // @amount: Amount of token to stake
        // @BWCERC20TokenAddr: Contract address of token to stake
        // @receipt_token: Contract address of receipt token
        fn stake(
            ref self: ContractState,
            amount: u256,
            BWCERC20TokenAddr: ContractAddress,
            receipt_token: ContractAddress
        ) -> bool {
            // CHECK -> EFFECTS -> INTERACTION

            let caller: ContractAddress = get_caller_address(); // Caller address
            let address_this: ContractAddress = get_contract_address(); // Address of this contract
            let bwc_erc20_contract = IBWCERC20TokenDispatcher {
                contract_address: BWCERC20TokenAddr
            };
            let receipt_contract = IBWCReceiptTokenDispatcher { contract_address: receipt_token };

            assert(!caller.is_zero(), Errors::ADDRESS_ZERO); // Caller cannot be address 0
            assert(
                amount >= bwc_erc20_contract.balance_of_token(caller), Errors::INSUFFICIENT_FUNDS
            ); // Caller cannot stake more than token balance
            assert(amount >= 0, Errors::ZERO_AMOUNT); // Cannot stake zero amount
            assert(
                BWCERC20TokenAddr == self.bwcerc20_token_address.read(), Errors::NOT_TOKEN_ADDRESS
            ); // Address must be BWCERC20 Token address

            // TODO: Assert that conttact has enough receipt token for stake amount

            // set storage variable
            let mut stake: StakeDetail = self.staker.read(caller);
            let stake_time: u64 = get_block_timestamp();
            stake.time_staked = stake_time;
            stake.amount += amount; // Increase total amount staked
            stake.status = true;

            // transfer receipt token to depositor
            receipt_contract.transfer_token(caller, amount);

            // approve stake contract to spend receipt token
            receipt_contract.approve_token(address_this, amount);

            // approve stake contract to spend stake token of depositor
            bwc_erc20_contract.approve_token(address_this, amount);

            // transfer stake token from depositor to this contract
            bwc_erc20_contract.transfer_token_from(caller, address_this, amount);

            self.emit(Event::TokenStaked(TokenStaked { staker: caller, amount, time: stake_time }));
            true
        }

        // WIP
        // Function allows caller to withdraw their staked token
        // @amount: Amount of token to withdraw
        // @BWCERC20TokenAddr: Contract address of token to withdraw
        fn withdraw(
            ref self: ContractState, amount: u256, BWCERC20TokenAddr: ContractAddress
        ) -> bool {
            // get address of caller
            let caller = get_caller_address();

            // get stake details
            let mut stake: StakeDetail = self.staker.read(caller);
            // get amount caller has staked
            let stake_amount = stake.amount;
            // get last timestamp caller staked
            let stake_time = stake.time_staked;

            assert(
                amount <= stake_amount, Errors::INSUFFICIENT_FUND
            ); //caller cannot withdraw more than staked amount
            assert(self.time_has_passed(stake_time), Errors::NOT_WITHDRAW_TIME);

            // CONTINUE HERE 

            self
                .emit(
                    Event::TokenWithdraw(TokenWithdraw { staker: caller, amount, time: stake_time })
                );
            true
        }

        fn get_user_stake_balance(self: @ContractState) -> u256 {
            let caller: ContractAddress = get_caller_address();
            return self.staker.read(caller).amount;
        }

        fn time_has_passed(self: @ContractState, time: u64) -> bool {
            let now = get_block_timestamp();

            if (time > now) {
                true
            } else {
                false
            }
        }
    }


    #[generate_trait]
    impl calculateRewardTrait of calculateReward {
        fn calculate_reward(self: ContractState, account: ContractAddress) -> u256 {
            let caller = get_caller_address();
            let stake_status: bool = self.staker.read(caller).status;
            let stake_amount = self.staker.read(caller).amount;
            let stake_time: u64 = self.staker.read(caller).time_staked;
            if stake_status == false {
                return 0;
            }
            let reward_per_month = (stake_amount * 10);
            let time = get_block_timestamp() - stake_time;
            let reward = (reward_per_month * time.into() * 1000) / MIN_STAKE_TIME.into();
            return reward;
        }
    }
}
