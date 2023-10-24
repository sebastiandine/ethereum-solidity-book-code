import "forge-std/console2.sol";
import { IPuppet } from "./Puppet.sol";

contract Master {

    function pullStrings(address puppet) external {
        IPuppet(puppet).action();
    }

}