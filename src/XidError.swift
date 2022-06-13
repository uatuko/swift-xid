enum XidError: Error, Equatable {
	case decodeValidationFailure
	case invalidId
	case invalidIdStringLength(have: Int, want: Int)
}
