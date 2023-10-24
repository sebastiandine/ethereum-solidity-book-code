import { JsonRpcProvider, Contract } from "ethers";
import abi from "./DBlogAbi.json" assert {type: 'json'};

const RPC_URL = "http://127.0.0.1:8545";
const CONTRACT_ADDR = "0x5FbDB2315678afecb367f032d93F642f64180aa3"

const history = async () => {
    const provider = new JsonRpcProvider(RPC_URL)
    const dblog = new Contract(CONTRACT_ADDR, abi, provider);
    const posts = await dblog.queryFilter(dblog.filters.BlogPost, 0, "latest");
    posts.forEach(post => console.log(`NEW POST\nauthor: ${post.args[0]}\npost: ${post.args[1]}\n${post.args[2]}`))
}


const listen = async () => {
    const provider = new JsonRpcProvider(RPC_URL)
    const dblog = new Contract(CONTRACT_ADDR, abi, provider);
    dblog.on(dblog.filters.BlogPost, (author, postId, content) => {
        console.log(`NEW POST\nauthor: ${author}\npost: ${postId}\n${content}`);
    })
}

history();
listen();

