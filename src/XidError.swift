enum XidError: Error {
	case decodeValidationFailure
	case invalidId
	case invalidIdStringLength(have: Int, want: Int)
}
