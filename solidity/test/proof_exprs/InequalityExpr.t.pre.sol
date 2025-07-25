// SPDX-License-Identifier: UNLICENSED
// This is licensed under the Cryptographic Open Software License 1.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import "../../src/base/Constants.sol";
import {VerificationBuilder} from "../../src/builder/VerificationBuilder.pre.sol";
import {InequalityExpr} from "../../src/proof_exprs/InequalityExpr.pre.sol";
import {F} from "../base/FieldUtil.sol";

contract InequalityExprTest is Test {
    function testSimpleInequalityExpr() public pure {
        VerificationBuilder.Builder memory builder;
        uint256[] memory bitDistribution = new uint256[](4);
        bitDistribution[0] = 0x800000000000000000000000000000000000000000000000000000000000007D;
        bitDistribution[1] = 0x8000000000000000000000000000000000000000000000000000000000000002;
        bitDistribution[2] = 0x800000000000000000000000000000000000000000000000000000000000007D;
        bitDistribution[3] = 0x8000000000000000000000000000000000000000000000000000000000000002;
        VerificationBuilder.__setBitDistributions(builder, bitDistribution);
        builder.maxDegree = 3;
        builder.constraintMultipliers = new uint256[](7);
        builder.constraintMultipliers[0] = 5;
        builder.constraintMultipliers[1] = 5;
        builder.constraintMultipliers[2] = 5;
        builder.constraintMultipliers[3] = 5;
        builder.constraintMultipliers[4] = 5;
        builder.constraintMultipliers[5] = 5;
        builder.constraintMultipliers[6] = 5;
        builder.aggregateEvaluation = 0;
        builder.rowMultipliersEvaluation = addmod(MODULUS, mulmod(MODULUS_MINUS_ONE, 2, MODULUS), MODULUS);

        int64[4] memory evaluationVector = [int64(700), -6, 3007, 134562844];

        int64[4][10] memory vectorsToEvaluate = [
            [int64(-99), -16, 67, 83],
            [int64(1), 1, 1, 1],
            [int64(0), 1, 0, 0],
            [int64(0), 1, 1, 1],
            [int64(1), 0, 0, 0],
            [int64(0), 1, 0, 1],
            [int64(1), 0, 0, 1],
            [int64(1), 0, 1, 0],
            [int64(1), 1, 0, 0],
            [int64(0), 0, 1, 1]
        ];

        uint256[] memory evaluations = new uint256[](10);

        for (uint8 i = 0; i < 10; ++i) {
            int64 evaluation = 0;
            for (uint8 j = 0; j < 4; ++j) {
                evaluation += evaluationVector[j] * vectorsToEvaluate[i][j];
            }
            evaluations[i] = F.from(evaluation).into();
        }

        builder.columnEvaluations = new uint256[](1);
        builder.columnEvaluations[0] = evaluations[0];

        uint256[] memory finalRoundMles = new uint256[](7);
        for (uint8 i = 2; i < 9; ++i) {
            finalRoundMles[i - 2] = evaluations[i];
        }

        VerificationBuilder.__setFinalRoundMLEs(builder, finalRoundMles);

        bytes memory expr = abi.encodePacked(
            abi.encodePacked(LITERAL_EXPR_VARIANT, DATA_TYPE_BIGINT_VARIANT, int64(7)),
            abi.encodePacked(COLUMN_EXPR_VARIANT, uint64(0)),
            true,
            hex"abcdef"
        );

        uint256 signEval;
        (expr, builder, signEval) = InequalityExpr.__inequalityExprEvaluate(expr, builder, evaluations[1]);
        assert(signEval == evaluations[9]);
    }
}
