# Anti-Token : The first mechanical token

*This is a description of the SmartLink deflationary token in LIGO !*

## Introduction

The system is comprised of a deflationary "mechanical" FA12 token contract.

In order to incentivize people using the token in Smart-Contract, a fee is taken
if the receiver of a transfer is a user.

| Attribute | Value |
|---|---|
| Name | Anti token |
| Decimal | 3 |
| Symbol | ANTI |
| Description | A Deflationary token for <https://smartlink.so/> the Decentralized escrow platform for Web 3.0 |
| Interface | TZIP-007 TZIP-016 |
| Authors | SmartLink Dev Team |
| Homepage | <https://smartlink.so/> |
| Icon | ipfs://QmRPwZSAUkU6nZNor1qoHu4aajPHYpMXrkyZNi8EaNWAmm |
| Initial supply | 777 777 777 777.777 |
| Mintable | FALSE |
| Admin | tz1ic7L44bmZc9xjmLf8FbxMJPJtHPgA5csv |
| Reserves | tz1djkbrkYiuWFTgd3qUiViijGUuz2wBGxQ2 |
| Burn address | tz1burnburnburnburnburnburnburjAYjjX |

## Prerequisites

The contract is written in cameligo flavour of [https://ligolang.org/](LigoLANG),
to be able to compile the contract, you need either:

- a [ligo binary](https://ligolang.org/docs/intro/installation#static-linux-binary),
  in this case, to use the binary, you need to have set up a `LIGO` environment variable,
  pointing to the binary (see [Makefile](./Makefile))
- or docker

You also need to have [nodejs](https://nodejs.org/en/) installed, up to version 14.

## Usage

Run `make install` to install dependencies.

Run `make` to see available commands.

### Compilation of the ANTI Token

Run `make compile`

### Deployment

There is a [tezos sandbox](https://gitlab.com/tezos/flextesa) integrated in this
repository, if you wish to use it, run `make sandbox-start`.

Then, just run `make deploy` to deploy the contract on the sandbox.

If you wish to deploy on other networks, you need to edit the `.env` at the root of
this repository, it should have been generated when you runned `make install`.

## System Architecture

### The ANTI Token

The ANTI token can be used as any other FA12 asset, and is not mintable. The amount of the taxe is 7% burn and 1% sent to reserve.

### Finding Smart-Contract

In order to find if the receiver of the token is a contract, the ANTI token will scan for the following entrypoints and arguments :

| Attribute | Value |
|---|---|
| %setBaker          | { baker : key_hash option ; freezeBaker : bool }
| %set_baker        | { baker : key_hash option }
| %baker            | { baker : key_hash }
| %setAdmin          | { address : address }
| %set_admin        | { address : address }
| %set_administrator | { address : address }

### About

The mechanical token is a genuine and innovative idea of Smart-Chain.
