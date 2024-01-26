use starknet::ContractAddress;
#[starknet::interface]
trait IERC20<TContractState> {
    fn get_name(self: @TContractState) -> felt252;
    fn get_symbol(self: @TContractState) -> felt252;
    fn get_decimals(self: @TContractState) -> u8;
    //fn totalSupply(ref self: TContractState, to: ContractAddress, amount: u256);
    fn get_total_supply(self: @TContractState) -> u256;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
    fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256);
    fn transfer_from(
        ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    );
    fn approve(ref self: TContractState, spender: ContractAddress, amount: u256);
    fn increase_allowance(ref self: TContractState, spender: ContractAddress, added_value: u256);
    fn decrease_allowance(
        ref self: TContractState, spender: ContractAddress, subtracted_value: u256
    );

    fn mint(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;

    fn burn(ref self: TContractState, amount: u256) -> bool;
}

#[starknet::contract]
mod BWCERC20Token {
    // importing necessary libraries
    use starknet::{ContractAddress, get_caller_address, contract_address_const};
    use core::zeroable::Zeroable;
    use super::IERC20;

    //Storage Variables
    #[storage]
    struct Storage {
        name: felt252,
        owner: ContractAddress,
        symbol: felt252,
        decimals: u8,
        total_supply: u256,
        balances: LegacyMap<ContractAddress, u256>,
        allowances: LegacyMap<
            (ContractAddress, ContractAddress), u256
        >, //similar to mapping(address => mapping(address => uint256))
    }

