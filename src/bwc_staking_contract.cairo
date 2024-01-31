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
}

#[starknet::contract]
mod BWCStakingContract {
    /////////////////////////////
    //LIBRARY IMPORTS
    /////////////////////////////
    use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};
    use core::zeroable::Zeroable;

    use basic_staking_dapp::bwc_erc20_token::{IERC20Dispatcher, IERC20DispatcherTrait};
    use basic_staking_dapp::receipt_token::{
        IBWCReceiptTokenDispatcher, IBWCReceiptTokenDispatcherTrait
    };
    //use integer::Into;
    use core::serde::Serde;
    use core::integer::u64;

    /////////////////////
    //STAKING DETAIL
    /////////////////////
    // #[derive(Drop)]
    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct StakeDetail {
        timeStaked: u64,
        amount: u256,
        status: bool,
    }

    ////////////////////
    //STORAGE
    ////////////////////
    #[storage]
    struct Storage {
        staker: LegacyMap::<ContractAddress, StakeDetail>
    }


    //////////////////
    // CONSTANTS
    //////////////////

    const min_stake_time: u64 =
        3600_u64; // Minimun time staked token can be withdrawn from pool. Equivalent to 1 hour
    // const bwc_stake_token: ContractAddress = '';

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
        const ADDRESS_ZERO: felt252 = 'Adddress zero';
    }

    #[constructor]
    fn constructor(ref self: ContractState, receipt_token: ContractAddress, amount: u256) {
        // transfer receipt tokens to staking contract
        let address_this: ContractAddress = get_contract_address();
        let caller: ContractAddress = get_caller_address();
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
            let caller: ContractAddress = get_caller_address();
            assert(!caller.is_zero(), Errors::ADDRESS_ZERO);

            // set storage variable
            let mut stake: StakeDetail = self.staker.read(caller);
            let stake_time: u64 = get_block_timestamp();
            stake.timeStaked = stake_time;
            stake.amount += amount; // Increase total amount staked
            stake.status = true;
            // todo - validate bwctokenaddr

            // get address of this contract
            let address_this: ContractAddress = get_contract_address();

            // transfer receipt token to depositor
            IBWCReceiptTokenDispatcher { contract_address: receipt_token }.transfer_token(caller, amount);

            // approve stake contract to spend receipt token
            IBWCReceiptTokenDispatcher { contract_address: address_this }
                .approve_token(address_this, amount);

            // approve stake contract to spend stake token of depositor
            IERC20Dispatcher { contract_address: BWCERC20TokenAddr }.approve(address_this, amount);

            // transfer stake token from depositor to this contract
            IERC20Dispatcher { contract_address: BWCERC20TokenAddr }
                .transfer_from(caller, address_this, amount);

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

            // 
            let mut stake: StakeDetail = self.staker.read(caller);

            // get amount caller has staked
            let stake_amount = stake.amount;

            // get last timestamp caller staked
            let stake_time = stake.timeStaked;

            // get how many days has passed since caller last staked
            let day_spent = get_block_timestamp() - stake_time;

            // assert that caller cannot withdraw more than staked amount
            assert(amount <= stake_amount, Errors::INSUFFICIENT_FUND);

            // 👀👀👀
            if day_spent > min_stake_time {
                let reward = self.calculateReward(caller);
                stake.amount += reward;
                stake.amount -= amount;
                stake.timeStaked = get_block_timestamp();
            } else {
                stake.amount = stake.amount - amount;
                stake.timeStaked = get_block_timestamp();
            }

            IERC20Dispatcher { contract_address: BWCERC20TokenAddr }.transfer(caller, amount);
            stake.timeStaked = get_block_timestamp();

            if stake.amount > 0 {
                stake.status = true;
            } else {
                stake.status = false;
            }
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
    }


    #[generate_trait]
    impl calculateRewardTrait of calculateReward {
        fn calculateReward(self: ContractState, account: ContractAddress) -> u256 {
            let caller = get_caller_address();
            let stake_status: bool = self.staker.read(caller).status;
            let stake_amount = self.staker.read(caller).amount;
            let stake_time: u64 = self.staker.read(caller).timeStaked;
            if stake_status == false {
                return 0;
            }
            let reward_per_month = (stake_amount * 10);
            let time = get_block_timestamp() - stake_time;
            let reward = (reward_per_month * time.into() * 1000) / min_stake_time.into();
            return reward;
        }
    }
}
