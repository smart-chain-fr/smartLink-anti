import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
import { char2Bytes } from '@taquito/utils';
import anti from './anti.json';
import * as dotenv from 'dotenv'

dotenv.config(({path:__dirname+'/.env'}))

const rpc = "https://hangzhounet.api.tez.ie"  // "https://rpc.hangzhounet.teztnets.xyz" // HANGZOUNET
//const rpc = "https://rpc.tzstats.com" // https://mainnet.api.tez.ie // MAINNET

const pk: string = "edskS8x3MqxnSVLix29fvBh7QBoTt6WLERyatEfTpRzE1XF26Aqy2ii7cBLMwpcE6u6fnj72gNRitAbXQjCS9eGncR7P4C3hy8";
const Tezos = new TezosToolkit(rpc);
const signer = new InMemorySigner(pk);
Tezos.setProvider({ signer: signer })

let tokens = new MichelsonMap();
tokens.set("tz1hA7UiKADZQbH8doJDiFY2bacWk8yAaU9i", 777777777777);
let allowances = new MichelsonMap();
const admin = "tz1hA7UiKADZQbH8doJDiFY2bacWk8yAaU9i"
const reserve_address = 'tz1RyejUffjfnHzWoRp1vYyZwGnfPuHsD5F5'
const total_supply = 777777777777
let metadata = MichelsonMap.fromLiteral({
    "name" : char2Bytes("SmartLink Anti token"),
    "decimals": char2Bytes("3"),
    "symbol" : char2Bytes("ANTI"),
    "description": char2Bytes("A Deflationnary token for https://smartlink.so/ the Decentralized escrow platform for Web 3.0"),
    "interfaces": char2Bytes("TZIP-007 TZIP-016"),
    "authors": char2Bytes("SmartLink Dev Team"),
    "homepage": char2Bytes("https://smartlink.so/"),
    "icon": char2Bytes("ipfs://QmRPwZSAUkU6nZNor1qoHu4aajPHYpMXrkyZNi8EaNWAmm"),
  });
let token_metadata_entry_anti = {
    token_id:'1',
    token_info:metadata,
  };

let token_metadata = new MichelsonMap();
token_metadata.set('0', token_metadata_entry_anti);


MichelsonMap.fromLiteral({
    token_id:'0',
    token_info:token_metadata_entry_anti,
  });

async function orig() {

    const store = {
        'admin' : admin,
        'reserve' : reserve_address,
        'tokens' : tokens,
        'allowances' : allowances,
        'total_supply' : total_supply,
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
