# Anti-Token
### *The deflationary token in LIGO !*

## Summary

##### I. Compilation of the ANTI Token .tz
- At root, with docker run :
`docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract contract/anti.mligo > contract/compiled/anti.tz`

##### II. Prepare deployment of the ANTI Token
- At root, with docker run :
`docker run --rm -v "$PWD":"$PWD" -w "$PWD" ligolang/ligo:next compile contract contract/anti.mligo --michelson-format json > deploy/anti.json`

#### III. Deployment
- In the folder /deploy, run :
`tsc deploy/deploy.ts --resolveJsonModule -esModuleInterop`


npm i @taquito/taquit
npm i @taquito/signer
npm i dotenv
npm i nvm

node deploy.js