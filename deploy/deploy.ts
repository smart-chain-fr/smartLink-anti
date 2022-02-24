import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import { char2Bytes } from '@taquito/utils';
import anti from './anti.json';
import * as dotenv from 'dotenv'

dotenv.config(({path:__dirname+'/.env'}))

//const rpc = "https://hangzhounet.api.tez.ie"  // "https://rpc.hangzhounet.teztnets.xyz" // HANGZOUNET
const rpc = "https://rpc.tzstats.com" // https://mainnet.api.tez.ie // MAINNET

const pk: string = "";
const Tezos = new TezosToolkit(rpc);
const signer = new InMemorySigner(pk);
Tezos.setProvider({ signer: signer })

let ledger = new MichelsonMap();
ledger.set("tz1ic7L44bmZc9xjmLf8FbxMJPJtHPgA5csv", 777777777777);
let allowances = new MichelsonMap();
const admin = "tz1ic7L44bmZc9xjmLf8FbxMJPJtHPgA5csv"
const reserve_address = 'tz1djkbrkYiuWFTgd3qUiViijGUuz2wBGxQ2'
const burn_address = 'tz1burnburnburnburnburnburnburjAYjjX'
const initial_supply = 777777777777
const total_supply = 777777777777
const burned_supply = 0
let metadata = MichelsonMap.fromLiteral({
    "name" : char2Bytes("Anti token"),
    "decimals": char2Bytes("3"),
    "symbol" : char2Bytes("ANTI"),
    "description": char2Bytes("The ANTI token is a fungible deflationary asset."),
    "interfaces": char2Bytes("TZIP-007 TZIP-016"),
    "authors": char2Bytes("SmartLink Dev Team"),
    "homepage": char2Bytes("https://smartlink.so/"),
    "icon": char2Bytes("ipfs://QmRPwZSAUkU6nZNor1qoHu4aajPHYpMXrkyZNi8EaNWAmm"),
    "supply": char2Bytes("777777777.777"),
    "mintable": char2Bytes("False"),    
  });
let token_metadata_entry_anti = {
    token_id:'0',
    token_info:metadata,
  };

let token_metadata = new MichelsonMap();
token_metadata.set('0', token_metadata_entry_anti);

async function orig() {

    const store = {
        'admin' : admin,
        'reserve' : reserve_address,
        'ledger' : ledger,
        'allowances' : allowances,
        'initial_supply' : initial_supply,
        'total_supply' : total_supply,
        'burned_supply' : burned_supply,
        'burn_address' : burn_address,
        'metadata' : metadata,
        'token_metadata' : token_metadata,
    }

    try {
        const originated = await Tezos.contract.originate({
            code: anti,
            storage: store,
        })
        console.log(`Waiting for fa12 ${originated.contractAddress} to be confirmed...`);
        await originated.confirmation(2);
        console.log('confirmed fa12: ', originated.contractAddress);

    } catch (error: any) {
        console.log(error)
    }
}

orig();
