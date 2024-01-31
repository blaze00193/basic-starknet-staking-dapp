// // SPDX-License-Identifier: MIT
// use starknet::{ContractAddress, get_caller_address, get_contract_address, get_block_timestamp};

// #[starknet::interface]
// trait IBWCRewardToken<T> {
//     fn mint(ref self: T, recipient: ContractAddress, amount: u256) -> bool;
//     fn burn(ref self: T, value: u256) -> bool;
//     fn transfer(ref self: T, to: ContractAddress, amount: u256) -> bool;
//     fn transfer_from(
//         ref self: T, from: ContractAddress, spender: ContractAddress, amount: u256
//     ) -> bool;
//     fn approve(ref self: T, spender: ContractAddress, amount: u256) -> bool;
// }

// #[starknet::contract]
// mod BWCRewardToken {
//     use core::zeroable::Zeroable;
//     use starknet::{ContractAddress, get_caller_address};
//     use super::IBWCRewardToken;

//     use openzeppelin::token::erc20::interface::IERC20;
//     use openzeppelin::token::erc20::erc20::ERC20Component::InternalTrait;
//     use openzeppelin::token::erc20::ERC20Component;
//     use openzeppelin::access::ownable::OwnableComponent;

//     // Components import
//     component!(path: ERC20Component, storage: erc20, event: ERC20Event);
//     component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

//     // External implementations from components

//     #[abi(embed_v0)]
//     impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;

//     #[abi(embed_v0)]
//     impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;

//     #[abi(embed_v0)]
//     impl OwnableImpl = OwnableComponent::OwnableImpl<ContractState>;

//     #[abi(embed_v0)]
//     impl OwnableCamelOnlyImpl =
//         OwnableComponent::OwnableCamelOnlyImpl<ContractState>;

//     // Internal implelemntations from components

//     impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

//     impl OwnableInternalImpl = OwnableComponent::InternalImpl<ContractState>;

//     #[storage]
//     struct Storage {
//         #[substorage(v0)]
//         erc20: ERC20Component::Storage,
//         #[substorage(v0)]
//         ownable: OwnableComponent::Storage,
//     }

//     #[event]
//     #[derive(Drop, starknet::Event)]
//     enum Event {
//         #[flat]
//         ERC20Event: ERC20Component::Event,
//         #[flat]
//         OwnableEvent: OwnableComponent::Event,
//     }

//     /////////////////
//     //CUSTOM ERRORS
//     /////////////////
//     mod Errors {
//         const TRANSFER_ADDRESS_ZERO: felt252 = 'Transfer to zero address';
//         const OWNER_ADDRESS: felt252 = 'Owner cant be zero address';
//         const CALLER_NOT_OWNER: felt252 = 'Caller not owner';
//         const ADDRESS_ZERO: felt252 = 'Adddress zero';
//         const INSUFFICIENT_FUND: felt252 = 'Insufficient fund';
//         const APPROVED_TOKEN: felt252 = 'You have no token approved';
//         const AMOUNT_NOT_ALLOWED: felt252 = 'Amount not allowed';
//         const ZERO_AMOUNT: felt252 = 'Amount cannot be zero';
//         const MSG_SENDER_NOT_OWNER: felt252 = 'Msg_sender not owner';
//         const TRANSFER_FROM_ADDRESS_ZERO: felt252 = 'Transfer from 0';
//         const TRANSFER_TO_ADDRESS_ZERO: felt252 = 'Transfer to 0';
//         const APPROVE_FROM_ADDRESS_ZERO: felt252 = 'Approve from 0';
//         const APPROVE_TO_ADDRESS_ZERO: felt252 = 'Approve to 0';
//     }

//     #[constructor]
//     fn constructor(ref self: ContractState, recipient: ContractAddress, owner: ContractAddress) {
//         self.erc20.initializer('BWCRewardToken', 'wBWCRT');
//         self.ownable.initializer(owner);

//         self.erc20._mint(recipient, 10000000000000000000000); // Mint 10,000 tokens
//     }

//     #[external(v0)]
//     impl IBWCRewardTokenImpl of IBWCRewardToken<ContractState> {
//         fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
//             assert(amount != 0, Errors::ZERO_AMOUNT); // Cannot mint 0 tokens
//             assert(!recipient.is_zero(), Errors::ADDRESS_ZERO); // Cannot mint to address 0

//             self.ownable.assert_only_owner();
//             self.erc20._mint(recipient, amount);

//             true
//         }

//         fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
//             let caller = get_caller_address();

//             assert(
//                 self.erc20.balance_of(caller) >= amount, Errors::INSUFFICIENT_FUND
//             ); // Cannot approve more than token balance
//             assert(amount != 0, Errors::ZERO_AMOUNT); // Cannot approve 0 tokens

//             self.erc20._approve(caller, spender, amount);

//             true
//         }

//         fn transfer(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
//             let caller = get_caller_address();

//             assert(
//                 self.erc20.balance_of(caller) >= amount, Errors::INSUFFICIENT_FUND
//             ); // Sender must have enough tokens to transfer 
//             assert(amount != 0, Errors::ZERO_AMOUNT); // Cannot transfer 0 tokens

//             self.erc20.transfer(to, amount);

//             true
//         }

//         fn transfer_from(
//             ref self: ContractState, from: ContractAddress, spender: ContractAddress, amount: u256
//         ) -> bool {
//             let caller = get_caller_address();

//             assert(amount != 0, Errors::ZERO_AMOUNT); // Cannot transfer 0 tokens
//             assert(
//                 self.erc20.allowance(from, caller) >= amount, Errors::AMOUNT_NOT_ALLOWED
//             ); // Caller cannot spend more than allowed amount from owner account     
//             assert(
//                 self.erc20.balance_of(from) >= amount, Errors::INSUFFICIENT_FUND
//             ); // Owner must have enough tokens to be transferred

//             self.erc20.transfer_from(from, spender, amount);

//             true
//         }

//         fn burn(ref self: ContractState, value: u256) -> bool {
//             let caller = get_caller_address();

//             assert(value != 0, Errors::ZERO_AMOUNT); // Burn amount cannnot be 0
//             assert(
//                 self.erc20.balance_of(caller) >= value, ''
//             ); // Caller must have enough token to burn

//             self.erc20._burn(caller, value); // Burn 'value' from caller account

//             true
//         }
//     }
// }


