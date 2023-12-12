// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import '../lib/forge-std/src/Script.sol';

import { UpshotAdapter } from '../src/UpshotAdapter.sol';
import { TopicConfig, TopicView } from '../src/interface/IUpshotAdapter.sol';
import { IAggregator } from '../src/interface/IAggregator.sol';
import { IFeeHandler } from '../src/interface/IFeeHandler.sol';
import { NumericData } from '../src/interface/IUpshotAdapter.sol';
import { ECDSA } from '../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol';


// run with 
// forge script ./script/AddTopicScript.s.sol:AddTopicScript --rpc-url <rpc url> --broadcast --verify -vvvv


contract AddTopicScript is Script {
    function run() public virtual {
        uint256 scriptRunnerPrivateKey = vm.envUint('SCRIPT_RUNNER_PRIVATE_KEY');
        address scriptRunner = vm.addr(scriptRunnerPrivateKey);
        UpshotAdapter upshotAdapter = UpshotAdapter(0xdD3C703221c7F00Fe0E2d8cdb5403ca7760CDd4c);

        vm.startBroadcast(scriptRunnerPrivateKey);
        console.log('Broadcast started by %s', scriptRunner);

        TopicConfig memory topicConfig = TopicConfig({
            title: 'Eth/USD Price feed',
            owner: scriptRunner,
            totalFee: 0 ether,
            recentValueTime: 0,
            recentValue: 0,
            aggregator: IAggregator(0xd7DbA19fEa80d79d647eA92C3B6B011A6Ef6FDf6),
            ownerSwitchedOn: true,
            adminSwitchedOn: true,
            feeHandler: IFeeHandler(0xA9D209191Ef18ab7EA51766ed1C6dd0EB06520C5),
            dataProviderQuorum: 1,
            dataValiditySeconds: 1 hours
        });

        address[] memory validDataProviders = new address[](1);
        validDataProviders[0] = address(0xA459c3A3b7769e18E702a3B5e2dEcDD495655791);

        TopicView memory topicView = TopicView({
            config: topicConfig,
            validDataProviders: validDataProviders
        });

        upshotAdapter.addTopic(topicView);

        vm.stopBroadcast();
    }
}