    //  Event
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Approval: Approval,
        Transfer: Transfer
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer {
        from: ContractAddress,
        to: ContractAddress,
        value: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Approval {
        owner: ContractAddress,
        spender: ContractAddress,
        value: u256,
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
        const MSG_SENDER_NOT_OWNER: felt252 = 'Msg_sender not owner';
        const TRANSFER_FROM_ADDRESS_ZERO: felt252 = 'Transfer from 0';
        const TRANSFER_TO_ADDRESS_ZERO: felt252 = 'Transfer to 0';
        const APPROVE_FROM_ADDRESS_ZERO: felt252 = 'Approve from 0';
        const APPROVE_TO_ADDRESS_ZERO: felt252 = 'Approve to 0';
    }

    // Note: The contract constructor is not part of the interface. Nor are internal functions part of the interface.

    // Constructor 
    #[constructor]
    fn constructor(ref self: ContractState, //_owner: ContractAddress,
     // _name: felt252,
    // _symbol: felt252,
    // _decimal: u8,
    // _initial_supply: u256,
    recipient: ContractAddress) {
        // The .is_zero() method here is used to determine whether the address type recipient is a 0 address, similar to recipient == address(0) in Solidity.
        assert(!recipient.is_zero(), Errors::TRANSFER_ADDRESS_ZERO);
        // assert(!_owner.is_zero(), Errors::OWNER_ADDRESS);
        //self.owner.write(_owner);
        // self.name.write(_name);
        // self.symbol.write(_symbol);
        // self.decimals.write(_decimal);
        // self.total_supply.write(_initial_supply);
        // self.balances.write(recipient, _initial_supply);
        self.owner.write(recipient);

        self.name.write('BlockheaderToken');
        self.symbol.write('BWC');
        self.decimals.write(18);
        self.total_supply.write(1000000);
        self.balances.write(recipient, 1000000);

        self
            .emit(
                Transfer { //Here, `contract_address_const::<0>()` is similar to address(0) in Solidity
                    from: contract_address_const::<0>(), to: recipient, value: 1000000
                }
            );
    }


    #[external(v0)]
    impl IERC20Impl of IERC20<ContractState> {
        fn get_name(self: @ContractState) -> felt252 {
            self.name.read()
        }
        fn get_symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn get_decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        fn get_total_supply(self: @ContractState) -> u256 {
            self.total_supply.read()
        }


        fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
            self.balances.read(account)
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> u256 {
            self.allowances.read((owner, spender))
        }


        fn mint(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
            let owner = self.owner.read();
            let caller = get_caller_address();
            assert(owner == caller, Errors::CALLER_NOT_OWNER);
            assert(!recipient.is_zero(), Errors::ADDRESS_ZERO);
            assert(self.balances.read(self.owner.read()) >= amount, Errors::INSUFFICIENT_FUND);
            self.balances.write(self.owner.read(), self.balances.read(owner) - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.total_supply.write(self.total_supply.read() - amount); // Updated the total supply

            true
        }


        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            self.transfer_helper(caller, recipient, amount);
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) {
            let caller = get_caller_address();
            let my_allowance = self.allowances.read((sender, caller));

            assert(my_allowance > 0, Errors::APPROVED_TOKEN);
            assert(amount <= my_allowance, Errors::AMOUNT_NOT_ALLOWED);
            // assert(my_allowance <= amount, 'Amount Not Allowed');

            self
                .spend_allowance(
                    sender, caller, amount
                ); //responsible for deduction of the amount allowed to spend
            self.transfer_helper(sender, recipient, amount);
        }
        fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) {
            let caller = get_caller_address();
            self.approve_helper(caller, spender, amount);
        }

        fn increase_allowance(
            ref self: ContractState, spender: ContractAddress, added_value: u256
        ) {
            let caller = get_caller_address();
            self
                .approve_helper(
                    caller, spender, self.allowances.read((caller, spender)) + added_value
                );
        }

        fn decrease_allowance(
            ref self: ContractState, spender: ContractAddress, subtracted_value: u256
        ) {
            let caller = get_caller_address();
            self
                .approve_helper(
                    caller, spender, self.allowances.read((caller, spender)) - subtracted_value
                );
        }


        fn burn(ref self: ContractState, amount: u256) -> bool {
            let owner = self.owner.read();
            let caller = get_caller_address();

            // Check if the caller is the owner.
            assert(owner == caller, Errors::CALLER_NOT_OWNER);

            // Check if the balance of the owner is greater than or equal to the amount to burn.
            assert(self.balances.read(owner) >= amount, Errors::INSUFFICIENT_FUND);

            // Subtract the amount from the owner's balance.
            self.balances.write(owner, self.balances.read(owner) - amount);

            // Update the total supply.
            self.total_supply.write(self.total_supply.read() - amount);

            true
        }
    }
    #[generate_trait]
    impl HelperImpl of HelperTrait {
        fn transfer_helper(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: u256
        ) {
            let sender_balance = self.balance_of(sender);

            assert(!sender.is_zero(), Errors::TRANSFER_FROM_ADDRESS_ZERO);
            assert(!recipient.is_zero(), Errors::TRANSFER_TO_ADDRESS_ZERO);
            assert(sender_balance >= amount, Errors::INSUFFICIENT_FUND);
            self.balances.write(sender, self.balances.read(sender) - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            true;

            self.emit(Transfer { from: sender, to: recipient, value: amount, });
        }

        fn approve_helper(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            assert(!owner.is_zero(), Errors::APPROVE_FROM_ADDRESS_ZERO);
            assert(!spender.is_zero(), Errors::APPROVE_TO_ADDRESS_ZERO);

            self.allowances.write((owner, spender), amount);

            self.emit(Approval { owner, spender, value: amount, })
        }

        fn spend_allowance(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            // First, read the amount authorized by owner to spender
            let current_allowance = self.allowances.read((owner, spender));

            // define a variable ONES_MASK of type u128
            let ONES_MASK = 0xfffffffffffffffffffffffffffffff_u128;

            // to determine whether the authorization is unlimited, 

            let is_unlimited_allowance = current_allowance.low == ONES_MASK
                && current_allowance
                    .high == ONES_MASK; //equivalent to type(uint256).max in Solidity.

            // This is also a way to save gas, because if the authorized amount is the maximum value of u256, theoretically, this amount cannot be spent.
            if !is_unlimited_allowance {
                self.approve_helper(owner, spender, current_allowance - amount);
            }
        }
    }
}

#[cfg(test)]
mod test {
    use core::serde::Serde;
    use super::{IERC20, BWCERC20Token, IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::ContractAddress;
    use starknet::contract_address::contract_address_const;
    use core::ArrayTrait;
    use snforge_std::{declare, ContractClassTrait, fs::{FileTrait, read_txt}};
    use snforge_std::{start_prank, stop_prank, CheatTarget};
    use snforge_std::PrintTrait;
    use core::{Into, TryInto};

    // helper function
    fn deploy_contract() -> ContractAddress {
        let erc20_contract_class = declare('BWCERC20Token');
        let file = FileTrait::new('data/constructor_args.txt');
        let constructor_args = read_txt(@file);

        let contract_address = erc20_contract_class.deploy(@constructor_args).unwrap();
        contract_address
    }

    #[test]
    fn test_constructor() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        let name = dispatcher.get_name();
        assert(name == 'BlockheaderToken', Errors::INCORRECT_NAME);
    }

    #[test]
    fn test_name() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        let name = dispatcher.get_name();
        assert(name == 'BlockheaderToken', Errors::INCORRECT_NAME);
    }

