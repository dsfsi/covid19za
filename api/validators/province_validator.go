package validators

func IsValidProvince(value string) bool {
	provinces := [9]string{"EC", "FS", "GP", "KZN", "LP", "MP", "NC", "NW", "WC"}
	for _, province := range provinces {
		if province == value {
			return true
		}
	}

	return false
}
