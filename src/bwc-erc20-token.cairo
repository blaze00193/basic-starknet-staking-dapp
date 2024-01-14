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

    fn burn(ref self: TContractState, to: ContractAddress, amount: u256) -> bool;
}

#[starknet::contract]
mod BWCERC20Token {
    // importing necessary libraries
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use starknet::contract_address_const; //similar to address(0) in Solidity
    use core::zeroable::Zeroable;
    use super::IERC20;

    //Stroge Variables
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

    // Note: The contract constructor is not part of the interface. Nor are internal functions part of the interface.

    // Constructor 
    #[constructor]
    fn constructor(
        ref self: ContractState,
        _owner: ContractAddress,
        _name: felt252,
        _symbol: felt252,
        _decimal: u8,
        _initial_supply: u256,
        recipient: ContractAddress
    ) {
        // The .is_zero() method here is used to determine whether the address type recipient is a 0 address, similar to recipient == address(0) in Solidity.
        assert(!recipient.is_zero(), 'transfer to zero address');
        assert(!_owner.is_zero(), 'owner cant be zero addr');
        self.owner.write(_owner);
        self.name.write(_name);
        self.symbol.write(_symbol);
        self.decimals.write(_decimal);
        self.total_supply.write(_initial_supply);
        self.balances.write(recipient, _initial_supply);

        self
            .emit(
                Transfer {
                    //Here, `contract_address_const::<0>()` is similar to address(0) in Solidity
                    from: contract_address_const::<0>(), to: recipient, value: _initial_supply
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
            assert(owner == caller, 'caller not owner');
            assert(!recipient.is_zero(), 'ERC20: Adddress zero');
            assert(self.balances.read(recipient) >= amount, 'Insufficient fund');
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.total_supply.write(self.total_supply.read() - amount);
            // call tranfer 
            // Transfer(Zeroable::zero(), recipient, amount);

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
            let my_allowance = self.allowances.read((sender, recipient));
            assert(my_allowance <= amount, 'Amount Not Allowed');
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

        fn burn(ref self: ContractState, to: ContractAddress, amount: u256) -> bool {
            let owner = self.owner.read();
            let msg_sender = get_caller_address();
            assert(owner == msg_sender, 'msg_sender not owner');

            assert(self.balances.read(to) >= amount, 'Insufficient fund');

            self.balances.write(msg_sender, self.balances.read(msg_sender) - amount);

            // call transfer

            // Transfer(Zeroable::zero(), to, amount);

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

            assert(!sender.is_zero(), 'transfer from 0');
            assert(!recipient.is_zero(), 'transfer to 0');
            assert(sender_balance >= amount, 'Insufficient fund');
            self.balances.write(sender, self.balances.read(sender) - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            true;

            self.emit(Transfer { from: sender, to: recipient, value: amount, });
        }

        fn approve_helper(
            ref self: ContractState, owner: ContractAddress, spender: ContractAddress, amount: u256
        ) {
            assert(!owner.is_zero(), 'approve from 0');
            assert(!spender.is_zero(), 'approve to 0');

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
