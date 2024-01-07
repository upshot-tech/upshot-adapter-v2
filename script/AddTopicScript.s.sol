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
// forge script ./script/AddTopicScript.s.sol:AddTopicScript --rpc-url <rpc url> --etherscan-api-key <etherscan api key> --broadcast --verify -vvvv


/**
 * @title UpshotAdapterViewPredictionExample
 * @notice Example contract adding topics to an UpshotAdapter
 */
contract AddTopicScript is Script {

    UpshotAdapter upshotAdapter = UpshotAdapter(0x238D0abD53fC68fAfa0CCD860446e381b400b5Be);
    IAggregator aggregator = IAggregator(0x180A7132C54Eb5e88fbda5b764580B8cBa4c7958);
    IFeeHandler feeHandler = IFeeHandler(0x594F9D4d09E6daEe8C35b30bCB5c3a1269d2B712);

    function run() public virtual {
        uint256 scriptRunnerPrivateKey = vm.envUint('SCRIPT_RUNNER_PRIVATE_KEY');
        address scriptRunner = vm.addr(scriptRunnerPrivateKey);

        vm.startBroadcast(scriptRunnerPrivateKey);
        console.log('Broadcast started by %s', scriptRunner);

        string[7] memory indices = [
            'Art Blocks Curated Index',
            'Yuga Index',
            'PFP Index',
            'Top 30 Liquid Collections Index',
            'Yuga Index - Grails',
            'Art Blocks Curated Index - Grails',
            'PFP Index - Grails'
        ];

        uint256[] memory topicIds = new uint256[](indices.length);

        for (uint256 i = 0; i < indices.length; i++) {
            TopicConfig memory topicConfig = TopicConfig({
                title: indices[i],
                owner: scriptRunner,
                totalFee: 0 ether,
                aggregator: aggregator,
                ownerSwitchedOn: true,
                adminSwitchedOn: true,
                feeHandler: feeHandler,
                dataProviderQuorum: 1,
                dataValiditySeconds: 1 hours
            });

            address[] memory validDataProviders = new address[](1);
            validDataProviders[0] = address(0xA459c3A3b7769e18E702a3B5e2dEcDD495655791);

            TopicView memory topicView = TopicView({
                config: topicConfig,
                validDataProviders: validDataProviders
            });

            topicIds[i] = upshotAdapter.addTopic(topicView);
        }

        for (uint256 i = 0; i < indices.length; i++) {
            console.log('Topic "%s" generated with id %s', indices[i], topicIds[i]);
        }

        vm.stopBroadcast();
    }
}
