// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import { ECDSA } from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";
import {Prices, PricesConstructorArgs} from "../src/Prices.sol";
import {PriceData, FeedView} from "../src/interface/IPrices.sol";
import {EvenFeeHandler, EvenFeeHandlerConstructorArgs} from "../src/feeHandler/EvenFeeHandler.sol";
import {AverageAggregator} from "../src/aggregator/AverageAggregator.sol";
import {MedianAggregator} from "../src/aggregator/MedianAggregator.sol";
import {IAggregator} from "../src/interface/IAggregator.sol";
import {IFeeHandler} from "../src/interface/IFeeHandler.sol";

struct PriceDataWithoutSignature {
    uint256 feedId;
    uint128 nonce;
    uint96 timestamp;
    uint256 price; 
    bytes extraData;
}

contract PricesTest is Test {

    EvenFeeHandler public evenFeeHandler;
    IAggregator aggregator;
    IFeeHandler feeHandler;
    Prices prices;

    address admin = address(100);
    address protocolFeeReceiver = address(101);

    uint256 signer0pk = 0x1000;
    uint256 signer1pk = 0x1001;
    uint256 signer2pk = 0x1002;

    address signer0;
    address signer1;
    address signer2;

    address[] oneValidSigner;
    address[] twoValidSigners;
    address[] threeValidSigners;
    address[] emptyValidSigners;


    function setUp() public {
        vm.warp(1 hours);

        aggregator = new AverageAggregator();
        feeHandler = new EvenFeeHandler(EvenFeeHandlerConstructorArgs({
            admin: admin,
            protocolFeeReceiver: protocolFeeReceiver
        }));
        prices = new Prices(PricesConstructorArgs({
            admin: admin 
        }));

        signer0 = vm.addr(signer0pk);
        signer1 = vm.addr(signer1pk);
        signer2 = vm.addr(signer2pk);

        oneValidSigner = new address[](1);
        oneValidSigner[0] = signer0;

        twoValidSigners = new address[](2);
        twoValidSigners[0] = signer0;
        twoValidSigners[1] = signer1;

        threeValidSigners = new address[](3);
        threeValidSigners[0] = signer0;
        threeValidSigners[1] = signer1;
        threeValidSigners[2] = signer2;
    }

    // ***************************************************************
    // * ===================== FUNCTIONALITY ======================= *
    // ***************************************************************
    function test_cantCallGetPriceWhenContractSwitchedOff() public {
        vm.startPrank(admin);
        vm.deal(admin, 2^128);
        prices.turnOff();
        
        PriceData[] memory priceData = new PriceData[](0);

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2NotSwitchedOn()"));
        prices.getPrice(priceData, '');
    }

    function test_cantCallGetPriceWithoutFee() public {
        vm.startPrank(admin);
        prices.addFeed(_getBasicFeedView());
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](1);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2InsufficientPayment()"));
        prices.getPrice(priceData, '');
    }

    function test_cantCallGetPriceWithNoPrices() public {
        PriceData[] memory priceData = new PriceData[](0);

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2NoPricesProvided()"));
        prices.getPrice{value: 1 ether}(priceData, '');
    }

    function test_cantCallGetPriceWithLessThanThresholdPrices() public {
        vm.startPrank(admin);
        FeedView memory feedView = _getBasicFeedView();
        feedView.minPrices = 2;
        prices.addFeed(feedView);
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](1);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2NotEnoughPrices()"));
        prices.getPrice{value: 1 ether}(priceData, '');
    }

    function test_canCallGetPriceWithValidSignature() public {
        vm.startPrank(admin);
        prices.addFeed(_getBasicFeedView());
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](1);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        prices.getPrice{value: 1 ether}(priceData, '');
    }

    function test_cantCallGetPriceWithoutValidFeedId() public {
        /*
        vm.startPrank(admin);
        prices.addValidSigner(signer0);
        vm.stopPrank();
        */

        PriceData[] memory priceData = new PriceData[](1);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2InvalidFeed()"));
        prices.getPrice{value: 1 ether}(priceData, '');
    }

    function test_cantCallGetPriceWithoutValidNonce() public {
        vm.startPrank(admin);
        prices.addFeed(_getBasicFeedView());
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](1);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 3,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2InvalidNonce()"));
        prices.getPrice{value: 1 ether}(priceData, '');
    }

    function test_cantCallGetPriceWithMismatchedFeeds() public {
        vm.startPrank(admin);
        prices.addFeed(_getBasicFeedView());
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](2);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        priceData[1] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 2,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2FeedMismatch()"));

        prices.getPrice{value: 1 ether}(priceData, '');
    }

    function test_cantCallGetPriceWithMismatchedNonces() public {
        vm.startPrank(admin);
        prices.addFeed(_getBasicFeedView());
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](2);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        priceData[1] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 3,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2NonceMismatch()"));
        prices.getPrice{value: 1 ether}(priceData, '');
    }

    function test_cantCallGetPriceWithInvalidTime() public {
        vm.startPrank(admin);
        prices.addFeed(_getBasicFeedView());
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](1);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp + 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2InvalidPriceTime()"));
        prices.getPrice{value: 1 ether}(priceData, '');
    }

    function test_cantCallGetPriceWithInvalidSigner() public {
        vm.startPrank(admin);
        prices.addFeed(_getBasicFeedViewNoSigners());
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](1);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2InvalidSigner()"));
        prices.getPrice{value: 1 ether}(priceData, '');
    }

    function test_cantCallGetPriceWithDuplicateSigner() public {
        vm.startPrank(admin);
        prices.addFeed(_getBasicFeedView());
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](2);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        priceData[1] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        vm.expectRevert(abi.encodeWithSignature("UpshotOracleV2DuplicateSigner()"));
        prices.getPrice{value: 1 ether}(priceData, '');
    }

    function test_priceAverageAggregationWorksCorrectly() public {
        vm.startPrank(admin);
        prices.addFeed(_getBasicFeedViewTwoSigners());
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](2);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        priceData[1] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 3 ether,
                extraData: ''
            }),
            signer1pk
        );

        uint256 price = prices.getPrice{value: 1 ether}(priceData, '');
        assertEq(price, 2 ether);
    }

    function test_priceMedianAggregationWorksCorrectly() public {
        MedianAggregator medianAggregator = new MedianAggregator();

        vm.startPrank(admin);
        FeedView memory feedView = _getBasicFeedViewTwoSigners();
        feedView.aggregator = medianAggregator;
        prices.addFeed(feedView);
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](2);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        priceData[1] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 3 ether,
                extraData: ''
            }),
            signer1pk
        );

        uint256 price = prices.getPrice{value: 1 ether}(priceData, '');
        assertEq(price, 2 ether);
    }

    function test_priceMedianAggregationWorksCorrectly2() public {
        MedianAggregator medianAggregator = new MedianAggregator();

        vm.startPrank(admin);

        FeedView memory feedView = _getBasicFeedViewThreeSigners();
        feedView.aggregator = medianAggregator;
        prices.addFeed(feedView);
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](3);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        priceData[1] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 2 ether,
                extraData: ''
            }),
            signer1pk
        );

        priceData[2] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 5 ether,
                extraData: ''
            }),
            signer2pk
        );


        uint256 price = prices.getPrice{value: 1 ether}(priceData, '');
        assertEq(price, 2 ether);
    }

    function test_priceFeesSplitCorrectly() public {
        vm.startPrank(admin);
        prices.addFeed(_getBasicFeedViewTwoSigners());
        vm.stopPrank();

        PriceData[] memory priceData = new PriceData[](2);

        priceData[0] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 1 ether,
                extraData: ''
            }),
            signer0pk
        );

        priceData[1] = _getPriceData(
            PriceDataWithoutSignature({
                feedId: 1,
                nonce: 2,
                timestamp: uint96(block.timestamp - 1 minutes),
                price: 3 ether,
                extraData: ''
            }),
            signer1pk
        );

        uint256 protocolFeeBal0 = protocolFeeReceiver.balance;
        uint256 signer0Bal0 = signer0.balance;
        uint256 signer1Bal0 = signer1.balance;

        prices.getPrice{value: 1 ether}(priceData, '');

        uint256 protocolFee = protocolFeeReceiver.balance - protocolFeeBal0;
        uint256 signer0Fee = signer0.balance - signer0Bal0;
        uint256 signer1Fee = signer1.balance - signer1Bal0;

        assertEq(protocolFee, 0.2 ether);
        assertEq(signer0Fee, 0.4 ether);
        assertEq(signer1Fee, 0.4 ether);
    }

    // ***************************************************************
    // * ================= INTERNAL HELPERS ======================== *
    // ***************************************************************
    function _getPriceData(
        PriceDataWithoutSignature memory priceDataIn,
        uint256 signerPk
    ) internal view returns (PriceData memory) {
        bytes32 priceMessage = prices.getPriceMessage(
            priceDataIn.feedId,
            priceDataIn.nonce,
            priceDataIn.timestamp,
            priceDataIn.price,
            priceDataIn.extraData
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            signerPk,
            ECDSA.toEthSignedMessageHash(priceMessage)
        );
        bytes memory signature = abi.encodePacked(r, s, v);

        return PriceData({
            signature: signature,
            feedId: priceDataIn.feedId,
            nonce: priceDataIn.nonce,
            timestamp: priceDataIn.timestamp,
            price: priceDataIn.price,
            extraData: priceDataIn.extraData
        });
    }

    function _getBasicFeedView() internal view returns (FeedView memory feedView) {
        return FeedView({
            title: 'Initial feed',
            nonce: 1,
            totalFee: 0.001 ether,
            minPrices: 1,
            priceValiditySeconds: 5 minutes,
            aggregator: aggregator,
            isValid: true,
            feeHandler: feeHandler,
            validPriceProviders: oneValidSigner
        });
    }

    function _getBasicFeedViewNoSigners() internal view returns (FeedView memory feedView) {
        feedView = _getBasicFeedView();
        feedView.validPriceProviders = emptyValidSigners;
    }

    function _getBasicFeedViewTwoSigners() internal view returns (FeedView memory feedView) {
        feedView = _getBasicFeedView();
        feedView.validPriceProviders = twoValidSigners;
    }

    function _getBasicFeedViewThreeSigners() internal view returns (FeedView memory feedView) {
        feedView = _getBasicFeedView();
        feedView.validPriceProviders = threeValidSigners;
    }
}
