# RootFounders Smart Contracts

Currently this repository contains the main smart contract that powers RootFounders. It has been built using `foundry`.

RootFounders is a **decentralized and permission-less protocol**, which makes the smart contract it's most important part.
The contract is the source of truth for the rest of the stack. Frontend is only a nice wrapper around its functionality and
the backend is really just a cache.

The contract has methods defined for every action a user can perform: `createProject`, `comment`, `tip`, `apply` (to join a team),
`addTeammate` (to make someone part of a team), `removeTeammate` and `team` (to list team members).

Almost all methods emit events. RootFounders backend is listening for them and stores associated data in a database, to make
our frontend faster. However, anyone can use RootFounders by simply calling the contract and they don't need to use our frontend.

## Foundry Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
