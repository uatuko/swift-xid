enum XidError: Error {
	case decodeValidationFailure
	case invalidIdStringLength(have: Int, want: Int)
}
