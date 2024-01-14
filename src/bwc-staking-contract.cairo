use starknet::ContractAddress;
use bwc_erc20_token::bwc_staking_contract;

//  #[derive(Drop,storage_access::StorageAccess)]
// struct StakeDetail {
//     timeStaked: u64,
//     amount: u256,
//     status:bool,
// }

#[starknet::interface]
trait StakingTokenTrait<TContractState> {
    // fn depositBWC(ref self: TContractState, amount: u256) -> bool;
    fn stakeBWCToken(ref self: TContractState, amount: u256, BWCERC20TokenAddr: ContractAddress);
    fn withdrawBWCToken(ref self: TContractState, amount: u256, BWCERC20TokenAddr: ContractAddress);
    fn getUserBalance(self: @TContractState) -> u256;
// fn getStakeDetailsByAddress(self: @ContractState, account:ContractAddress) -> StakeDetail;
}

#[starknet::contract]
mod BWCStakingContract {
    /////////////////////////////
    //LIBRARY IMPORTS
    /////////////////////////////

    use starknet::ContractAddress;
    use starknet::{get_caller_address, get_contract_address, get_block_timestamp};
    use new_syntax::interfaces::IBWCERC20TokenDispatcherTrait;
    use new_syntax::interfaces::IBWCERC20TokenDispatcher;
    use integer::Into;
    use core::serde::Serde;
    use core::integer::u64;

    /////////////////////
    //STAKING DETAIL
    /////////////////////
    // #[derive(Drop)]
    #[derive(Drop, storage_access::StorageAccess)]
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
    // CONSTANT
    //////////////////
    const minStakeTime: u64 = 259200_u64;


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


    #[external(v0)]
    impl StakingTokenTraitImpl of super::StakingTokenTrait<ContractState> {
        // fn depositBWC(ref self: ContractState, amount: u256) -> bool {
        //     IBWCERC20TokenDispatcher { contract_address: BWCERC20TokenAddr }
        //         .transfer_from(
        //             contract_address = reward_token_address,
        //             sender = caller_address,
        //             recipient = contract_address,
        //             amount: u256
        //         )
        // }
        fn stakeBWCToken(
            ref self: ContractState, amount: u256, BWCERC20TokenAddr: ContractAddress
        ) {
            let caller: ContractAddress = get_caller_address();
            let address_this = get_contract_address();
            assert(
                (IBWCERC20TokenDispatcher { contract_address: BWCERC20TokenAddr }
                    .get_balance_of(caller) >= amount),
                'BWCERC20Token:Insufficient Balance'
            );
            IBWCERC20TokenDispatcher { contract_address: BWCERC20TokenAddr }
                .transfer_from(caller, address_this, amount);
            let stake_status: bool = self.staker.read(caller).status;
            let stake_time: u64 = self.staker.read(caller).timeStaked;
            let mut stake: StakeDetail = self.staker.read(caller);
            if stake_status == true {
                let day_spent = get_block_timestamp() - stake_time;
                if day_spent > minStakeTime {
                    let reward = self.calculateReward(caller);
                    stake.amount += reward;
                    stake.amount -= amount;
                    stake.timeStaked += get_block_timestamp();
                } else {
                    stake.amount -= amount;
                    stake.timeStaked = get_block_timestamp();
                }
                IBWCERC20TokenDispatcher { contract_address: BWCERC20TokenAddr }
                    .transfer(caller, amount);
                stake.timeStaked = get_block_timestamp();

                if stake.amount > 0 {
                    stake.status = true;
                } else {
                    stake.status = false;
                }
            }
            self.emit(Event::TokenStaked(TokenStaked { staker: caller, amount, time: stake_time }));
        }

        fn withdrawBWCToken(
            ref self: ContractState, amount: u256, BWCERC20TokenAddr: ContractAddress
        ) {
            let caller = get_caller_address();
            let stake_amount = self.staker.read(caller).amount;
            let stake_time = self.staker.read(caller).timeStaked;
            let day_spent = get_block_timestamp() - stake_time;
            let mut stake: StakeDetail = self.staker.read(caller);
            assert(amount <= stake_amount, 'Insufficient fund');
            if day_spent > minStakeTime {
                let reward = self.calculateReward(caller);
                stake.amount += reward;
                stake.amount -= amount;
                stake.timeStaked = get_block_timestamp();
            } else {
                stake.amount = stake.amount - amount;
                stake.timeStaked = get_block_timestamp();
            }
            IBWCERC20TokenDispatcher { contract_address: BWCERC20TokenAddr }
                .transfer(caller, amount);
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
        }

        fn getUserBalance(self: @ContractState) -> u256 {
            let caller: ContractAddress = get_caller_address();
            return self.staker.read(caller).amount;
        }
    // getStakeDetailsByAddress
    // fn getStakeDetailsByAddress(self: @ContractState, account:ContractAddress) ->super::StakeDetail{
    //     return self.staker.read(account);
    // }
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
            let reward = (reward_per_month * time.into() * 1000) / minStakeTime.into();
            return reward;
        }
    }
}
