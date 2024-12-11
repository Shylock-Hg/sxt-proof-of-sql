use super::{SumcheckMleEvaluations, VerificationBuilder};
use crate::{base::scalar::Curve25519Scalar, sql::proof::SumcheckSubpolynomialType};
use num_traits::Zero;

#[test]
fn an_empty_sumcheck_polynomial_evaluates_to_zero() {
    let mle_evaluations = SumcheckMleEvaluations {
        num_sumcheck_variables: 1,
        ..Default::default()
    };
    let builder = VerificationBuilder::<Curve25519Scalar>::new(
        0,
        mle_evaluations,
        &[][..],
        &[][..],
        Vec::new(),
        Vec::new(),
    );
    assert_eq!(builder.sumcheck_evaluation(), Curve25519Scalar::zero());
}

#[test]
fn we_build_up_a_sumcheck_polynomial_evaluation_from_subpolynomial_evaluations() {
    let mle_evaluations = SumcheckMleEvaluations {
        num_sumcheck_variables: 1,
        ..Default::default()
    };
    let subpolynomial_multipliers = [
        Curve25519Scalar::from(10u64),
        Curve25519Scalar::from(100u64),
    ];
    let mut builder = VerificationBuilder::new(
        0,
        mle_evaluations,
        &[][..],
        &subpolynomial_multipliers,
        Vec::new(),
        Vec::new(),
    );
    builder.produce_sumcheck_subpolynomial_evaluation(
        SumcheckSubpolynomialType::ZeroSum,
        Curve25519Scalar::from(2u64),
    );
    builder.produce_sumcheck_subpolynomial_evaluation(
        SumcheckSubpolynomialType::ZeroSum,
        Curve25519Scalar::from(3u64),
    );
    let expected_sumcheck_evaluation = subpolynomial_multipliers[0] * Curve25519Scalar::from(2u64)
        + subpolynomial_multipliers[1] * Curve25519Scalar::from(3u64);
    assert_eq!(builder.sumcheck_evaluation(), expected_sumcheck_evaluation);
}

#[test]
fn we_can_consume_post_result_challenges_in_proof_builder() {
    let mut builder = VerificationBuilder::new(
        0,
        SumcheckMleEvaluations::default(),
        &[][..],
        &[][..],
        vec![
            Curve25519Scalar::from(123),
            Curve25519Scalar::from(456),
            Curve25519Scalar::from(789),
        ],
        Vec::new(),
    );
    assert_eq!(
        Curve25519Scalar::from(789),
        builder.consume_post_result_challenge()
    );
    assert_eq!(
        Curve25519Scalar::from(456),
        builder.consume_post_result_challenge()
    );
    assert_eq!(
        Curve25519Scalar::from(123),
        builder.consume_post_result_challenge()
    );
}
