import { parseArgs } from "jsr:@std/cli/parse-args";
import { generateSecretKey, getPublicKey, finalizeEvent, verifyEvent } from "npm:nostr-tools/pure";
import { bytesToHex, hexToBytes } from "npm:@noble/hashes/utils";
import { sleep } from "https://deno.land/x/sleep/mod.ts"

const parsedArgs = parseArgs(Deno.args, {
    string: [
        "sk",
        "rpc",
        "to",
    ],
    boolean: [
      "dry"
    ],
    default: {
        dry: false,
        sk: "c885648cc3e4c94fe00b74111247d15ebe35640f7973d8b9f839ced49e3706d5",
        rpc: "http://127.0.0.1:3000",
        to: "6f7bb11c04d792784c9dfcb4246e9afc0d6a7eae549531c2fce51adf09b2887e"
    }
});

if (parsedArgs.sk.trim().length === 0) {
    console.log(`\`--sk <SECRET_KEY>\` is required, example: \`--sk ${bytesToHex(generateSecretKey())}\``);
    Deno.exit(1);
}
const sk = hexToBytes(parsedArgs.sk.trim());
console.log(`Public Key: ${getPublicKey(sk)}`);

if (parsedArgs.to.trim().length === 0) {
    console.log(`\`--to <PUB_KEY>\` is required`);
    Deno.exit(1);
}
const toPubKey = parsedArgs.to;


try {
    let event = finalizeEvent({
        kind: 1573,
        created_at: Math.floor(Date.now() / 1000),
        tags: [["s", "0"], ["p", toPubKey]],
        content: 'Ping',
    }, sk)

    console.log(JSON.stringify(event));

    if (!parsedArgs.dry) {
        const resp = await fetch(`${parsedArgs.rpc}/api/events`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({event}),
        });
        if (resp.status >= 200 && resp.status < 500) {
            console.log(await resp.json());
        } else {
            console.error(await resp.text());
        }
    }
} catch (ex) {
    console.error(ex);
    Deno.exit(1);
}
Deno.exit(0);
