# Lottery Module

The Lottery module is designed to provide a decentralized solution for organizing and conducting lotteries on the blockchain. It offers functionalities for creating lotteries, allowing players to participate, randomly selecting winners, and facilitating prize distribution. Let's delve into the core components and functionalities of this module:

## Structs

- **AdminCap**: This struct represents the administrative capabilities required for managing lotteries. It keeps track of the lotteries created by the admin.

- **Lottery**: The Lottery struct encapsulates the essential attributes of a lottery, including its unique identifier, participating players, designated winner (if selected), ticket price, end time for participation, and the prize pool balance.

- **Player**: Each participant in the lottery is represented by the Player struct, which stores their unique identifier, address, and current balance in the lottery.

## Errors

The Lottery module defines several error codes to handle exceptional cases:

- `EInvalidParams`: Denotes errors arising from invalid parameters provided to a function call.
  
- `ENotPlayer`: Indicates situations where the entity attempting an operation is not recognized as a valid player in the lottery system.
  
- `EInsufficientBalance`: This error is triggered when a player attempts an action requiring a balance that exceeds their available funds.
  
- `EWinnerSelected`: Signifies that a winner has already been selected for the lottery, preventing further selections.

## Functions

- **init**: Initializes the lottery module, setting up administrative capabilities and preparing the system for lottery operations.

- **add_player**: Allows the addition of new players to the lottery system, enabling them to participate in upcoming lotteries.

- **deposit**: Enables players to deposit tokens into their account balance within the lottery system, facilitating participation in lotteries.

- **create_lottery**: Empowers administrators to create new lotteries, defining parameters such as ticket price and end time for participation.

- **enter_lottery**: Allows players to enter a specific lottery by purchasing one or more lottery tickets, contributing to the prize pool.

- **execute**: Randomly selects a winner for the lottery once the participation period has ended, distributes the prize to the winner, and resets the lottery for future use.

- **withdraw**: Provides players with the ability to withdraw any remaining balance from their account within the lottery system.

## License

The Lottery module operates under the [MIT License](LICENSE), ensuring transparency, flexibility, and accessibility for all stakeholders.

## Prerequisites

1. Install dependencies by running the following commands:

   - `sudo apt update`

   - `sudo apt install curl git-all cmake gcc libssl-dev pkg-config libclang-dev libpq-dev build-essential -y`

2. Install Rust and Cargo

   - `curl https://sh.rustup.rs -sSf | sh`

   - source "$HOME/.cargo/env"

3. Install Sui Binaries

   - run the command `chmod u+x sui-binaries.sh` to make the file an executable

   execute the installation file by running

   - `./sui-binaries.sh "v1.21.0" "devnet" "ubuntu-x86_64"` for Debian/Ubuntu Linux users

   - `./sui-binaries.sh "v1.21.0" "devnet" "macos-x86_64"` for Mac OS users with Intel based CPUs

   - `./sui-binaries.sh "v1.21.0" "devnet" "macos-arm64"` for Silicon based Mac

## Installation

1. Clone the repo

   ```sh
   git clone https://github.com/kututajohn/de-collector
   ```

2. Navigate to the working directory

   ```sh
   cd de-collector
   ```

## Run a local network

To run a local network with a pre-built binary (recommended way), run this command:

```shsh
RUST_LOG="off,sui_node=info" sui-test-validator
```

## Configure connectivity to a local node

Once the local node is running (using `sui-test-validator`), you should the url of a local node - `http://127.0.0.1:9000` (or similar).
Also, another url in the output is the url of a local faucet - `http://127.0.0.1:9123`.

Next, we need to configure a local node. To initiate the configuration process, run this command in the terminal:

```shsh
sui client active-address
```

The prompt should tell you that there is no configuration found:

```shsh
Config file ["/home/codespace/.sui/sui_config/client.yaml"] doesn't exist, do you want to connect to a Sui Full node server [y/N]?
```

Type `y` and in the following prompts provide a full node url `http://127.0.0.1:9000` and a name for the config, for example, `localnet`.

On the last prompt you will be asked which key scheme to use, just pick the first one (`0` for `ed25519`).

After this, you should see the ouput with the wallet address and a mnemonic phrase to recover this wallet. You can save so later you can import this wallet into SUI Wallet.

Additionally, you can create more addresses and to do so, follow the next section - `Create addresses`.

### Create addresses

For this tutorial we need two separate addresses. To create an address run this command in the terminal:

```shsh
sui client new-address ed25519
```

where:

- `ed25519` is the key scheme (other available options are: `ed25519`, `secp256k1`, `secp256r1`)

And the output should be similar to this:

```sh
╭─────────────────────────────────────────────────────────────────────────────────────────────────╮
│ Created new keypair and saved it to keystore.                                                   │
├────────────────┬────────────────────────────────────────────────────────────────────────────────┤
│ address        │ 0x05db1e318f1e4bc19eb3f2fa407b3ebe1e7c3cd8147665aacf2595201f731519             │
│ keyScheme      │ ed25519                                                                        │
│ recoveryPhrase │ lava perfect chef million beef mean drama guide achieve garden umbrella second │
╰────────────────┴────────────────────────────────────────────────────────────────────────────────╯
```

Use `recoveryPhrase` words to import the address to the wallet app.

### Get localnet SUI tokens

```sh
curl --location --request POST 'http://127.0.0.1:9123/gas' --header 'Content-Type: application/json' \
--data-raw '{
    "FixedAmountRequest": {
        "recipient": "<ADDRESS>"
    }
}'
```

`<ADDRESS>` - replace this by the output of this command that returns the active address:

```sh
sui client active-address
```

You can switch to another address by running this command:

```sh
sui client switch --address <ADDRESS>
```

## Build and publish a smart contract

### Build package

To build tha package, you should run this command:

```sh
sui move build
```

If the package is built successfully, the next step is to publish the package:

### Publish package

```sh
sui client publish --gas-budget 100000000 --json
` - `sui client publish --gas-budget 1000000000`
```
