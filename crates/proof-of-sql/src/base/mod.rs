//! This module contains basic shared functionalities of the library.
/// TODO: add docs
pub(crate) mod bit;
pub mod commitment;
pub mod database;
/// TODO: add docs
pub(crate) mod encode;
pub mod math;
/// TODO: add docs
pub(crate) mod polynomial;
pub(crate) mod proof;
pub(crate) mod ref_into;
pub mod scalar;
mod serialize;
pub(crate) use serialize::{impl_serde_for_ark_serde_checked, impl_serde_for_ark_serde_unchecked};
pub(crate) mod slice_ops;

mod rayon_cfg;
pub(crate) use rayon_cfg::if_rayon;
