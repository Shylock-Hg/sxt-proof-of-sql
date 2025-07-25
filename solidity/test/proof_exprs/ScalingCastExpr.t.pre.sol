// SPDX-License-Identifier: UNLICENSED
// This is licensed under the Cryptographic Open Software License 1.0
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import "../../src/base/Constants.sol";
import {VerificationBuilder} from "../../src/builder/VerificationBuilder.pre.sol";
import {ScalingCastExpr} from "../../src/proof_exprs/ScalingCastExpr.pre.sol";
import {F} from "../base/FieldUtil.sol";

contract ScalingCastExprTest is Test {
    function testSimpleScalingCastExpr() public pure {
        VerificationBuilder.Builder memory builder;
        bytes memory expr = abi.encodePacked(
            DATA_TYPE_DECIMAL75_VARIANT,
            uint8(20),
            int8(2),
            LITERAL_EXPR_VARIANT,
            DATA_TYPE_INT_VARIANT,
            int32(7),
            uint256(100), // scaling factor comes after the proof expression
            hex"abcdef"
        );
        bytes memory expectedExprOut = hex"abcdef";

        uint256 eval;
        (expr, builder, eval) = ScalingCastExpr.__scalingCastExprEvaluate(expr, builder, 10);

        assert(eval == 7000); // 7 * 10 * 100
        assert(expr.length == expectedExprOut.length);
        uint256 exprOutLength = expr.length;
        for (uint256 i = 0; i < exprOutLength; ++i) {
            assert(expr[i] == expectedExprOut[i]);
        }
    }

    function testFuzzScalingCastExpr(
        VerificationBuilder.Builder memory builder,
        uint256 chiEvaluation,
        int32 inputValue,
        uint256 scalingFactor,
        bytes memory trailingExpr
    ) public pure {
        bytes memory expr = abi.encodePacked(
            DATA_TYPE_DECIMAL75_VARIANT,
            uint8(20),
            int8(2),
            LITERAL_EXPR_VARIANT,
            DATA_TYPE_INT_VARIANT,
            inputValue,
            scalingFactor, // scaling factor comes after the proof expression
            trailingExpr
        );

        uint256 eval;
        (expr, builder, eval) = ScalingCastExpr.__scalingCastExprEvaluate(expr, builder, chiEvaluation);

        assert(eval == (F.from(inputValue) * F.from(chiEvaluation) * F.from(scalingFactor)).into());
        assert(expr.length == trailingExpr.length);
        uint256 exprOutLength = expr.length;
        for (uint256 i = 0; i < exprOutLength; ++i) {
            assert(expr[i] == trailingExpr[i]);
        }
    }
}
