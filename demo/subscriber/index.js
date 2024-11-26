import { parseArgs } from "jsr:@std/cli/parse-args";
import { generateSecretKey, getPublicKey, finalizeEvent, verifyEvent } from "npm:nostr-tools/pure";
import { bytesToHex, hexToBytes } from "npm:@noble/hashes/utils";
import { sleep } from "https://deno.land/x/sleep/mod.ts"

const parsedArgs = parseArgs(Deno.args, {
    string: [
        "sk",
        "rpc",
    ],
    boolean: [
        "dry"
    ],
    default: {
        dry: false,
        sk: "",
        rpc: "http://127.0.0.1:3000",
    }
});

if (parsedArgs.sk.trim().length === 0) {
    console.log(`\`--sk <SECRET_KEY>\` is missing, example: \`--sk ${bytesToHex(generateSecretKey())}\``);
    Deno.exit(1);
}
const sk = hexToBytes(parsedArgs.sk.trim());
const pk = getPublicKey(sk);
console.log(`Public Key: ${pk}`);

let latestEventId = null;
let resp

resp = await fetch(`${parsedArgs.rpc}/api/recipients/${pk}/events/latest`, {
    method: "GET",
    headers: {
        "Content-Type": "application/json",
    }
});
if (resp.status === 200) {
    const latestEvent = (await resp.json()).event
    latestEventId = latestEvent ? latestEvent.id : null;
} else {
    console.error(await resp.text());
    Deno.exit(1)
}

while (true) {
    try {
        let url = `${parsedArgs.rpc}/api/recipients/${pk}/events`;
        if (latestEventId) {
            url = `${url}?after=${latestEventId}`
        }
        // console.log(url);
        resp = await fetch(url, {
            method: "GET",
            headers: {
                "Content-Type": "application/json",
            }
        });
        if (resp.status !== 200) {
            console.error(await resp.text());
            await sleep(2);
            continue;
        }

        const events = (await resp.json()).events ?? [];
        if (events.length > 0) {
            latestEventId = events[events.length - 1].id
        }

        const pingEvents = events.filter((e) => e.content === "Ping")
        if (pingEvents.length === 0) {
            console.log("No new ping event");
            await sleep(2);
            continue;
        }

        const pongEvents = pingEvents.map((e) => {
            return finalizeEvent({
                kind: 1573,
                created_at: Math.floor(Date.now() / 1000),
                tags: [["s", "0"], ["p", e.pubkey]],
                content: 'Pong',
            }, sk)
        })

        resp = await fetch(`${parsedArgs.rpc}/api/events/batch`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                events: pongEvents
            }),
        });
        if (resp.status === 200) {
            console.log(await resp.json());
        } else {
            console.error(await resp.text());
        }

        await sleep(2)
    } catch (ex) {
        console.error(ex);
        Deno.exit(1);
    }
}

Deno.exit(0);