    #[test]
    fn test_symbol_is_correct() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        let symbol = dispatcher.get_symbol();
        assert(symbol == 'BWC', Errors::INCORRECT_SYMBOLS);
    }

    #[test]
    fn test_decimal_is_correct() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        let decimal = dispatcher.get_decimals();
        assert(decimal == 18, Errors::INVALID_DECIMALS);
    }

    #[test]
    fn test_total_supply() {
        let address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address: address };
        let total_supply = dispatcher.get_total_supply();
        assert(total_supply == 1000000, Errors::UNMATCHED_SUPPLY);
    }

    #[test]
    fn test_address_balance() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        let balance = dispatcher.get_total_supply();
        let admin_balance = dispatcher.balance_of(Account::admin());
        assert(admin_balance == balance, Errors::INVALID_BALANCE);

        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.transfer(Account::user1(), 10);
        let new_admin_balance = dispatcher.balance_of(Account::admin());
        new_admin_balance.print();
        assert(new_admin_balance == balance - 10, Errors::INVALID_BALANCE);
        stop_prank(CheatTarget::One(contract_address));

        let user1_balance = dispatcher.balance_of(Account::user1());
        assert(user1_balance == 10, Errors::INVALID_BALANCE);
    }

    #[test]
    fn test_allowance() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };

        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.approve(contract_address, 10);
        assert(
            dispatcher.allowance(Account::admin(), contract_address) == 10, Errors::INVALID_BALANCE
        );
        stop_prank(CheatTarget::One(contract_address));
    }

    #[test]
    fn test_transfer() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.transfer(Account::user1(), 10);
        let user1_balance = dispatcher.balance_of(Account::user1());
        assert(user1_balance == 10, Errors::INVALID_BALANCE);

        stop_prank(CheatTarget::One(contract_address));
    }

    #[test]
    fn test_transfer_from() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        let user1 = Account::user1();
        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.approve(user1, 10);
        assert(dispatcher.allowance(Account::admin(), user1) == 10, Errors::NOT_ALLOWED);
        stop_prank(CheatTarget::One(contract_address));

        start_prank(CheatTarget::One(contract_address), user1);
        dispatcher.transfer_from(Account::admin(), Account::user2(), 5);
        assert(dispatcher.balance_of(Account::user2()) == 5, Errors::INVALID_BALANCE);
        // dispatcher.transfer_from(Account::admin(), user1, 15);
        // assert(dispatcher.balance_of(user1) == 5, Errors::INVALID_BALANCE);
        stop_prank(CheatTarget::One(contract_address));
    }

    #[test]
    #[should_panic(expected: ('You have no token approved',))]
    fn test_transfer_from_failed_when_not_approved() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };
        start_prank(CheatTarget::One(contract_address), Account::user1());
        dispatcher.transfer_from(Account::admin(), Account::user2(), 5);
    }

    #[test]
    fn test_mint() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };

        let admin = Account::admin();
        let user1 = Account::user1();
        let mint_amount: u256 = 10;

        // Ensure the user1's balance before the mint operation
        let initial_user1_balance = dispatcher.balance_of(Account::user1());
        let initial_total_supply = dispatcher.get_total_supply();

        start_prank(CheatTarget::One(contract_address), Account::admin());
        dispatcher.mint(Account::user1(), mint_amount);

        // Check user1's balance after the mint operation
        assert(
            dispatcher.balance_of(Account::user1()) == initial_user1_balance + mint_amount,
            Errors::INVALID_BALANCE
        );

        // Check the total supply after the mint operation
        assert(
            dispatcher.get_total_supply() == initial_total_supply - mint_amount,
            Errors::UNMATCHED_SUPPLY
        );

        stop_prank(CheatTarget::One(contract_address));
    }

    #[test]
    fn test_burn() {
        let contract_address = deploy_contract();
        let dispatcher = IERC20Dispatcher { contract_address };

        let owner = Account::admin();
        let burn_amount: u256 = 10;

        // Ensure the owner's balance before the burn operation
        let initial_owner_balance = dispatcher.balance_of(owner);
        let initial_total_supply = dispatcher.get_total_supply();

        start_prank(CheatTarget::One(contract_address), owner);
        dispatcher.burn(burn_amount);

        // Check owner's balance after the burn operation
        assert(
            dispatcher.balance_of(owner) == initial_owner_balance - burn_amount,
            Errors::INVALID_BALANCE
        );

        // Check the total supply after the burn operation
        assert(
            dispatcher.get_total_supply() == initial_total_supply - burn_amount,
            Errors::UNMATCHED_SUPPLY
        );
        stop_prank(CheatTarget::One(contract_address));
    }


    mod Errors {
        const INVALID_DECIMALS: felt252 = 'Invalid decimals';
        const UNMATCHED_SUPPLY: felt252 = 'Unmatched supply';
        const INVALID_BALANCE: felt252 = 'Invalid balance';
        const NOT_ALLOWED: felt252 = 'Not allowed';
        const INCORRECT_NAME: felt252 = 'Name is not correct';
        const INCORRECT_SYMBOLS: felt252 = 'Symbols is not correct';
    }

    mod Account {
        use core::option::OptionTrait;
        use starknet::ContractAddress;
        use core::TryInto;

        fn user1() -> ContractAddress {
            'joy'.try_into().unwrap()
        }

        fn user2() -> ContractAddress {
            'caleb'.try_into().unwrap()
        }
        fn admin() -> ContractAddress {
            'admin'.try_into().unwrap()
        }
    }
}

