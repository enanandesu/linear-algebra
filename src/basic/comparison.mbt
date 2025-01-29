///|
/// Returns the larger of two values of the same type that implements the
/// `Compare` trait.
///
/// Parameters:
///
/// * `a` : First value to compare.
/// * `b` : Second value to compare.
///
/// Returns the maximum of the two values.
///
/// Example:
///
/// ```moonbit
/// test "max" {
///   inspect!(max(3, 5), content="5")
///   inspect!(max(2.5, 1.5), content="2.5")
///   inspect!(max("abc", "def"), content="\"def\"")
/// }
/// ```
pub fn max[T : Compare](a : T, b : T) -> T {
  if a > b {
    a
  } else {
    b
  }
}

///|
/// Returns the smaller of two values of the same type that implements the
/// `Compare` trait.
///
/// Parameters:
///
/// * `first` : First value to compare.
/// * `second` : Second value to compare.
///
/// Returns the minimum of the two values.
///
/// Example:
///
/// ```moonbit
/// test "min" {
///   inspect!(min(3, 5), content="3")
///   inspect!(min(2.5, 1.5), content="1.5")
///   inspect!(min("abc", "def"), content="\"abc\"")
/// }
/// ```
pub fn min[T : Compare](a : T, b : T) -> T {
  if a < b {
    a
  } else {
    b
  }
}

///|
/// Constrains a value of any comparable type within a specified range \[minimum,
/// maximum].
///
/// Parameters:
///
/// * `value` : The value to be clamped.
/// * `minimum` : The lower bound of the range (inclusive).
/// * `maximum` : The upper bound of the range (inclusive).
///
/// Returns the clamped value:
///
/// * If `value` is less than `minimum`, returns `minimum`.
/// * If `value` is greater than `maximum`, returns `maximum`.
/// * Otherwise, returns `value` unchanged.
///
/// Example:
///
/// ```moonbit
/// test "clamp" {
///   inspect!(clamp(5, 0, 10), content="5")
///   inspect!(clamp(-1, 0, 10), content="0")
///   inspect!(clamp(15, 0, 10), content="10")
/// }
/// ```
pub fn clamp[T : Compare](value : T, min : T, max : T) -> T {
  if value < min {
    min
  } else if value > max {
    max
  } else {
    value
  }
}

///|
/// Checks if a value is within a closed interval \[minimum, maximum].
///
/// Parameters:
///
/// * `value` : The value to check.
/// * `minimum` : The lower bound of the interval (inclusive).
/// * `maximum` : The upper bound of the interval (inclusive).
///
/// Returns `true` if the value is greater than or equal to `minimum` and less
/// than or equal to `maximum`, `false` otherwise.
///
/// Example:
///
/// ```moonbit
/// test "is_between" {
///   inspect!(is_between(5, 0, 10), content="true")
///   inspect!(is_between(0, 1, 10), content="false")
///   inspect!(is_between(1.5, 1.0, 2.0), content="true")
/// }
/// ```
pub fn is_between[T : Compare](value : T, min : T, max : T) -> Bool {
  value >= min && value <= max
}
