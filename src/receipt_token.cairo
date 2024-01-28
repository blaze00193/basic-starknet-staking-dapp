// SPDX-License-Identifier: MIT
use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};
#[starknet::interface]
trait IReceiptToken<T> {
    fn mint(ref self: T, recipient: ContractAddress, amount: u256) -> bool;
    fn burn(ref self: T, value: u256) -> bool;
    fn _transfer(ref self: T, to: ContractAddress, amount: u256) -> bool;
    fn _transfer_from(
        ref self: T, from: ContractAddress, spender: ContractAddress, amount: u256
    ) -> bool;
    fn _approve(ref self: T, spender: ContractAddress, amount: u256) -> bool;
}
#[starknet::contract]
mod ReceiptToken {
    use openzeppelin::token::erc20::interface::IERC20;
    use openzeppelin::token::erc20::erc20::ERC20Component::InternalTrait;
    use super::IReceiptToken;
    use core::zeroable::Zeroable;


    use openzeppelin::token::erc20::ERC20Component;
    use openzeppelin::access::ownable::OwnableComponent;
    use starknet::{ContractAddress, get_caller_address};

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20CamelOnlyImpl = ERC20Component::ERC20CamelOnlyImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;
    #[abi(embed_v0)]
    impl OwnableCamelOnlyImpl =
        OwnableComponent::OwnableCamelOnlyImpl<ContractState>;

    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;
    impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event,
        #[flat]
        OwnableEvent: OwnableComponent::Event,
    }


    /////////////////
    //CUSTOM ERRORS
    /////////////////
    mod Errors {
        const TRANSFER_ADDRESS_ZERO: felt252 = 'Transfer to zero address';
        const OWNER_ADDRESS: felt252 = 'Owner cant be zero address';
        const CALLER_NOT_OWNER: felt252 = 'Caller not owner';
        const ADDRESS_ZERO: felt252 = 'Adddress zero';
        const INSUFFICIENT_FUND: felt252 = 'Insufficient fund';
        const APPROVED_TOKEN: felt252 = 'You have no token approved';
        const AMOUNT_NOT_ALLOWED: felt252 = 'Amount not allowed';
        const ZERO_AMOUNT: felt252 = 'Amount cannot be zero';
        const MSG_SENDER_NOT_OWNER: felt252 = 'Msg_sender not owner';
        const TRANSFER_FROM_ADDRESS_ZERO: felt252 = 'Transfer from 0';
        const TRANSFER_TO_ADDRESS_ZERO: felt252 = 'Transfer to 0';
        const APPROVE_FROM_ADDRESS_ZERO: felt252 = 'Approve from 0';
        const APPROVE_TO_ADDRESS_ZERO: felt252 = 'Approve to 0';
    }
    #[constructor]
    fn constructor(ref self: ContractState, recipient: ContractAddress, owner: ContractAddress) {
        self.erc20.initializer('ReceiptBWC', 'RBC');
        self.ownable.initializer(owner);

        self.erc20._mint(recipient, 10000000000000000000000);
    }

    // #[generate_trait]
    #[external(v0)]
    impl IReceiptTokenImpl of IReceiptToken<ContractState> {
        fn burn(ref self: ContractState, value: u256) -> bool {
            assert(value != 0, Errors::ZERO_AMOUNT);
            let caller = get_caller_address();
            self.erc20._burn(caller, value);
            true
        }

        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            assert(amount != 0, Errors::ZERO_AMOUNT);
            self.ownable.assert_only_owner();
            assert(!recipient.is_zero(), Errors::ADDRESS_ZERO);
            self.erc20._mint(recipient, amount);
            true
        }

        fn _transfer(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
            self.erc20.transfer(to, amount);
            true
        }


        fn _approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
            assert(amount != 0, Errors::ZERO_AMOUNT);
            assert(!spender.is_zero(), Errors::ADDRESS_ZERO);
            let caller = get_caller_address();
            self.erc20._approve(caller, spender, amount);
            true
        }

        fn _transfer_from(
            ref self: ContractState, from: ContractAddress, spender: ContractAddress, amount: u256
        ) -> bool {
            self.erc20.transfer_from(from, spender, amount);
            true
        }
    }
}
