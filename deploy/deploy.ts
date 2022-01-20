import { InMemorySigner } from '@taquito/signer';
import { TezosToolkit, MichelsonMap } from '@taquito/taquito';
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
let metadata = new MichelsonMap();
let token_metadata = new MichelsonMap();

async function orig() {

    // for (let i = 0; i < weeks + 1; i++) {
    //     farm_points[i] = 0
    // }

    const store = {
        'admin' : admin,
        'reserve' : reserve_address,
        'tokens' : tokens,
        'allowances' : allowances,
        'total_supply' : total_supply,
        'metadata' : metadata,
        'token_metadata' : token_metadata
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
