module lottery::lottery {
    // This module defines the lottery system.
    // Importing necessary modules from the standard library and SUI.
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::random::{Random, new_generator};
    use sui::clock::{Self, Clock};
    use sui::balance::{Self, Balance};
    use sui::object::{Self, UID, ID};
    use sui::transfer;
    use sui::tx_context::{self, TxContext};
    use std::option::{none, some, is_some};
    use std::vector;
    // Structs definition for the lottery system.
    // Struct to store information about the administrator of the lottery system.
    public struct AdminCap has key, store {
        id: UID,
        lotteries: vector<ID>, // Vector to store the IDs of lotteries managed by the administrator.
    }
    // Struct to represent a lottery.
    public struct Lottery has key, store {
        id: UID,
        players: vector<address>, // Vector to store the addresses of players participating in the lottery.
        winner: Option<address>, // Optional field to store the address of the winner.
        price: u64, // Price of a single entry to the lottery.
        end_time: u64, // Timestamp indicating the end time of the lottery.
        pool: Balance<SUI>, // Balance representing the total funds collected in the lottery pool.
    }
    // Struct to represent a player participating in the lottery.
    public struct Player has key, store {
        id: UID,
        player: address, // Address of the player.
        balance: Balance<SUI>, // Balance representing the funds deposited by the player.
    }
    // Error codes used in the lottery system.
    const EInvalidParams: u64 = 0;
    const ENotPlayer: u64 = 2;
    const EInsufficientBalance: u64 = 5;
    const EWinnerSelected: u64 = 6;
    // Functions for managing the lottery system.
    // Initializes the lottery system by creating an AdminCap object.
    public fun init(ctx: &mut TxContext) {
        let admin = AdminCap {
            id: object::new(ctx),
            lotteries: vector::empty<ID>(),
        };
        transfer::transfer(admin, tx_context::sender(ctx));
    }
    // Adds a new player to the system.
    public fun add_player(
        player: address,
        ctx: &mut TxContext
    ) : Player {
        let id = object::new(ctx);
        Player {
            id,
            player,
            balance: balance::zero<SUI>(),
        }
    }
    // Deposits funds into a player's balance.
    public fun deposit(
        player: &mut Player,
        amount: Coin<SUI>,
    ) {
        let coin = coin::into_balance(amount);
        balance::join(&mut player.balance, coin);
    }
    // Creates a new lottery.
    public fun create_lottery(
        admin: &mut AdminCap,
        price: u64,
        end_time: u64,
        ctx: &mut TxContext
    ) {
        let id = object::new(ctx);
        let inner = object::uid_to_inner(&id);
        let lottery = Lottery {
            id,
            players: vector::empty(),
            winner: none(),
            price,
            end_time,
            pool: balance::zero<SUI>(),
        };
        transfer::share_object(lottery);
        vector::push_back(&mut admin.lotteries, inner);
    }
    // Allows a player to enter the lottery.
    public fun enter_lottery(
        lottery: &mut Lottery,
        player: &mut Player,
        mut entries: u64,
        ctx: &mut TxContext
    ) {
        assert!(balance::value(&player.balance) >= (lottery.price * entries), EInsufficientBalance);
        let price = coin::take(&mut player.balance, (lottery.price * entries), ctx);
        coin::put(&mut lottery.pool, price);
        while (entries > 0) {
            vector::push_back(&mut lottery.players, player.player);
            entries = entries - 1;
        };
    }
    // Picks a winner for the lottery.
    #[allow(lint(public_random))]
    public fun execute(
        lottery: &mut Lottery,
        clock: &Clock,
        r: &Random,
        ctx: &mut TxContext
    ) {
        assert!(clock::timestamp_ms(clock) > lottery.end_time, EInvalidParams);
        assert!(!is_some(&lottery.winner), EWinnerSelected);
        let mut generator = new_generator(r, ctx);
        let no_players: u64 = vector::length<address>(&lottery.players);
        let no_players_u8 = no_players as u8;
        let v = generator.generate_u8_in_range(0, no_players_u8);
        let winner_address = *vector::borrow(&lottery.players, v as u64);
        lottery.winner = some(winner_address);
        let payment = balance::withdraw_all(&mut lottery.pool);
        let coin = coin::from_balance(payment, ctx);
        transfer::public_transfer(coin, winner_address);
    }
    // Withdraws funds from a player's balance.
    public fun withdraw(
        player: &mut Player,
        amount: u64,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == player.player, ENotPlayer); // Add access control check
        assert!(balance::value(&player.balance) >= amount, EInsufficientBalance);
        let withdrawn = coin::take(&mut player.balance, amount, ctx);
        transfer::public_transfer(withdrawn, player.player);
    }
}