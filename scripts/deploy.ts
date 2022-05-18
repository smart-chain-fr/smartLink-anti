import { InMemorySigner } from "@taquito/signer";
import { TezosToolkit, MichelsonMap } from "@taquito/taquito";
import { char2Bytes } from '@taquito/utils';
import code from "../compiled/anti.json";
import metadataJson from "./metadata.json";
import * as dotenv from "dotenv";

// Read environment variables from .env file
dotenv.config();

// Initialize RPC connection
const Tezos = new TezosToolkit(process.env.NODE_URL);

// Deploy to configured node with configured secret key
const deploy = async () => {
  try {
    const signer = await InMemorySigner.fromSecretKey(process.env.SECRET_KEY);

    Tezos.setProvider({ signer });

    // format metadata from JSON
    for (const [k,v] of Object.entries(metadataJson)) {
      metadataJson[k] = char2Bytes(v)
    }
    const metadata = MichelsonMap.fromLiteral(metadataJson)

    // create a JavaScript object to be used as initial storage
    // https://tezostaquito.io/docs/originate/#a-initializing-storage-using-a-plain-old-javascript-object
    const storage = {
      admin: process.env.ADMIN_ADDRESS,
      reserve: process.env.RESERVE_ADDRESS,
      ledger: MichelsonMap.fromLiteral({
        [process.env.ADMIN_ADDRESS]: process.env.INITIAL_SUPPLY,
      }),
      allowances: new MichelsonMap(),
      initial_supply: process.env.INITIAL_SUPPLY,
      total_supply: process.env.INITIAL_SUPPLY,
      burned_supply: 0,
      burn_address: process.env.BURN_ADDRESS,
      metadata: metadata,
      token_metadata: MichelsonMap.fromLiteral({
        0: { token_id: 0, token_info: metadata },
      }),
    };

    const op = await Tezos.contract.originate({ code, storage });
    console.log("Waiting confirmation...");
    await op.confirmation();
    console.log(`[OK] ${op.contractAddress}`);
  } catch (e) {
    console.log(e);
  }
};

deploy();
